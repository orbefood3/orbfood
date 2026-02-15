-- Allow viewing any order linked to a group room
-- This is necessary so participants can see the group rekap/summary
DROP POLICY IF EXISTS "Users can view group room orders" ON order_history;

CREATE POLICY "Users can view group room orders"
ON order_history FOR SELECT
USING (
  order_room_id IS NOT NULL
);

-- Note: We keep the existing "Users can view their own orders" and 
-- "Shop owners can view their shop orders" policies.
-- This new policy specifically enables the communal rekap feature.
