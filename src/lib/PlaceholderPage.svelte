<script lang="ts">
  import { supabase } from './supabase';
  export let title: string = "Halaman";
  export let user: any = null;

  async function loginWithGoogle() {
    const { error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: window.location.origin
      }
    });
    if (error) console.error('Error logging in:', error.message);
  }
</script>

<div class="placeholder-page">
  <div class="header bg-primary">
    <h1>{title}</h1>
  </div>
  <div class="content">
    {#if user}
      <div class="illustration">✅</div>
      <p>Kamu sudah login!</p>
    {:else}
      <div class="illustration">🔒</div>
      <p>Silakan login untuk melihat halaman ini</p>
      <button class="bg-accent" on:click={loginWithGoogle}>Login dengan Google</button>
    {/if}
  </div>
</div>

<style>
  .placeholder-page {
    display: flex;
    flex-direction: column;
    flex: 1;
    text-align: center;
  }

  .header {
    padding: 20px;
    color: white;
  }

  .header h1 {
    margin: 0;
    font-size: 20px;
  }

  .content {
    padding: 40px 20px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 16px;
  }

  .illustration {
    font-size: 64px;
  }

  p {
    color: var(--text-muted);
  }

  button {
    padding: 12px 24px;
    border-radius: 8px;
    font-weight: 600;
    color: white;
  }
</style>
