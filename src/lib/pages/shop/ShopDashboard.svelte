<script lang="ts">
  import { supabase } from "../../services/supabase";
  import { onMount } from "svelte";
  
  import ShopMenus from "./ShopMenus.svelte";
  import ShopSettings from "./ShopSettings.svelte";
  import {
    BarChart3,
    Utensils,
    Settings,
    ShoppingBag,
    Share2,
    Users as UsersIcon,
    LogOut,
  } from "lucide-svelte";
  import AdminOrders from "../admin/AdminOrders.svelte";
  import ShopGroupOrders from "./ShopGroupOrders.svelte";

  export let user: any;
  export let profile: any;

  let activeTab = "dashboard";
  let shopData: any = null;
  let loading = true;
  let announcements: any[] = [];

  // Persist Active Tab
  $: {
    if (typeof window !== "undefined" && activeTab) {
      localStorage.setItem("shop_active_tab", activeTab);
    }
  }

  $: menuItems = [
    { id: "dashboard", label: "Dashboard", icon: BarChart3, badge: null },
    {
      id: "menu",
      label: "Menu",
      icon: Utensils,
      badge: shopData?.total_menus || null,
    },
    {
      id: "orders",
      label: "Pesanan",
      icon: ShoppingBag,
      badge: null,
    },
    {
      id: "groups",
      label: "Group",
      icon: UsersIcon,
      badge: null,
    },
    { id: "settings", label: "Pengaturan", icon: Settings, badge: null },
  ];

  onMount(() => {
    // Restore Active Tab
    const savedTab = localStorage.getItem("shop_active_tab");
    if (savedTab && menuItems.some((item) => item.id === savedTab)) {
      activeTab = savedTab;
    }

    fetchShop();
    fetchAnnouncements();
  });

  async function fetchAnnouncements() {
    const { data } = await supabase
      .from("blog_posts")
      .select("*")
      .eq("status", "announcement")
      .order("created_at", { ascending: false })
      .limit(3);
    announcements = data || [];
  }

  async function fetchShop() {
    loading = true;
    const { data, error } = await supabase
      .from("shops")
      .select("*")
      .eq("owner_id", user.id)
      .single();

    if (error) {
      console.error("Error fetching shop:", error);
    } else {
      shopData = data;
    }
    loading = false;
  }

  async function handleLogout() {
    await supabase.auth.signOut();
  }

  async function handleShareShop() {
    const url = `${window.location.origin}/#/shop/${shopData.slug}`;
    try {
      if (navigator.share) {
        await navigator.share({
          title: shopData.name,
          text: "Ayo mampir ke toko saya di OrbFood!",
          url: url,
        });
      } else {
        await navigator.clipboard.writeText(url);
        const { toasts } = await import("../../stores/toastStore");
        toasts.success("Link toko berhasil disalin!");
      }
    } catch (err) {
      console.error("Error sharing:", err);
    }
  }
</script>

