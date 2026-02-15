-- Update RLS policies for proper recap access control
-- Only room creators can view participant orders for verification

-- Drop policies if they exist to avoid conflict
DROP POLICY IF EXISTS "Users can view group room orders" ON order_history;
DROP POLICY IF EXISTS "Users can view their own orders" ON order_history;
DROP POLICY IF EXISTS "Room creators can view participant orders" ON order_history;

-- Recreate proper access control policies
-- Users can always view their own orders
CREATE POLICY "Users can view their own orders"
ON order_history FOR SELECT
USING (auth.uid() = user_id);

-- Room creators can view ALL orders in their rooms (for recap/verification)
CREATE POLICY "Room creators can view participant orders"
ON order_history FOR SELECT
USING (
  order_room_id IS NOT NULL 
  AND EXISTS (
    SELECT 1 FROM order_rooms
    WHERE order_rooms.id = order_history.order_room_id
    AND order_rooms.creator_id = auth.uid()
  )
);

-- Note: Existing policies for shop owners and admins are preserved
-- (from migration 20260111000001_tighten_orders_rls.sql)
