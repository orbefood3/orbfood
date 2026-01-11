-- Add interaction tracking columns to shops table
ALTER TABLE shops ADD COLUMN IF NOT EXISTS wa_taps INTEGER DEFAULT 0;
ALTER TABLE shops ADD COLUMN IF NOT EXISTS maps_taps INTEGER DEFAULT 0;

-- Function to atomically increment shop interaction counters
CREATE OR REPLACE FUNCTION increment_shop_interaction(shop_id UUID, interaction_type TEXT)
RETURNS void AS $$
BEGIN
    IF interaction_type = 'whatsapp' THEN
        UPDATE shops SET wa_taps = wa_taps + 1 WHERE id = shop_id;
    ELSIF interaction_type = 'google_maps' THEN
        UPDATE shops SET maps_taps = maps_taps + 1 WHERE id = shop_id;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant access to the function
GRANT EXECUTE ON FUNCTION increment_shop_interaction(UUID, TEXT) TO anon, authenticated;
