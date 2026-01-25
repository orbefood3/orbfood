<script lang="ts">
  import { supabase, getAuthRedirectUrl } from "../../services/supabase";
  export let title: string = "Halaman";
  export let user: any = null;

  let agreed = false;

  async function loginWithGoogle() {
    if (!agreed) return;
    const { error } = await supabase.auth.signInWithOAuth({
      provider: "google",
      options: {
        redirectTo: getAuthRedirectUrl(),
      },
    });
    if (error) console.error("Error logging in:", error.message);
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

      <label class="agreement">
        <input type="checkbox" bind:checked={agreed} />
        <span>
          Dengan login, saya menyetujui
          <a href="#/privacy">Kebijakan Privasi</a>
          dan
          <a href="#/terms">Syarat Layanan</a>
        </span>
      </label>

      <button class="bg-accent" on:click={loginWithGoogle} disabled={!agreed}>
        Login dengan Google
      </button>
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

  button:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }

  .agreement {
    display: flex;
    align-items: flex-start;
    gap: 10px;
    font-size: 13px;
    color: var(--text-main);
    cursor: pointer;
    text-align: left;
    max-width: 300px;
  }

  .agreement input[type="checkbox"] {
    width: 18px;
    height: 18px;
    margin-top: 2px;
    accent-color: var(--primary);
    cursor: pointer;
    flex-shrink: 0;
  }

  .agreement span {
    flex: 1;
    line-height: 1.5;
  }

  .agreement a {
    color: var(--primary);
    text-decoration: underline;
    font-weight: 600;
  }
</style>
