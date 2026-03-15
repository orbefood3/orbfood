<script lang="ts">
  import { createEventDispatcher } from "svelte";

  export let profile: any = null; // Optional profile data
  export let title: string = "Dashboard";
  export let activeTab: string;
  export let menuItems: Array<{
    id: string;
    label: string;
    icon: any; // Lucide icon component
    badge?: number | null;
  }>;
  export let sidebarOpen: boolean = false;

  const dispatch = createEventDispatcher();

  function handleLogout() {
    dispatch("logout");
  }

  function handleTabChange(id: string) {
    activeTab = id;
    dispatch("tabChange", id);
    dispatch("closeSidebar"); // Close sidebar on mobile on selection
  }
</script>

<div class="dashboard-layout">
  <!-- Sidebar -->
  <aside class="sidebar {sidebarOpen ? 'open' : ''}">
    <div class="sidebar-header">
      <div class="avatar">
        <slot name="header-icon">
          <div class="default-avatar">
            <span>{title[0]}</span>
          </div>
        </slot>
      </div>
      <div class="info">
        <h3>
          <slot name="header-title">{title}</slot>
        </h3>
        <span class="status-badge">
          <slot name="header-subtitle">Role: {profile?.role || "Admin"}</slot>
        </span>
      </div>
      <div class="header-actions-container">
        <slot name="header-actions" />
      </div>
    </div>

    <nav class="nav-links">
      {#each menuItems as item}
        <button
          class:active={activeTab === item.id}
          on:click={() => handleTabChange(item.id)}
        >
          <span class="icon">
            <svelte:component this={item.icon} size={18} />
          </span>
          <span class="label">{item.label}</span>
          {#if item.badge}
            <span class="badge">{item.badge}</span>
          {/if}
        </button>
      {/each}

      <button class="logout" on:click={handleLogout}>
        <span class="icon">🚪</span>
        <span class="label">Keluar</span>
      </button>
    </nav>
  </aside>

  <!-- Mobile Overlay -->
  {#if sidebarOpen}
    <div
      class="mobile-overlay"
      on:click={() => dispatch("closeSidebar")}
      on:keydown={() => dispatch("closeSidebar")}
      role="button"
      tabindex="0"
      aria-label="Close sidebar"
    ></div>
  {/if}

  <!-- Main Content -->
  <main class="content">
    <header class="mobile-header">
      <button
        class="menu-btn"
        on:click={() => dispatch("toggleSidebar")}
        aria-label="Open sidebar"
      >
        ☰
      </button>
      <div class="mobile-title">
        <h1>{title}</h1>
        <p>{profile?.role || "Admin"}</p>
      </div>
    </header>

    <div class="content-inner">
      <slot />
    </div>
  </main>
</div>

<style>
  .dashboard-layout {
    display: flex;
    min-height: 100vh;
    background: linear-gradient(180deg, #f8fafc 0%, #f1f5f9 100%);
    overflow: hidden;
  }

  .sidebar {
    width: 280px;
    background: linear-gradient(180deg, #0f172a 0%, #1e293b 100%);
    color: #f8fafc;
    display: flex;
    flex-direction: column;
    padding: 20px 14px 16px;
    flex-shrink: 0;
    z-index: 50;
    transition: transform 0.25s ease;
    border-right: 1px solid rgba(148, 163, 184, 0.2);
  }

  .sidebar-header {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 4px 8px 14px;
    border-bottom: 1px solid rgba(148, 163, 184, 0.2);
  }

  .avatar {
    width: 46px;
    height: 46px;
    border-radius: 14px;
    background: rgba(248, 250, 252, 0.08);
    border: 1px solid rgba(248, 250, 252, 0.14);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    overflow: hidden;
  }

  .default-avatar {
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
    font-weight: 700;
  }

  .info {
    min-width: 0;
    flex: 1;
  }

  .info h3 {
    margin: 0;
    font-size: 14px;
    font-weight: 700;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .status-badge {
    margin-top: 4px;
    display: inline-block;
    font-size: 10px;
    line-height: 1;
    font-weight: 700;
    padding: 5px 8px;
    border-radius: 999px;
    background: rgba(56, 189, 248, 0.18);
    color: #bae6fd;
  }

  .header-actions-container {
    display: flex;
    align-items: center;
  }

  .nav-links {
    margin-top: 14px;
    display: flex;
    flex-direction: column;
    gap: 6px;
    flex: 1;
    overflow-y: auto;
    padding-right: 4px;
  }

  .nav-links button {
    border: none;
    border-radius: 12px;
    background: transparent;
    color: rgba(241, 245, 249, 0.8);
    padding: 10px 12px;
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s ease;
    text-align: left;
  }

  .nav-links button:hover {
    color: #ffffff;
    background: rgba(51, 65, 85, 0.7);
  }

  .nav-links button.active {
    background: rgba(56, 189, 248, 0.18);
    color: #e0f2fe;
    box-shadow: inset 0 0 0 1px rgba(56, 189, 248, 0.22);
  }

  .icon {
    width: 18px;
    height: 18px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }

  .label {
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .badge {
    margin-left: auto;
    background: #ef4444;
    color: #fff;
    border-radius: 999px;
    padding: 2px 8px;
    font-size: 11px;
    font-weight: 700;
    line-height: 1.35;
  }

  .nav-links button.logout {
    margin-top: auto;
    color: #fca5a5;
  }

  .nav-links button.logout:hover {
    background: rgba(239, 68, 68, 0.14);
    color: #fecaca;
  }

  .content {
    flex: 1;
    overflow-y: auto;
    min-width: 0;
    padding: 20px;
  }

  .content-inner {
    width: 100%;
  }

  .mobile-header {
    display: none;
    align-items: center;
    gap: 10px;
    margin-bottom: 14px;
    padding: 10px 12px;
    background: #ffffff;
    border: 1px solid #e2e8f0;
    border-radius: 14px;
  }

  .mobile-title {
    min-width: 0;
  }

  .mobile-title h1 {
    margin: 0;
    font-size: 15px;
    line-height: 1.2;
    color: #0f172a;
  }

  .mobile-title p {
    margin: 2px 0 0;
    font-size: 11px;
    color: #64748b;
  }

  .menu-btn {
    border: none;
    background: #0f172a;
    color: #fff;
    width: 34px;
    height: 34px;
    border-radius: 10px;
    font-size: 18px;
    line-height: 1;
    cursor: pointer;
  }

  .mobile-overlay {
    position: fixed;
    inset: 0;
    z-index: 40;
    background: rgba(15, 23, 42, 0.46);
    backdrop-filter: blur(2px);
  }

  @media (max-width: 1024px) {
    .sidebar {
      position: fixed;
      top: 0;
      left: 0;
      bottom: 0;
      transform: translateX(-100%);
    }

    .sidebar.open {
      transform: translateX(0);
    }

    .mobile-header {
      display: flex;
    }

    .content {
      padding: 14px;
    }
  }
</style>
