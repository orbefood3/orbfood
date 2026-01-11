-- Redefine increment_shop_views with SECURITY DEFINER and proper permissions
CREATE OR REPLACE FUNCTION increment_shop_views(shop_uuid UUID)
RETURNS void AS $$
BEGIN
  UPDATE shops SET total_views = total_views + 1 WHERE id = shop_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute to all roles since this is a public metric
GRANT EXECUTE ON FUNCTION increment_shop_views(UUID) TO anon, authenticated;

-- Redefine increment_menu_views with SECURITY DEFINER and proper permissions
CREATE OR REPLACE FUNCTION increment_menu_views(menu_uuid UUID)
RETURNS void AS $$
BEGIN
  UPDATE menu_items SET view_count = view_count + 1 WHERE id = menu_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute to all roles 
GRANT EXECUTE ON FUNCTION increment_menu_views(UUID) TO anon, authenticated;
