-- Move payment collection to user profiles for reusability
-- Users can set payment info once and reuse it for all future rooms

-- Add payment fields to user_profiles
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS payment_method TEXT CHECK (payment_method IN ('qris', 'bank_transfer')),
ADD COLUMN IF NOT EXISTS qris_image_url TEXT,
ADD COLUMN IF NOT EXISTS bank_name TEXT,
ADD COLUMN IF NOT EXISTS bank_account_number TEXT,
ADD COLUMN IF NOT EXISTS bank_account_name TEXT;

-- Remove payment fields from order_rooms (cleanup from previous migration)
-- These fields were added but we're moving them to profiles instead
ALTER TABLE order_rooms 
DROP COLUMN IF EXISTS payment_method,
DROP COLUMN IF EXISTS qris_image_url,
DROP COLUMN IF EXISTS bank_name,
DROP COLUMN IF EXISTS bank_account_number,
DROP COLUMN IF EXISTS bank_account_name;

-- Add comments for clarity
COMMENT ON COLUMN user_profiles.payment_method IS 'Preferred payment method for group orders: qris or bank_transfer';
COMMENT ON COLUMN user_profiles.qris_image_url IS 'Stored QRIS image URL for receiving payments';
COMMENT ON COLUMN user_profiles.bank_name IS 'Bank name for receiving transfers';
COMMENT ON COLUMN user_profiles.bank_account_number IS 'Bank account number';
COMMENT ON COLUMN user_profiles.bank_account_name IS 'Account holder name';
