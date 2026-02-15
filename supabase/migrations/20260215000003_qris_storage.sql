-- Create storage bucket for QRIS images
INSERT INTO storage.buckets (id, name, public)
VALUES ('qris_images', 'qris_images', true)
ON CONFLICT (id) DO NOTHING;

-- RLS Policy: Anyone can read QRIS images (public bucket)
CREATE POLICY "Anyone can view QRIS images"
ON storage.objects FOR SELECT
USING (bucket_id = 'qris_images');

-- RLS Policy: Authenticated users can upload QRIS images
CREATE POLICY "Authenticated users can upload QRIS"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'qris_images'
  AND auth.role() = 'authenticated'
);

-- RLS Policy: Users can delete their own QRIS images
CREATE POLICY "Users can delete own QRIS images"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'qris_images'
  AND auth.uid()::text = (storage.foldername(name))[1]
);
