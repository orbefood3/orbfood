-- Add business_hours JSONB column to shops table
ALTER TABLE shops ADD COLUMN IF NOT EXISTS business_hours JSONB DEFAULT '{
  "monday": {"open": "08:00", "close": "20:00", "active": true},
  "tuesday": {"open": "08:00", "close": "20:00", "active": true},
  "wednesday": {"open": "08:00", "close": "20:00", "active": true},
  "thursday": {"open": "08:00", "close": "20:00", "active": true},
  "friday": {"open": "08:00", "close": "20:00", "active": true},
  "saturday": {"open": "08:00", "close": "20:00", "active": true},
  "sunday": {"open": "08:00", "close": "20:00", "active": true}
}'::jsonb;

-- Comment for clarity
COMMENT ON COLUMN shops.business_hours IS 'Weekly operational schedule for the shop';
