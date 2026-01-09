<script lang="ts">
  import { supabase } from '../../services/supabase';
  export let user: any = null;
  export let profile: any = null;
  export let onBukaToko: () => void;

  const menuItems = [
    { icon: "📜", label: "Riwayat Pesanan" },
    { icon: "📍", label: "Alamat Pengiriman" },
    { icon: "⭐", label: "Ulasan Saya" },
    { icon: "❓", label: "Bantuan" },
    { icon: "ℹ️", label: "Tentang Aplikasi" },
  ];

  async function handleLogout() {
    await supabase.auth.signOut();
  }
</script>

<div class="profile-page">
  <header class="profile-header bg-primary">
    <div class="user-info">
      <img src={user.user_metadata.avatar_url} alt="Avatar" class="avatar shadow-soft" />
      <div class="text-info">
        <h2>{profile?.display_name || user.user_metadata.full_name}</h2>
        <p>{user.email}</p>
        <div class="flex gap-2">
          <span class="auth-badge uppercase">{profile?.role || 'User'}</span>
          <span class="auth-badge opacity-70">Google Account</span>
        </div>
      </div>
    </div>
  </header>

  <main class="profile-menu">
    {#if profile?.role === 'user'}
      <button class="buka-toko-card rounded-lg shadow-soft" on:click={onBukaToko}>
        <div class="buka-toko-content">
          <span class="icon">🟦</span>
          <div class="text">
            <h3>Buka Toko Anda</h3>
            <p>Mulai jualan makanan di sekitar Anda</p>
          </div>
          <span class="arrow">›</span>
        </div>
      </button>
    {/if}

    {#each menuItems as item}
      <button class="menu-item">
        <span class="menu-icon">{item.icon}</span>
        <span class="menu-label">{item.label}</span>
        <span class="arrow">›</span>
      </button>
    {/each}

    <button class="menu-item logout-btn" on:click={handleLogout}>
      <span class="menu-icon">🚪</span>
      <span class="menu-label">Keluar</span>
    </button>
  </main>
</div>

<style>
  .profile-page {
    display: flex;
    flex-direction: column;
    flex: 1;
    background: var(--bg-soft);
  }

  .profile-header {
    padding: 32px 20px;
    color: white;
  }

  .user-info {
    display: flex;
    align-items: center;
    gap: 16px;
  }

  .avatar {
    width: 64px;
    height: 64px;
    border-radius: 50%;
    border: 3px solid rgba(255,255,255,0.2);
  }

  .text-info h2 {
    margin: 0;
    font-size: 18px;
    font-weight: 700;
  }

  .text-info p {
    margin: 2px 0;
    font-size: 13px;
    opacity: 0.8;
  }

  .auth-badge {
    display: inline-block;
    font-size: 10px;
    background: rgba(255,255,255,0.15);
    padding: 2px 8px;
    border-radius: 10px;
    margin-top: 4px;
  }

  .profile-menu {
    padding: 20px 16px;
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .buka-toko-card {
    background: white;
    padding: 16px;
    border: 1px solid var(--bg-soft);
    text-align: left;
    margin-bottom: 8px;
  }

  .buka-toko-content {
    display: flex;
    align-items: center;
    gap: 16px;
  }

  .buka-toko-content h3 {
    margin: 0;
    font-size: 16px;
    color: var(--primary);
  }

  .buka-toko-content p {
    margin: 2px 0 0 0;
    font-size: 13px;
    color: var(--text-muted);
  }

  .menu-item {
    display: flex;
    align-items: center;
    padding: 16px 20px;
    background: white;
    border-radius: 12px;
    text-align: left;
    gap: 16px;
  }

  .menu-icon {
    font-size: 20px;
    width: 24px;
    text-align: center;
  }

  .menu-label {
    flex: 1;
    font-size: 15px;
    font-weight: 500;
    color: var(--text-main);
  }

  .arrow {
    font-size: 24px;
    color: var(--text-hint);
    opacity: 0.5;
  }

  .logout-btn .menu-label {
    color: var(--danger);
  }
</style>
