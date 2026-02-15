-- Add payment_status to order_history
ALTER TABLE order_history 
ADD COLUMN IF NOT EXISTS payment_status TEXT NOT NULL DEFAULT 'none';

-- Update existing records
-- If transfer_proof_url is present, set to pending
UPDATE order_history 
SET payment_status = 'pending' 
WHERE transfer_proof_url IS NOT NULL 
AND payment_status = 'none';

-- Add check constraint for valid statuses
ALTER TABLE order_history
ADD CONSTRAINT check_payment_status 
CHECK (payment_status IN ('none', 'pending', 'verified'));
