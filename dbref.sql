-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- SHOPS TABLE
-- ============================================
CREATE TABLE shops (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Basic Info
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  description TEXT,
  category TEXT NOT NULL, -- 'makanan', 'minuman', 'camilan', 'lainnya'
  
  -- Contact
  phone TEXT NOT NULL,
  whatsapp TEXT NOT NULL,
  address TEXT,
  
  -- Images
  logo_url TEXT,
  banner_url TEXT,
  
  -- Operating Hours
  open_time TIME,
  close_time TIME,
  is_open BOOLEAN DEFAULT true,
  
  -- Status
  is_active BOOLEAN DEFAULT true,
  is_verified BOOLEAN DEFAULT false,
  
  -- Stats (denormalized for performance)
  total_views INTEGER DEFAULT 0,
  total_menus INTEGER DEFAULT 0,
  rating DECIMAL(2,1) DEFAULT 0,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- MENU ITEMS TABLE
-- ============================================
CREATE TABLE menu_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
  
  -- Basic Info
  name TEXT NOT NULL,
  description TEXT,
  price INTEGER NOT NULL,
  category TEXT, -- 'makanan utama', 'minuman', 'camilan', 'paket'
  
  -- Images
  cloudinary_images JSONB DEFAULT '[]'::jsonb,
  -- [{ url: 'https://...', thumbnail: 'https://...', publicId: 'xxx' }]
  
  external_images JSONB DEFAULT '[]'::jsonb,
  -- [{ url: 'https://...', preview: 'https://...', platform: 'google_drive' }]
  
  primary_image TEXT,
  
  -- Status
  is_available BOOLEAN DEFAULT true,
  stock INTEGER, -- NULL = unlimited
  
  -- Stats
  view_count INTEGER DEFAULT 0,
  order_count INTEGER DEFAULT 0,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- USER PROFILES TABLE (Optional Login)
-- ============================================
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  phone TEXT,
  avatar_url TEXT,
  favorite_shops UUID[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- ORDER HISTORY TABLE (For Logged-in Users)
-- ============================================
CREATE TABLE order_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  shop_id UUID REFERENCES shops(id) ON DELETE SET NULL,
  
  -- Order Details
  items JSONB NOT NULL,
  -- [{ menu_id, name, price, qty, image }]
  
  total_price INTEGER NOT NULL,
  customer_name TEXT NOT NULL,
  customer_phone TEXT NOT NULL,
  notes TEXT,
  
  -- Tracking
  status TEXT DEFAULT 'sent_to_wa',
  whatsapp_sent_at TIMESTAMPTZ DEFAULT NOW(),
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- SHOP REVIEWS (Phase 2)
-- ============================================
CREATE TABLE shop_reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, shop_id)
);

-- ============================================
-- BLOG POSTS (For Your Branding)
-- ============================================
CREATE TABLE blog_posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  author_id UUID REFERENCES auth.users(id),
  
  title TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  excerpt TEXT,
  content TEXT NOT NULL,
  cover_image TEXT,
  
  category TEXT, -- 'tips', 'success-story', 'tutorial', 'announcement'
  tags TEXT[],
  
  is_published BOOLEAN DEFAULT false,
  published_at TIMESTAMPTZ,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================
CREATE INDEX idx_shops_slug ON shops(slug);
CREATE INDEX idx_shops_category ON shops(category);
CREATE INDEX idx_shops_active ON shops(is_active, is_verified);
CREATE INDEX idx_menu_shop ON menu_items(shop_id);
CREATE INDEX idx_menu_available ON menu_items(is_available);
CREATE INDEX idx_order_user ON order_history(user_id, created_at DESC);
CREATE INDEX idx_order_shop ON order_history(shop_id, created_at DESC);
CREATE INDEX idx_blog_slug ON blog_posts(slug);
CREATE INDEX idx_blog_published ON blog_posts(is_published, published_at DESC);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Shops: Public can read, owners can update
ALTER TABLE shops ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Shops are viewable by everyone" 
ON shops FOR SELECT 
USING (is_active = true);

CREATE POLICY "Shop owners can update their own shops" 
ON shops FOR UPDATE 
USING (auth.uid() = owner_id);

CREATE POLICY "Shop owners can insert their own shops" 
ON shops FOR INSERT 
WITH CHECK (auth.uid() = owner_id);

-- Menu Items: Public can read, shop owners can manage
ALTER TABLE menu_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Menu items are viewable by everyone" 
ON menu_items FOR SELECT 
USING (true);

CREATE POLICY "Shop owners can manage their menu items" 
ON menu_items FOR ALL 
USING (
  EXISTS (
    SELECT 1 FROM shops 
    WHERE shops.id = menu_items.shop_id 
    AND shops.owner_id = auth.uid()
  )
);

-- Order History: Users can only see their own
ALTER TABLE order_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own orders" 
ON order_history FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Anyone can insert orders" 
ON order_history FOR INSERT 
WITH CHECK (true);

-- User Profiles: Users can only manage their own
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile" 
ON user_profiles FOR SELECT 
USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" 
ON user_profiles FOR UPDATE 
USING (auth.uid() = id);

-- Blog Posts: Public can read published, admin can manage
ALTER TABLE blog_posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Published posts are viewable by everyone" 
ON blog_posts FOR SELECT 
USING (is_published = true);

CREATE POLICY "Authors can manage their own posts" 
ON blog_posts FOR ALL 
USING (auth.uid() = author_id);

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_shops_updated_at BEFORE UPDATE ON shops
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_menu_items_updated_at BEFORE UPDATE ON menu_items
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Update shop's total_menus count
CREATE OR REPLACE FUNCTION update_shop_menu_count()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE shops 
  SET total_menus = (
    SELECT COUNT(*) FROM menu_items 
    WHERE shop_id = COALESCE(NEW.shop_id, OLD.shop_id)
  )
  WHERE id = COALESCE(NEW.shop_id, OLD.shop_id);
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_menu_count_on_insert 
AFTER INSERT ON menu_items
FOR EACH ROW EXECUTE FUNCTION update_shop_menu_count();

CREATE TRIGGER update_menu_count_on_delete 
AFTER DELETE ON menu_items
FOR EACH ROW EXECUTE FUNCTION update_shop_menu_count();

-- Increment shop views
CREATE OR REPLACE FUNCTION increment_shop_views(shop_uuid UUID)
RETURNS void AS $$
BEGIN
  UPDATE shops SET total_views = total_views + 1 WHERE id = shop_uuid;
END;
$$ LANGUAGE plpgsql;

-- Increment menu views
CREATE OR REPLACE FUNCTION increment_menu_views(menu_uuid UUID)
RETURNS void AS $$
BEGIN
  UPDATE menu_items SET view_count = view_count + 1 WHERE id = menu_uuid;
END;
$$ LANGUAGE plpgsql;