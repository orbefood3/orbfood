<script lang="ts">
  import { onMount } from "svelte";
  import { supabase } from "../../services/supabase";
  import LoadingSpinner from "../../components/ui/LoadingSpinner.svelte";
  import PageWrapper from "../../components/ui/PageWrapper.svelte";

  let stats = {
    totalShops: 0,
    pendingShops: 0,
    totalMenus: 0,
    totalOrders: 0,
  };
  let loading = true;

  onMount(fetchStats);

  async function fetchStats() {
    loading = true;

    // Total Shops
    const { count: shopsCount } = await supabase
      .from("shops")
      .select("*", { count: "exact", head: true });

    // Pending Shops
    const { count: pendingCount } = await supabase
      .from("shops")
      .select("*", { count: "exact", head: true })
      .eq("is_verified", false);

    // Total Menus
    const { count: menusCount } = await supabase
      .from("menu_items")
      .select("*", { count: "exact", head: true });

    // Total Orders
    const { count: ordersCount } = await supabase
      .from("order_history")
      .select("*", { count: "exact", head: true });

    stats = {
      totalShops: shopsCount || 0,
      pendingShops: pendingCount || 0,
      totalMenus: menusCount || 0,
      totalOrders: ordersCount || 0,
    };

    loading = false;
  }
</script>

<PageWrapper>
  {#if loading}
    <LoadingSpinner />
  {:else}
    <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
      <!-- Total Toko -->
      <div class="rounded-xl border bg-white text-gray-950 shadow-sm">
        <div
          class="flex flex-row items-center justify-between space-y-0 p-6 pb-2"
        >
          <h3 class="tracking-tight text-sm font-medium">Total Toko</h3>
          <span class="text-gray-500">🏪</span>
        </div>
        <div class="p-6 pt-0">
          <div class="text-2xl font-bold">{stats.totalShops}</div>
          <p class="text-xs text-gray-500">Terdaftar di platform</p>
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
      <div class="rounded-xl border bg-white text-gray-950 shadow-sm">
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
