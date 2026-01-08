# Setting Up Google Authentication with Supabase in Svelte

This guide provides step-by-step instructions for integrating Google OAuth authentication into your Svelte application using Supabase.

## Prerequisites

- A Google Cloud Console account
- A Supabase project
- Your Svelte app with Supabase client configured (see `src/lib/supabase.ts`)

## Step 1: Set Up Google OAuth Credentials

1. Go to the [Google Cloud Console](https://console.cloud.google.com/).
2. Create a new project or select an existing one.
3. Enable the Google+ API:
   - Navigate to "APIs & Services" > "Library"
   - Search for "Google+ API" and enable it.
4. Create OAuth 2.0 credentials:
   - Go to "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "OAuth 2.0 Client IDs"
   - Configure the OAuth consent screen if prompted
   - Set Application type to "Web application"
   - Add authorized redirect URIs:
     - For development: `http://localhost:5173/auth/callback` (adjust port if different)
     - For production: Your app's callback URL
   - Note down the Client ID and Client Secret

## Step 2: Configure Google Auth in Supabase

1. Log in to your [Supabase Dashboard](https://supabase.com/dashboard).
2. Select your project.
3. Go to "Authentication" > "Providers".
4. Find "Google" and click to configure.
5. Enter the Client ID and Client Secret from Step 1.
6. Set the redirect URL to match your app's callback URL.
7. Enable the provider and save.

## Step 3: Implement Google Auth in Your Svelte App

### Update Environment Variables

Add the following to your `.env` file (if not already present):
```
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

### Create Auth Callback Page

Create a new Svelte component for handling the OAuth callback:

```svelte
<!-- src/lib/AuthCallback.svelte -->
<script>
  import { onMount } from 'svelte';
  import { supabase } from './supabase';
  import { goto } from '$app/navigation';

  onMount(async () => {
    const { data, error } = await supabase.auth.getSession();
    if (error) {
      console.error('Error getting session:', error);
    } else if (data.session) {
      // User is authenticated, redirect to home or dashboard
      goto('/');
    } else {
      // Handle case where no session
      goto('/login');
    }
  });
</script>

<div>Loading...</div>
```

### Add Google Sign-In Button

In your login or home component, add a button to trigger Google sign-in:

```svelte
<!-- src/lib/LoginButton.svelte -->
<script>
  import { supabase } from './supabase';

  async function signInWithGoogle() {
    const { data, error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: `${window.location.origin}/auth/callback`
      }
    });

    if (error) {
      console.error('Error signing in with Google:', error);
    }
  }
</script>

<button on:click={signInWithGoogle}>
  Sign in with Google
</button>
```

### Handle Authentication State

Create a store or context to manage auth state across your app:

```javascript
// src/lib/authStore.js
import { writable } from 'svelte/store';
import { supabase } from './supabase';

export const user = writable(null);

supabase.auth.onAuthStateChange((event, session) => {
  user.set(session?.user ?? null);
});
```

### Protect Routes (Optional)

Use SvelteKit's route guards or check auth state in components:

```svelte
<!-- src/routes/protected/+page.svelte -->
<script>
  import { user } from '$lib/authStore';
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';

  onMount(() => {
    const unsubscribe = user.subscribe(currentUser => {
      if (!currentUser) {
        goto('/login');
      }
    });

    return unsubscribe;
  });
</script>

<!-- Protected content here -->
```

## Step 4: Test the Integration

1. Start your development server: `npm run dev`
2. Navigate to your login page
3. Click the "Sign in with Google" button
4. Complete the Google OAuth flow
5. Verify that the user is authenticated and redirected appropriately

## Troubleshooting

- **Redirect URI mismatch**: Ensure the redirect URI in Google Cloud Console matches the one in Supabase and your code.
- **CORS issues**: Make sure your Supabase project allows requests from your app's domain.
- **Session not persisting**: Check that cookies are enabled and your app handles auth state changes properly.

## Additional Resources

- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [Google OAuth 2.0 Documentation](https://developers.google.com/identity/protocols/oauth2)
- [SvelteKit Authentication Guide](https://kit.svelte.dev/docs#routing-pages)