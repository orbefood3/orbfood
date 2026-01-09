-- Allow admins to delete profiles
CREATE POLICY "Admins can delete profiles"
ON user_profiles FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM user_profiles
    WHERE id = auth.uid() AND role = 'admin'
  )
);
