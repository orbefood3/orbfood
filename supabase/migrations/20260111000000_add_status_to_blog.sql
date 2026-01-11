-- Add status column to blog_posts
ALTER TABLE public.blog_posts ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'draft';

-- Migrate existing is_published values
UPDATE public.blog_posts SET status = 'published' WHERE is_published = true;
UPDATE public.blog_posts SET status = 'draft' WHERE is_published = false;

-- Add check constraint for status
ALTER TABLE public.blog_posts ADD CONSTRAINT blog_posts_status_check
  CHECK (status IN ('draft', 'published', 'announcement'));
