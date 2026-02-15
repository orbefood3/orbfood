-- Broaden delete policy for transfer_proofs: 
-- 1. Creator of the room can delete
-- 2. Owner of the shop associated with the room can delete
DROP POLICY IF EXISTS "Room Creators can delete proofs" ON storage.objects;

CREATE POLICY "Creators and Shop Owners can delete proofs"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'transfer_proofs'
    AND (
        EXISTS (
            SELECT 1 FROM public.order_rooms r
            LEFT JOIN public.shops s ON r.store_id = s.id
            WHERE r.id::text = (storage.foldername(storage.objects.name))[1]
            AND (r.creator_id = auth.uid() OR s.owner_id = auth.uid())
        )
    )
);
