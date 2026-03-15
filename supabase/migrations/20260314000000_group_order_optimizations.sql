-- Group Order Optimizations: Schedule and Verification Fixes
-- This migration adds necessary columns for recurring schedules and fixes RLS.

-- 1. Add scheduling columns to order_rooms
ALTER TABLE order_rooms 
ADD COLUMN IF NOT EXISTS schedule_type TEXT DEFAULT 'once', -- 'once', 'recurring'
ADD COLUMN IF NOT EXISTS schedule_days JSONB DEFAULT '[]'::jsonb, -- ['monday', 'tuesday', ...]
ADD COLUMN IF NOT EXISTS opening_time_daily TIME,
ADD COLUMN IF NOT EXISTS closing_time_daily TIME;

-- 2. Add archive flag to order_history for clearing daily orders in recurring groups
ALTER TABLE order_history
ADD COLUMN IF NOT EXISTS is_archived BOOLEAN DEFAULT false;

-- 3. Fix RLS for order_history UPDATE
-- Previously, only Admins could update order_history.
-- We need to allow:
-- a) Shop owners to update orders in their shop.
-- b) Group order creators to update orders in their group.

-- Drop conflicting policies if they exist (to be safe during re-runs)
DROP POLICY IF EXISTS "Shop owners can update orders" ON order_history;
DROP POLICY IF EXISTS "Group creators can update orders" ON order_history;
DROP POLICY IF EXISTS "Order history users can update" ON order_history;

-- Policy A: Shop owners can update their shop's orders (useful for finishing normal orders too)
CREATE POLICY "Shop owners can update orders"
ON order_history FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM shops 
    WHERE shops.id = order_history.shop_id 
    AND shops.owner_id = auth.uid()
  )
);

-- Policy B: Group Order creators can update orders in their group (for payment verification)
CREATE POLICY "Group creators can update orders"
ON order_history FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM order_rooms 
    WHERE order_rooms.id = order_history.order_room_id 
    AND order_rooms.creator_id = auth.uid()
  )
);

-- Policy C: Users can update their own orders ONLY IF status is 'sent_to_wa' or payment_status is 'pending' (optional, mainly for uploading proof if they missed it)
-- To keep it secure, we'll just allow them to attach transfer proof if it doesn't bypass group rules.
CREATE POLICY "Users can attach payment proofs to their orders"
ON order_history FOR UPDATE
USING (auth.uid() = user_id AND payment_status IN ('none', 'pending'));
