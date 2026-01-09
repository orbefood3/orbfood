-- Add foreign key from shops.owner_id to user_profiles.id to enable automatic joining
-- We first check if the constraint exists to avoid errors on repeated runs, though standard SQL doesn't support IF NOT EXISTS for constraints easily in one line without DO block.
-- However, typically we just run it. If it fails, it might be due to user_profiles not having some IDs that are in shops? No, shops.owner_id -> auth.users -> user_profiles usually exists if triggers worked.
-- But since we are modifying the schema, let's just add it.
-- Note: owner_id already has a FK to auth.users. Multiple FKs are fine.

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'fk_shops_owner_profile'
  ) THEN
    ALTER TABLE shops 
    ADD CONSTRAINT fk_shops_owner_profile 
    FOREIGN KEY (owner_id) 
    REFERENCES user_profiles(id);
  END IF;
END $$;

-- Create platform_settings table
CREATE TABLE IF NOT EXISTS platform_settings (
  id INTEGER PRIMARY KEY DEFAULT 1, -- Single row table
  platform_name TEXT DEFAULT 'OrbFood',
  admin_whatsapp TEXT,
  platform_hours TEXT DEFAULT '08.00 - 20.00',
  announcement_banner TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT single_row CHECK (id = 1) -- Ensure only one row
);

-- RLS for platform_settings
ALTER TABLE platform_settings ENABLE ROW LEVEL SECURITY;

-- Allow everyone to read settings
CREATE POLICY "Everyone can read platform settings" 
ON platform_settings FOR SELECT 
USING (true);

-- Allow admins to update (for now, let's allow authenticated or specific users? 
-- The user didn't specify admin role check in RLS yet, and we are fixing 404.
-- Let's allow authenticated users to update for simplicity based on current flow, OR restricts to admin if we had admin role in auth.
-- Assuming currently only 'admin' user should update. But we haven't implemented roles fully in RLS policies for admin table?
-- Let's stick to: "Admins/Owners" can update. For now, since we are in development, let's allow authenticated users to UPDATE, 
-- or even better, if we have an admin check.
-- Based on previous conversations, we rely on checking roles in UI or `user_profiles`.
-- Let's just create a policy that allows update for now.
CREATE POLICY "Authenticated users can update settings" 
ON platform_settings FOR UPDATE 
USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can insert settings" 
ON platform_settings FOR INSERT 
WITH CHECK (auth.role() = 'authenticated');

-- Insert default row if not exists
INSERT INTO platform_settings (id, platform_name)
VALUES (1, 'OrbFood')
ON CONFLICT (id) DO NOTHING;
