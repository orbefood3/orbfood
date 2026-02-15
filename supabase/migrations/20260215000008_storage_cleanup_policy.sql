-- Allow Room Creators to delete files in their room's folder within transfer_proofs bucket
CREATE POLICY "Room Creators can delete proofs"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'transfer_proofs'
    AND (
        EXISTS (
            SELECT 1 FROM public.order_rooms
            WHERE id::text = (storage.foldername(name))[1]
            AND creator_id = auth.uid()
        )
    )
);
