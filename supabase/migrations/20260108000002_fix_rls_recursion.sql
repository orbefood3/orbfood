-- Create a function to get current user role without recursion
CREATE OR REPLACE FUNCTION public.get_auth_role()
RETURNS user_role AS $$
  SELECT role FROM public.user_profiles WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER;

-- Fix recursion in user_profiles policies
DROP POLICY IF EXISTS "Admins can see all profiles" ON user_profiles;
DROP POLICY IF EXISTS "Admins can update all profiles" ON user_profiles;

CREATE POLICY "Admins can see all profiles"
ON user_profiles FOR SELECT
USING (
  (SELECT role FROM user_profiles WHERE id = auth.uid()) = 'admin'
);

-- Actually, a better way for Supabase to avoid recursion is to use the auth.uid() check first
-- or use a security definer function.
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM user_profiles
    WHERE id = auth.uid() AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Redo policies using the function
DROP POLICY IF EXISTS "Admins can see all profiles" ON user_profiles;
DROP POLICY IF EXISTS "Admins can update all profiles" ON user_profiles;

CREATE POLICY "Admins can see all profiles"
ON user_profiles FOR SELECT
USING (is_admin());

CREATE POLICY "Admins can update all profiles"
ON user_profiles FOR UPDATE
USING (is_admin());

-- Fix Shop policies recursion as well
DROP POLICY IF EXISTS "Admins can manage all shops" ON shops;
CREATE POLICY "Admins can manage all shops"
ON shops FOR ALL
USING (is_admin());
