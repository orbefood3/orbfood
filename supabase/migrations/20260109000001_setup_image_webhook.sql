-- Webhook setup guide (Manual setup via Dashboard is recommended)

-- Hook for deleting/updating images via Edge Function
-- Note: Replace 'YOUR_PROJECT_REF' with your actual project reference or use the local URL
-- Since migrations should be generic, we usually set this up in the dashboard or via a config script.
-- However, we can provide the SQL as a guide.

/*
  HOW TO ENABLE WEBHOOK MANUALLY (RECOMMENDED):
  1. Go to Supabase Dashboard -> Database -> Webhooks.
  2. Create a new Webhook:
     - Name: 'delete_menu_image'
     - Table: 'menu_items'
     - Events: 'UPDATE', 'DELETE'
     - Target: 'HTTP Request'
     - Method: 'POST'
     - URL: 'https://[PROJECT_REF].functions.supabase.co/delete-image'
     - Headers: 
       - Authorization: Bearer [YOUR_ANON_KEY] (Optional, since we used --no-verify-jwt for webhooks usually or handle it)
*/

-- If you want to use SQL to create the trigger (requires pg_net):
-- This is harder to genericize without project refs, so dashboard is often better for newcomers.
