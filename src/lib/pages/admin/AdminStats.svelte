<script lang="ts">
  import { onMount } from "svelte";
  import { supabase } from "../../services/supabase";
  import LoadingSpinner from "../../components/ui/LoadingSpinner.svelte";
  import PageWrapper from "../../components/ui/PageWrapper.svelte";

  let stats = {
    totalShops: 0,
    activeShops: 0,
    pendingShops: 0,
    totalMenus: 0,
    totalOrders: 0,
    totalUsers: 0,
    totalInteractions: 0,
  };
  let loading = true;

  onMount(fetchStats);

  async function fetchStats() {
    loading = true;

    // Total Users
    const { count: usersCount } = await supabase
      .from("user_profiles")
      .select("*", { count: "exact", head: true });

    // Pending Shops
    const { count: pendingCount } = await supabase
      .from("shops")
      .select("*", { count: "exact", head: true })
      .eq("is_verified", false);

    // Active Shops
    const { count: activeCount } = await supabase
      .from("shops")
      .select("*", { count: "exact", head: true })
      .eq("is_verified", true);

    // Total Shops (All)
    const { count: shopsCount } = await supabase
      .from("shops")
      .select("*", { count: "exact", head: true });

    // Total Menus
    const { count: menusCount } = await supabase
      .from("menu_items")
      .select("*", { count: "exact", head: true });

    // Total Orders
    const { count: ordersCount } = await supabase
      .from("order_history")
      .select("*", { count: "exact", head: true });

    // Total Interactions (WA + Maps)
    const { data: shopsData } = await supabase
      .from("shops")
      .select("wa_taps, maps_taps");

    const totalInteractions = (shopsData || []).reduce(
      (acc, s) => acc + (s.wa_taps || 0) + (s.maps_taps || 0),
      0,
    );

    stats = {
      totalShops: shopsCount || 0,
      activeShops: activeCount || 0,
      pendingShops: pendingCount || 0,
      totalMenus: menusCount || 0,
      totalOrders: ordersCount || 0,
      totalUsers: usersCount || 0,
      totalInteractions,
    };

    loading = false;
  }
</script>

<PageWrapper>
  {#if loading}
    <LoadingSpinner />
  {:else}
    <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
      <!-- Total Pengguna -->
      <div class="rounded-xl border bg-white text-gray-950 shadow-sm">
        <div
          class="flex flex-row items-center justify-between space-y-0 p-6 pb-2"
        >
          <h3 class="tracking-tight text-sm font-medium">Total Pengguna</h3>
          <span class="text-gray-500">👥</span>
        </div>
        <div class="p-6 pt-0">
          <div class="text-2xl font-bold">{stats.totalUsers}</div>
          <p class="text-xs text-gray-500">Masyarakat terdaftar</p>
        </div>
      </div>

      <!-- Total Interaksi -->
      <div class="rounded-xl border bg-white text-gray-950 shadow-sm">
        <div
          class="flex flex-row items-center justify-between space-y-0 p-6 pb-2"
        >
          <h3 class="tracking-tight text-sm font-medium">
            Platform Engagement
          </h3>
          <span class="text-gray-500">⚡</span>
        </div>
        <div class="p-6 pt-0">
          <div class="text-2xl font-bold text-blue-600">
            {stats.totalInteractions}
          </div>
          <p class="text-xs text-gray-500">WA & G-Maps Clicks</p>
        </div>
      </div>

      <!-- Toko Aktif -->
      <div class="rounded-xl border bg-white text-gray-950 shadow-sm">
        <div
          class="flex flex-row items-center justify-between space-y-0 p-6 pb-2"
        >
          <h3 class="tracking-tight text-sm font-medium">Toko Aktif</h3>
          <span class="text-gray-500">✅</span>
        </div>
        <div class="p-6 pt-0">
          <div class="text-2xl font-bold text-green-600">
            {stats.activeShops}
          </div>
          <p class="text-xs text-gray-500">
            Dari total {stats.totalShops} toko
          </p>
        </div>
      </div>

      <!-- Menunggu Verifikasi -->
      <div class="rounded-xl border bg-white text-gray-950 shadow-sm">
        <div
          class="flex flex-row items-center justify-between space-y-0 p-6 pb-2"
        >
          <h3 class="tracking-tight text-sm font-medium">
            Menunggu Verifikasi
          </h3>
          <span class="text-gray-500">⏳</span>
        </div>
        <div class="p-6 pt-0">
          <div class="text-2xl font-bold text-orange-500">
            {stats.pendingShops}
          </div>
          <p class="text-xs text-gray-500">Perlu tindakan</p>
        </div>
      </div>

      <!-- Total Menu -->
      <div class="rounded-xl border bg-white text-gray-950 shadow-sm">
        <div
          class="flex flex-row items-center justify-between space-y-0 p-6 pb-2"
        >
          <h3 class="tracking-tight text-sm font-medium">Total Menu</h3>
          <span class="text-gray-500">🍽️</span>
        </div>
        <div class="p-6 pt-0">
          <div class="text-2xl font-bold">{stats.totalMenus}</div>
          <p class="text-xs text-gray-500">Item aktif</p>
        </div>
      </div>

      <!-- Total Pesanan -->
      <div
        class="rounded-xl border bg-white text-gray-950 shadow-sm col-span-1"
      >
        <div
          class="flex flex-row items-center justify-between space-y-0 p-6 pb-2"
        >
          <h3 class="tracking-tight text-sm font-medium">Total Pesanan</h3>
          <span class="text-gray-500">📦</span>
        </div>
        <div class="p-6 pt-0">
          <div class="text-2xl font-bold">{stats.totalOrders}</div>
          <p class="text-xs text-gray-500">Semua waktu</p>
        </div>
      </div>
    </div>
  {/if}
</PageWrapper>
