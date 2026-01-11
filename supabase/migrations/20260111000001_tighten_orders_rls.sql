-- Tighten RLS for order_history

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view their own orders" ON order_history;
DROP POLICY IF EXISTS "Anyone can insert orders" ON order_history;

-- 1. Anyone can insert orders (to support Guest Checkout)
-- In production, you might want to add a rate limit or CAPTCHA at the application layer.
CREATE POLICY "Anyone can insert orders" 
ON order_history FOR INSERT 
WITH CHECK (true);

-- 2. Users can view their own orders
CREATE POLICY "Users can view their own orders" 
ON order_history FOR SELECT 
USING (auth.uid() = user_id);

-- 3. Shop owners can view orders for their own shops
CREATE POLICY "Shop owners can view their shop orders"
ON order_history FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM shops 
    WHERE shops.id = order_history.shop_id 
    AND shops.owner_id = auth.uid()
  )
);

-- 4. Admins can view all orders
CREATE POLICY "Admins can view all orders"
ON order_history FOR SELECT
USING (public.is_admin());

-- 5. Admins can update orders (e.g., status)
CREATE POLICY "Admins can update all orders"
ON order_history FOR UPDATE
USING (public.is_admin());
