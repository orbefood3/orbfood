<script lang="ts">
  import { supabase } from "../../services/supabase";
  export let user: any = null;
  export let profile: any = null;
  export let onBukaToko: () => void;
  export let onNavigate: (tab: string) => void = () => {};

  const menuItems = [
    { icon: "📜", label: "Riwayat Pesanan", action: "pesanan" },
  ];

  async function handleLogout() {
    await supabase.auth.signOut();
  }

  function handleMenuClick(action: string) {
    if (action) {
      onNavigate(action);
    }
  }
</script>

<div class="profile-page">
  <header class="profile-header bg-primary">
    <div class="user-info">
      <img
        src={user.user_metadata.avatar_url}
        alt="Avatar"
        class="avatar shadow-soft"
      />
      <div class="text-info">
        <h2>{profile?.display_name || user.user_metadata.full_name}</h2>
        <p>{user.email}</p>
        <div class="flex gap-2">
          <span class="auth-badge uppercase">{profile?.role || "User"}</span>
          <span class="auth-badge opacity-70">Google Account</span>
        </div>
      </div>
    </div>
  </header>

  <main class="profile-menu">
    {#if profile?.role === "user"}
      <button
        class="buka-toko-card rounded-lg shadow-soft"
        on:click={onBukaToko}
      >
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
      <button class="menu-item" on:click={() => handleMenuClick(item.action)}>
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
    overflow-y: auto;
    -webkit-overflow-scrolling: touch;
  }

  .profile-header {
    padding: 24px 16px 20px 16px;
    color: white;
    border-radius: 0 0 22px 22px;
    box-shadow: 0 16px 30px -24px rgba(15, 42, 68, 0.85);
  }

  .user-info {
    display: flex;
    align-items: center;
    gap: 16px;
  }

  .avatar {
    width: 68px;
    height: 68px;
    border-radius: 50%;
    border: 3px solid rgba(255, 255, 255, 0.32);
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
    background: rgba(255, 255, 255, 0.15);
    padding: 2px 8px;
    border-radius: 10px;
    margin-top: 4px;
  }

  .profile-menu {
    padding: 18px 14px 26px 14px;
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .buka-toko-card {
    background: linear-gradient(180deg, #ffffff 0%, #fff7ed 100%);
    padding: 16px;
    border: 1px solid #fed7aa;
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
    color: var(--accent);
  }

  .buka-toko-content p {
    margin: 2px 0 0 0;
    font-size: 13px;
    color: var(--text-muted);
  }

  .menu-item {
    display: flex;
    align-items: center;
    padding: 14px 16px;
    background: white;
    border-radius: 14px;
    border: 1px solid #e2e8f0;
    text-align: left;
    gap: 16px;
    box-shadow: 0 8px 20px -20px rgba(15, 42, 68, 0.55);
  }

  .menu-icon {
    font-size: 20px;
    width: 24px;
    text-align: center;
  }

  .menu-label {
    flex: 1;
    font-size: 14px;
    font-weight: 700;
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

  .logout-btn {
    border-color: #fecaca;
    background: #fef2f2;
  }
</style>
