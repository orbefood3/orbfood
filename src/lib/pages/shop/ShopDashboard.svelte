<script lang="ts">
  import { supabase } from "../../services/supabase";
  import { onMount } from "svelte";
  import DashboardLayout from "../../components/layouts/DashboardLayout.svelte";
  import logo from "../../../assets/logo-orb.png";
  import ShopMenus from "./ShopMenus.svelte";
  import ShopSettings from "./ShopSettings.svelte";
  import { BarChart3, Utensils, Clock, Settings } from "lucide-svelte";
  import PlaceholderPage from "../user/PlaceholderPage.svelte";

  export let user: any;
  export let profile: any;

  let activeTab = "menu";
  let shopData: any = null;
  let loading = true;
  let sidebarOpen = false;

  $: menuItems = [
    { id: "dashboard", label: "Dashboard", icon: BarChart3, badge: null },
    {
      id: "menu",
      label: "Menu Saya",
      icon: Utensils,
      badge: shopData?.total_menus || null,
    },
    { id: "settings", label: "Pengaturan Toko", icon: Settings, badge: null },
  ];

  onMount(() => {
    fetchShop();
  });

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

    <div class="max-w-7xl mx-auto">
      {#if activeTab === "dashboard"}
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <div class="bg-white p-6 rounded-xl border border-gray-100 shadow-sm">
            <p class="text-sm font-medium text-gray-500 mb-1">Total Menu</p>
            <p class="text-3xl font-bold text-gray-900">
              {shopData.total_menus || 0}
            </p>
          </div>
          <div class="bg-white p-6 rounded-xl border border-gray-100 shadow-sm">
            <p class="text-sm font-medium text-gray-500 mb-1">Total Dilihat</p>
            <p class="text-3xl font-bold text-blue-600">
              {shopData.total_views || 0}
            </p>
          </div>
          <div class="bg-white p-6 rounded-xl border border-gray-100 shadow-sm">
            <p class="text-sm font-medium text-gray-500 mb-1">Rating</p>
            <div class="flex items-center gap-2">
              <p class="text-3xl font-bold text-yellow-500">
                {shopData.rating || 0}
              </p>
              <span class="text-sm text-gray-400">/ 5.0</span>
            </div>
          </div>
        </div>

        <div
          class="bg-blue-50 border border-blue-100 rounded-xl p-6 text-center"
        >
          <p class="text-blue-800 font-medium">
            ✨ Fitur Dashboard Lengkap Segera Hadir!
          </p>
          <p class="text-blue-600 text-sm mt-1">
            Pantau pesanan dan performa toko Anda di sini.
          </p>
        </div>
      {:else if activeTab === "menu"}
        <ShopMenus shopId={shopData.id} />
      {:else if activeTab === "settings"}
        <ShopSettings shopId={shopData.id} />
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
