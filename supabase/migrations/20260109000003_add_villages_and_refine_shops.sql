-- Create villages table
CREATE TABLE IF NOT EXISTS villages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS for villages
ALTER TABLE villages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Everyone can read villages" 
ON villages FOR SELECT 
USING (true);

CREATE POLICY "Admins can manage villages" 
ON villages FOR ALL 
USING (
  EXISTS (
    SELECT 1 FROM user_profiles
    WHERE user_profiles.id = auth.uid()
    AND user_profiles.role = 'admin'
  )
);

-- Refine shops table
ALTER TABLE shops ADD COLUMN IF NOT EXISTS village_id UUID REFERENCES villages(id) ON DELETE SET NULL;
ALTER TABLE shops ADD COLUMN IF NOT EXISTS google_maps_url TEXT;
ALTER TABLE shops ADD COLUMN IF NOT EXISTS instagram_url TEXT;
ALTER TABLE shops ADD COLUMN IF NOT EXISTS tiktok_url TEXT;
ALTER TABLE shops ADD COLUMN IF NOT EXISTS is_delivery_available BOOLEAN DEFAULT false;

-- Add comments for clarity
COMMENT ON TABLE villages IS 'Standardized list of villages for shop location filtering';
COMMENT ON COLUMN shops.village_id IS 'Reference to the village where the shop is located';
COMMENT ON COLUMN shops.google_maps_url IS 'External link to Google Maps location';
COMMENT ON COLUMN shops.is_delivery_available IS 'Whether the shop offers delivery service';
