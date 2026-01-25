-- Migration to add Menu Bundles (Menu Paket) support
ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS is_package BOOLEAN DEFAULT false;

CREATE TABLE IF NOT EXISTS menu_package_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_menu_id UUID NOT NULL REFERENCES menu_items(id) ON DELETE CASCADE,
    child_menu_id UUID NOT NULL REFERENCES menu_items(id) ON DELETE CASCADE,
    quantity INTEGER DEFAULT 1,
    additional_price INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    -- Ensure a menu can't be added to the same package multiple times
    UNIQUE(parent_menu_id, child_menu_id)
);

-- Index for performance
CREATE INDEX IF NOT EXISTS idx_menu_package_parent ON menu_package_items(parent_menu_id);

-- RLS
ALTER TABLE menu_package_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view package items"
ON menu_package_items FOR SELECT
USING (true);

CREATE POLICY "Shop owners can manage their package items"
ON menu_package_items FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM menu_items
        JOIN shops ON menu_items.shop_id = shops.id
        WHERE menu_items.id = menu_package_items.parent_menu_id
        AND shops.owner_id = auth.uid()
    )
);
