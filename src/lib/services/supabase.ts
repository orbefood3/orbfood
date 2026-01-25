import { createClient } from '@supabase/supabase-js';

export const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
export const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
    console.error('Missing Supabase environment variables');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

/**
 * Helper to get the correct redirect URL for authentication based on current environment.
 * Prioritizes VITE_AUTH_REDIRECT_URL from .env if present.
 */
export function getAuthRedirectUrl() {
    // If we have an explicit override in .env
    const envRedirect = import.meta.env.VITE_AUTH_REDIRECT_URL;
    console.log('DEBUG: VITE_AUTH_REDIRECT_URL from env:', envRedirect);

    if (envRedirect) {
        console.log('DEBUG: Using env redirect:', envRedirect);
        return envRedirect;
    }

    // Default to current origin
    const origin = typeof window !== 'undefined' ? window.location.origin : '';
    console.log('DEBUG: Using origin redirect:', origin);
    return origin;
}
