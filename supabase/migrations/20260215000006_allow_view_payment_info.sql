-- Allow authenticated users to view other users' profiles 
-- (Needed so participants can see the room creator's payment info)
DROP POLICY IF EXISTS "Users can view other profiles" ON user_profiles;
CREATE POLICY "Users can view other profiles" 
ON user_profiles FOR SELECT 
TO authenticated 
USING (true);