{#if loading}
  <div class="loading-wrap">
    <div class="spin"></div>
  </div>
{:else if !shopData}
  <div class="empty-wrap">
    <div class="emoji">🏪</div>
    <h1>Toko Tidak Ditemukan</h1>
    <p>
      Anda terdaftar sebagai pemilik toko, namun data toko tidak ditemukan.
    </p>
    <button on:click={handleLogout}>Keluar</button>
  </div>
{:else}
  <div class="shop-shell">
    <header class="topbar">
      <div class="brand">
        <div class="brand-logo">
          <img src="/logo-orb.png" alt="OrbFood" />
        </div>
        <span>OrbFood</span>
      </div>
      <div class="store-name">{shopData.name}</div>
      <div class="actions">
        <button on:click={handleShareShop} title="Bagikan toko">
          <Share2 size={16} />
        </button>
        <button on:click={handleLogout} title="Keluar">
          <LogOut size={16} />
        </button>
      </div>
    </header>

    <nav class="tabstrip">
      {#each menuItems as item}
        <button
          class:on={activeTab === item.id}
          on:click={() => (activeTab = item.id)}
        >
          <svelte:component this={item.icon} size={16} />
          <span>{item.label}</span>
          {#if item.badge}
            <small>{item.badge}</small>
          {/if}
        </button>
      {/each}
    </nav>

    <main class="page-content">
      {#if activeTab === "dashboard"}
        <section class="hero">
          <div class="hero-head">
            <div class="hero-icon">🏪</div>
            <div>
              <h2>{shopData.name}</h2>
              <p>
                {shopData.is_open ? "Status: Buka" : "Status: Tutup"} •
                {profile?.role || "shop"}
              </p>
            </div>
          </div>

          <div class="stats-row">
            <div class="stat-card">
              <div class="stat-val">{shopData.total_menus || 0}</div>
              <div class="stat-lbl">Total Menu</div>
            </div>
            <div class="stat-card">
              <div class="stat-val">{shopData.total_views || 0}</div>
              <div class="stat-lbl">Dilihat</div>
            </div>
            <div class="stat-card">
              <div class="stat-val">{(shopData.wa_taps || 0) + (shopData.maps_taps || 0)}</div>
              <div class="stat-lbl">Interaksi</div>
            </div>
          </div>
        </section>

        <section class="section">
          <div class="section-head">
            <h3>Informasi & Pengumuman</h3>
          </div>

          {#if announcements.length > 0}
            <div class="announce-list">
              {#each announcements as post}
                <article class="announce-card">
                  <div class="thumb">
                    <img src={post.cover_image || logo} alt="" />
                  </div>
                  <div class="body">
                    <div class="meta">
                      <span class="badge">Pengumuman</span>
                      <span class="date"
                        >{new Date(post.created_at).toLocaleDateString("id-ID", {
                          day: "numeric",
                          month: "short",
                        })}</span
                      >
                    </div>
                    <h4>{post.title}</h4>
                    <p>{post.excerpt || "Klik untuk lihat detail"}</p>
                  </div>
                </article>
              {/each}
            </div>
          {:else}
            <div class="announce-empty">
              Belum ada pengumuman terbaru.
            </div>
          {/if}
        </section>
      {:else if activeTab === "menu"}
        <section class="panel"><ShopMenus shopId={shopData.id} /></section>
      {:else if activeTab === "orders"}
        <section class="panel"><AdminOrders shopId={shopData.id} /></section>
      {:else if activeTab === "settings"}
        <section class="panel"><ShopSettings shopId={shopData.id} /></section>
      {:else if activeTab === "groups"}
        <section class="panel"><ShopGroupOrders shopId={shopData.id} /></section>
      {/if}
    </main>

    <nav class="bnav">
      {#each menuItems as item}
        <button
          class:on={activeTab === item.id}
          on:click={() => (activeTab = item.id)}
        >
          <svelte:component this={item.icon} size={18} />
          <span>{item.label}</span>
          {#if item.badge}
            <small>{item.badge}</small>
          {/if}
        </button>
      {/each}
    </nav>
  </div>
{/if}

<style>
  .shop-shell {
    --navy: #1c2b3a;
    --orange: #f97316;
    --bg: #f7f8fa;
    --surface: #ffffff;
    --line: #eceae6;
    --muted: #8896a4;

    min-height: 100vh;
    width: 100%;
    background: var(--bg);
    position: relative;
  }

  .topbar {
    position: sticky;
    top: 0;
    z-index: 40;
    height: 56px;
    background: var(--navy);
    display: grid;
    grid-template-columns: auto 1fr auto;
    align-items: center;
    gap: 10px;
    padding: 0 14px;
  }

  .tabstrip {
    display: none;
  }

  .brand {
    display: flex;
    align-items: center;
    gap: 7px;
    min-width: 0;
  }

  .brand-logo {
    width: 26px;
    height: 26px;
    border-radius: 999px;
    overflow: hidden;
    flex-shrink: 0;
  }

  .brand-logo img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    transform: scale(1.35);
  }

  .brand span {
    color: white;
    font-weight: 800;
    font-size: 16px;
    letter-spacing: -0.02em;
  }

  .store-name {
    font-size: 12px;
    color: rgba(255, 255, 255, 0.75);
    font-weight: 700;
    text-align: center;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .actions {
    display: flex;
    align-items: center;
    gap: 6px;
  }

  .actions button {
    width: 32px;
    height: 32px;
    border-radius: 999px;
    display: grid;
    place-items: center;
    color: rgba(255, 255, 255, 0.9);
    background: rgba(255, 255, 255, 0.1);
  }

  .page-content {
    padding-bottom: calc(74px + env(safe-area-inset-bottom));
    width: 100%;
  }

  .hero {
    background: var(--navy);
    padding: 18px 14px 20px;
  }

  .hero-head {
    display: flex;
    gap: 10px;
    align-items: center;
    margin-bottom: 16px;
  }

  .hero-icon {
    width: 46px;
    height: 46px;
    border-radius: 12px;
    background: rgba(255, 255, 255, 0.12);
    display: grid;
    place-items: center;
    font-size: 22px;
  }

  .hero h2 {
    color: white;
    margin: 0;
    font-size: 18px;
    font-weight: 800;
    line-height: 1.1;
  }

  .hero p {
    margin: 2px 0 0;
    font-size: 12px;
    color: rgba(255, 255, 255, 0.68);
    font-weight: 600;
  }

  .stats-row {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 8px;
  }

  .stat-card {
    background: rgba(255, 255, 255, 0.09);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 12px;
    padding: 10px 8px;
    text-align: center;
  }

  .stat-val {
    color: white;
    font-size: 20px;
    font-weight: 800;
    line-height: 1;
    margin-bottom: 2px;
  }

  .stat-lbl {
    font-size: 10px;
    color: rgba(255, 255, 255, 0.55);
    font-weight: 700;
    text-transform: uppercase;
  }

  .section {
    padding: 14px;
  }

  .section-head {
    margin-bottom: 10px;
  }

  .section-head h3 {
    margin: 0;
    font-size: 14px;
    font-weight: 800;
    color: #243447;
  }

  .announce-list {
    display: grid;
    gap: 10px;
  }

  .announce-card {
    background: var(--surface);
    border-radius: 14px;
    border: 1px solid var(--line);
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
    overflow: hidden;
    display: flex;
    gap: 10px;
    padding: 10px;
  }

  .thumb {
    width: 58px;
    height: 58px;
    border-radius: 10px;
    overflow: hidden;
    flex-shrink: 0;
    background: #fff7ed;
  }

  .thumb img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }

  .body {
    min-width: 0;
  }

  .meta {
    display: flex;
    gap: 8px;
    align-items: center;
    margin-bottom: 3px;
  }

  .badge {
    font-size: 9px;
    font-weight: 800;
    color: #ea6c0a;
    background: #fff7ed;
    border: 1px solid rgba(249, 115, 22, 0.25);
    border-radius: 999px;
    padding: 2px 7px;
    text-transform: uppercase;
  }

  .date {
    font-size: 10px;
    color: var(--muted);
    font-weight: 700;
  }

  .body h4 {
    margin: 0;
    font-size: 13px;
    font-weight: 800;
    color: #1c2b3a;
    line-height: 1.2;
  }

  .body p {
    margin: 3px 0 0;
    font-size: 11px;
    color: #6b7280;
    line-height: 1.4;
  }

  .announce-empty {
    background: #fff7ed;
    border: 1px solid rgba(249, 115, 22, 0.2);
    border-radius: 12px;
    padding: 12px;
    color: #ea6c0a;
    font-size: 12px;
    font-weight: 700;
    text-align: center;
  }

  .panel {
    padding: 14px;
  }

  .bnav {
    position: fixed;
    left: 50%;
    transform: translateX(-50%);
    bottom: 0;
    width: 100%;
    height: calc(66px + env(safe-area-inset-bottom));
    padding-bottom: env(safe-area-inset-bottom);
    background: var(--navy);
    display: grid;
    grid-template-columns: repeat(5, minmax(0, 1fr));
    z-index: 60;
  }

  .bnav button {
    color: rgba(255, 255, 255, 0.45);
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 3px;
    position: relative;
  }

  .bnav button.on {
    color: white;
  }

  .bnav button.on :global(svg) {
    color: var(--orange);
  }

  .bnav span {
    font-size: 9px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.03em;
  }

  .bnav small {
    position: absolute;
    top: 7px;
    right: 16px;
    font-size: 9px;
    line-height: 1;
    background: var(--orange);
    color: white;
    border-radius: 999px;
    min-width: 14px;
    height: 14px;
    padding: 2px 4px;
    display: grid;
    place-items: center;
    font-weight: 800;
  }

  .loading-wrap,
  .empty-wrap {
    min-height: 100vh;
    display: grid;
    place-items: center;
    background: #f7f8fa;
    padding: 24px;
    text-align: center;
  }

  .spin {
    width: 46px;
    height: 46px;
    border: 4px solid rgba(28, 43, 58, 0.15);
    border-top-color: #f97316;
    border-radius: 999px;
    animation: spin 1s linear infinite;
  }

  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }

  .empty-wrap .emoji {
    font-size: 42px;
    margin-bottom: 8px;
  }

  .empty-wrap h1 {
    margin: 0;
    font-size: 20px;
    color: #111827;
  }

  .empty-wrap p {
    margin: 8px 0 18px;
    color: #6b7280;
    max-width: 300px;
  }

  .empty-wrap button {
    background: #1c2b3a;
    color: white;
    padding: 10px 16px;
    border-radius: 10px;
    font-weight: 700;
  }

  @media (min-width: 1024px) {
    .topbar {
      position: sticky;
      top: 0;
      height: 62px;
      padding: 0 22px;
    }

    .tabstrip {
      position: sticky;
      top: 62px;
      z-index: 35;
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 10px 22px;
      background: #fff;
      border-bottom: 1px solid var(--line);
      overflow-x: auto;
    }

    .tabstrip button {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      padding: 8px 12px;
      border-radius: 999px;
      border: 1px solid #e5e7eb;
      background: #fff;
      color: #4b5563;
      font-size: 12px;
      font-weight: 700;
      white-space: nowrap;
      position: relative;
    }

    .tabstrip button.on {
      background: rgba(249, 115, 22, 0.1);
      color: #ea6c0a;
      border-color: rgba(249, 115, 22, 0.3);
    }

    .tabstrip button small {
      background: #ea6c0a;
      color: #fff;
      border-radius: 999px;
      min-width: 14px;
      height: 14px;
      font-size: 9px;
      display: grid;
      place-items: center;
      padding: 2px 4px;
      line-height: 1;
    }

    .page-content {
      max-width: 1280px;
      margin: 0 auto;
      padding: 16px 22px 28px;
    }

    .hero {
      border-radius: 18px;
      margin-bottom: 16px;
    }

    .section,
    .panel {
      padding: 0;
    }

    .announce-list {
      grid-template-columns: repeat(2, minmax(0, 1fr));
    }

    .bnav {
      display: none;
    }
  }
</style>
