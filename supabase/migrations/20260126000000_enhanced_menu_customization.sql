-- Migration to support the new Menu Customization (Prasmanan/Topping) system
-- This replaces the old simple bundle system

-- 1. Clean up old table
DROP TABLE IF EXISTS menu_package_items;

-- 2. Add type column to menu_items
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'menu_item_type') THEN
        CREATE TYPE menu_item_type AS ENUM ('single', 'package');
    END IF;
END $$;

ALTER TABLE menu_items 
ADD COLUMN IF NOT EXISTS type menu_item_type DEFAULT 'single';

-- 3. Create Option Groups table
CREATE TABLE IF NOT EXISTS menu_option_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    menu_id UUID NOT NULL REFERENCES menu_items(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    is_required BOOLEAN DEFAULT false,
    min_selection INTEGER DEFAULT 0,
    max_selection INTEGER DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Create Option Items table
CREATE TABLE IF NOT EXISTS menu_option_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES menu_option_groups(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    additional_price INTEGER DEFAULT 0,
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Add RLS policies (simple for now, following existing project patterns)
ALTER TABLE menu_option_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE menu_option_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public select for option groups" ON menu_option_groups FOR SELECT USING (true);
CREATE POLICY "Allow public select for option items" ON menu_option_items FOR SELECT USING (true);

-- Shop owners can manage their own groups
CREATE POLICY "Allow shop owners to manage option groups" ON menu_option_groups
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM menu_items m
            JOIN shops s ON m.shop_id = s.id
            WHERE m.id = menu_option_groups.menu_id
            AND s.owner_id = auth.uid()
        )
    );

CREATE POLICY "Allow shop owners to manage option items" ON menu_option_items
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM menu_option_groups g
            JOIN menu_items m ON g.menu_id = m.id
            JOIN shops s ON m.shop_id = s.id
            WHERE g.id = menu_option_items.group_id
            AND s.owner_id = auth.uid()
        )
    );
