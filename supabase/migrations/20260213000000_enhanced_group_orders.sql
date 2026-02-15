-- Phase 2: Enhanced Group Orders (Automation & Payments)

-- 1. Update order_rooms for scheduled opening
ALTER TABLE order_rooms 
ADD COLUMN IF NOT EXISTS opening_time TIMESTAMPTZ DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS is_shop_managed BOOLEAN DEFAULT false;

-- 2. Update order_history for payment proof
ALTER TABLE order_history 
ADD COLUMN IF NOT EXISTS transfer_proof_url TEXT;

-- 3. Create Storage Bucket for Transfer Proofs
-- Note: This requires the storage extension to be enabled (usually is in Supabase)
INSERT INTO storage.buckets (id, name, public) 
VALUES ('transfer_proofs', 'transfer_proofs', true)
ON CONFLICT (id) DO NOTHING;

-- Storage RLS Policies
-- Allow public read of proofs (so shop owners and participants can see)
CREATE POLICY "Public Read Transfer Proofs"
ON storage.objects FOR SELECT
USING (bucket_id = 'transfer_proofs');

-- Allow authenticated users to upload to transfer_proofs
CREATE POLICY "Users can upload transfer proofs"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'transfer_proofs' 
    AND auth.role() = 'authenticated'
);

-- Allow users to delete their own proofs (if they want to replace)
CREATE POLICY "Users can delete their own transfer proofs"
ON storage.objects FOR DELETE
USING (bucket_id = 'transfer_proofs' AND auth.uid() = owner);

-- 4. Function to cleanup expired proofs (Storage maintenance)
-- This is a suggestion for a background worker or manual trigger
CREATE OR REPLACE FUNCTION purge_expired_proofs()
RETURNS void AS $$
BEGIN
    -- This would ideally delete files from storage.objects
    -- For now we just mark they're candidates for deletion if needed
    -- Real deletion usually requires a Service Role or Edge Function
END;
$$ LANGUAGE plpgsql;
