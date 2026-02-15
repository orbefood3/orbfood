-- Allow room members to view orders in their group room
-- This enables the collective rekap feature for everyone in the room
DROP POLICY IF EXISTS "Room members can view room orders" ON order_history;
CREATE POLICY "Room members can view room orders" 
ON order_history FOR SELECT 
TO authenticated 
USING (
  order_room_id IS NOT NULL 
  AND EXISTS (
    SELECT 1 FROM order_rooms
    WHERE order_rooms.id = order_history.order_room_id
    -- Allow viewing if room is open or if you are the creator
    AND (order_rooms.status = 'open' OR order_rooms.creator_id = auth.uid())
  )
);
