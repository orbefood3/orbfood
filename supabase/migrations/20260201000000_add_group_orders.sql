-- Group Order Feature Migration
-- 1. Create order_rooms table
CREATE TABLE IF NOT EXISTS order_rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    store_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
    creator_id UUID REFERENCES auth.users(id) ON DELETE SET NULL, -- Optional if we allow anon creation later
    
    name TEXT NOT NULL DEFAULT 'Order Bersama',
    short_code TEXT UNIQUE, -- 6 char code for sharing
    
    closing_time TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL DEFAULT 'open', -- 'open', 'closed', 'sent'
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Add function to generate short_code
CREATE OR REPLACE FUNCTION generate_unique_short_code()
RETURNS TEXT AS $$
DECLARE
    chars TEXT := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    result TEXT := '';
    i INTEGER := 0;
    count_exists INTEGER;
BEGIN
    LOOP
        result := '';
        FOR i IN 1..6 LOOP
            result := result || substr(chars, floor(random() * length(chars) + 1)::integer, 1);
        END LOOP;

        SELECT count(*) INTO count_exists FROM order_rooms WHERE short_code = result;
        EXIT WHEN count_exists = 0;
    END LOOP;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- 3. Trigger to auto-fill short_code on insert
CREATE OR REPLACE FUNCTION set_short_code()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.short_code IS NULL THEN
        NEW.short_code := generate_unique_short_code();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_short_code
BEFORE INSERT ON order_rooms
FOR EACH ROW
EXECUTE FUNCTION set_short_code();

-- 4. Update order_history to link to rooms
ALTER TABLE order_history 
ADD COLUMN IF NOT EXISTS order_room_id UUID REFERENCES order_rooms(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS participant_name TEXT; -- Name used in the group order context

-- 5. RLS Policies
ALTER TABLE order_rooms ENABLE ROW LEVEL SECURITY;

-- Everyone can view open rooms (needed for listing in store)
CREATE POLICY "Public can view open rooms" 
ON order_rooms FOR SELECT 
USING (status = 'open' OR auth.uid() = creator_id);

-- Only authenticated users (or anyone?) can create rooms. Let's allow authenticated for now.
CREATE POLICY "Authenticated users can create rooms" 
ON order_rooms FOR INSERT 
WITH CHECK (auth.role() = 'authenticated');

-- Creator can update their rooms (close/finalize)
CREATE POLICY "Creator can update their rooms" 
ON order_rooms FOR UPDATE 
USING (auth.uid() = creator_id);

-- Update order_history policy to allow inserting into valid rooms
-- (Existing policies might be too strict or too loose, let's ensure this works)
-- We rely on the existing "Anyone can insert orders" policy which is TRUE.
-- But we might want to validate the room is open. We'll do that in Logic or a Trigger to be safe.

-- Validation Trigger (Optional but good)
CREATE OR REPLACE FUNCTION validate_room_open()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.order_room_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM order_rooms 
            WHERE id = NEW.order_room_id 
            AND status = 'open' 
            AND closing_time > NOW()
        ) THEN
            RAISE EXCEPTION 'This order room is closed.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validate_room_open
BEFORE INSERT ON order_history
FOR EACH ROW
EXECUTE FUNCTION validate_room_open();
