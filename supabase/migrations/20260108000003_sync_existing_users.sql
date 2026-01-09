-- Insert profiles for existing users who don't have one
INSERT INTO public.user_profiles (id, display_name, avatar_url, role)
SELECT 
    id, 
    raw_user_meta_data->>'full_name', 
    raw_user_meta_data->>'avatar_url', 
    'user'
FROM auth.users
ON CONFLICT (id) DO NOTHING;
