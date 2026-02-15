<script lang="ts">
  import { supabase } from "../../services/supabase";
  import { onMount } from "svelte";
  import DashboardLayout from "../../components/layouts/DashboardLayout.svelte";
  import logo from "../../../assets/logo-orb.png";
  import ShopMenus from "./ShopMenus.svelte";
  import ShopSettings from "./ShopSettings.svelte";
  import {
    BarChart3,
    Utensils,
    Clock,
    Settings,
    ShoppingBag,
    Share2,
  } from "lucide-svelte";
  import PlaceholderPage from "../user/PlaceholderPage.svelte";
  import AdminOrders from "../admin/AdminOrders.svelte";
  import ShopGroupOrders from "./ShopGroupOrders.svelte";
  import { Users as UsersIcon } from "lucide-svelte";

  export let user: any;
  export let profile: any;

  let activeTab = "dashboard";
  let shopData: any = null;
  let loading = true;
  let sidebarOpen = false;
  let announcements: any[] = [];

  $: menuItems = [
    { id: "dashboard", label: "Dashboard", icon: BarChart3, badge: null },
    {
      id: "menu",
      label: "Menu Saya",
      icon: Utensils,
      badge: shopData?.total_menus || null,
    },
    {
      id: "orders",
      label: "Pesanan Masuk",
      icon: ShoppingBag,
      badge: null,
    },
    {
      id: "groups",
      label: "Group Order",
      icon: UsersIcon,
      badge: null,
    },
    { id: "settings", label: "Pengaturan Toko", icon: Settings, badge: null },
  ];

  onMount(() => {
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
          text: `Ayo mampir ke toko saya di OrbFood!`,
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
  <div class="flex items-center justify-center h-screen bg-gray-50">
    <div
      class="animate-spin w-12 h-12 border-4 border-primary border-t-transparent rounded-full"
    ></div>
  </div>
{:else if !shopData}
  <div
    class="flex flex-col items-center justify-center h-screen bg-gray-50 p-6 text-center"
  >
    <div class="bg-red-50 text-red-600 p-4 rounded-full mb-4">
      <span class="text-4xl">🏪</span>
    </div>
    <h1 class="text-2xl font-bold text-gray-900 mb-2">Toko Tidak Ditemukan</h1>
    <p class="text-gray-500 mb-6">
      Anda terdaftar sebagai pemilik toko, namun data toko tidak ditemukan.
    </p>
    <button
      on:click={handleLogout}
      class="px-6 py-2 bg-gray-900 text-white rounded-lg hover:bg-gray-800 transition-colors"
    >
      Keluar
    </button>
  </div>
{:else}
  <DashboardLayout
    title={shopData.name}
    {activeTab}
    {menuItems}
    {sidebarOpen}
    profile={{ ...profile, role: "Shop Owner" }}
    on:tabChange={(e) => (activeTab = e.detail)}
    on:logout={handleLogout}
    on:toggleSidebar={() => (sidebarOpen = !sidebarOpen)}
    on:closeSidebar={() => (sidebarOpen = false)}
  >
    <div
      slot="header-icon"
      class="w-full h-full flex items-center justify-center bg-white rounded-full overflow-hidden p-0 shadow-inner"
    >
      <img
        src={logo}
        alt="OrbFood Logo"
        class="w-full h-full object-cover scale-150"
      />
    </div>

    <button
      slot="header-actions"
      on:click={handleShareShop}
      class="p-2 bg-white/10 text-white rounded-lg hover:bg-white/20 transition-all active:scale-95"
      title="Bagikan Link Toko"
    >
      <Share2 class="w-4 h-4" />
    </button>

    <div class="max-w-7xl mx-auto">
      {#if activeTab === "dashboard"}
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <div
            class="bg-white p-6 rounded-xl border border-gray-100 shadow-sm transition-all hover:shadow-md"
          >
            <p
              class="text-xs font-bold text-gray-400 uppercase tracking-wider mb-1"
            >
              Total Menu
            </p>
            <p class="text-3xl font-black text-gray-900">
              {shopData.total_menus || 0}
            </p>
          </div>
          <div
            class="bg-white p-6 rounded-xl border border-gray-100 shadow-sm transition-all hover:shadow-md"
          >
            <p
              class="text-xs font-bold text-gray-400 uppercase tracking-wider mb-1"
            >
              Total Dilihat
            </p>
            <p class="text-3xl font-black text-blue-600">
              {shopData.total_views || 0}
            </p>
          </div>
          <div
            class="bg-white p-6 rounded-xl border border-gray-100 shadow-sm transition-all hover:shadow-md"
          >
            <p
              class="text-xs font-bold text-gray-400 uppercase tracking-wider mb-1"
            >
              Klik WhatsApp
            </p>
            <p class="text-3xl font-black text-green-600">
              {shopData.wa_taps || 0}
            </p>
          </div>
          <div
            class="bg-white p-6 rounded-xl border border-gray-100 shadow-sm transition-all hover:shadow-md"
          >
            <p
              class="text-xs font-bold text-gray-400 uppercase tracking-wider mb-1"
            >
              Klik Maps
            </p>
            <p class="text-3xl font-black text-orange-600">
              {shopData.maps_taps || 0}
            </p>
          </div>
        </div>

        <div class="space-y-6">
          <div class="flex items-center justify-between">
            <h3 class="text-lg font-bold text-gray-900">
              Informasi & Pengumuman
            </h3>
          </div>

          {#if announcements.length > 0}
            <div class="grid grid-cols-1 gap-4">
              {#each announcements as post}
                <div
                  class="bg-white p-4 rounded-xl border border-primary/10 shadow-sm flex gap-4 hover:border-primary/30 transition-colors"
                >
                  <div
                    class="w-16 h-16 rounded-lg bg-primary/5 flex-shrink-0 overflow-hidden"
                  >
                    <img
                      src={post.cover_image || logo}
                      alt=""
                      class="w-full h-full object-cover"
                    />
                  </div>
                  <div class="flex-1">
                    <div class="flex items-center gap-2 mb-1">
                      <span
                        class="text-[10px] font-bold bg-primary/10 text-primary px-1.5 py-0.5 rounded uppercase leading-none"
                        >PENGUMUMAN</span
                      >
                      <span class="text-[10px] text-gray-400 font-medium"
                        >{new Date(post.created_at).toLocaleDateString(
                          "id-ID",
                          { day: "numeric", month: "short" },
                        )}</span
                      >
                    </div>
                    <h4 class="text-sm font-bold text-gray-900 line-clamp-1">
                      {post.title}
                    </h4>
                    <p class="text-xs text-gray-500 mt-1 line-clamp-1">
                      {post.excerpt || "Klik untuk lihat detail"}
                    </p>
                  </div>
                </div>
              {/each}
            </div>
          {:else}
            <div
              class="bg-blue-50 border border-blue-100 rounded-xl p-6 text-center"
            >
              <p class="text-blue-800 font-medium">
                ✨ Belum ada pengumuman terbaru.
              </p>
              <p class="text-blue-600 text-sm mt-1">
                Kami akan memberitahu Anda di sini jika ada update!
              </p>
            </div>
          {/if}
        </div>
      {:else if activeTab === "menu"}
        <ShopMenus shopId={shopData.id} />
      {:else if activeTab === "orders"}
        <AdminOrders shopId={shopData.id} />
      {:else if activeTab === "settings"}
        <ShopSettings shopId={shopData.id} />
      {:else if activeTab === "groups"}
        <ShopGroupOrders shopId={shopData.id} />
      {:else}
        <div
          class="bg-white rounded-xl border border-gray-200 p-12 text-center"
        >
          <div
            class="inline-flex items-center justify-center w-16 h-16 rounded-full bg-gray-100 mb-4 text-3xl"
          >
            🚧
          </div>
          <h2 class="text-xl font-bold text-gray-900 mb-2">Segera Hadir</h2>
          <p class="text-gray-500">Fitur ini sedang dalam pengembangan.</p>
        </div>
      {/if}
    </div>
  </DashboardLayout>
{/if}
