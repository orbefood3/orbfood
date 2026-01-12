<script lang="ts">
  import { onMount } from "svelte";
  import { supabase } from "../../services/supabase";
  import { toasts } from "../../stores/toastStore";
  import AdminOrders from "./AdminOrders.svelte";
  import LoadingSpinner from "../../components/ui/LoadingSpinner.svelte";
  import PageWrapper from "../../components/ui/PageWrapper.svelte";
  import EmptyState from "../../components/ui/EmptyState.svelte";
  import {
    Eye,
    Power,
    Trash2,
    Search,
    ChevronLeft,
    ChevronRight,
    X,
  } from "lucide-svelte";

  let shops: any[] = [];
  let loading = true;
  let searchQuery = "";
  let currentPage = 1;
  let itemsPerPage = 10;
  let totalItems = 0;
  let searchTimeout: any;

  // Detail Modal State
  let showDetailModal = false;
  let selectedShop: any = null;

  onMount(fetchShops);

  async function fetchShops() {
    loading = true;

    // Calculate range
    const from = (currentPage - 1) * itemsPerPage;
    const to = from + itemsPerPage - 1;

    let query = supabase
      .from("shops")
      .select("*, user_profiles!inner(display_name)", { count: "exact" })
      .eq("is_verified", true)
      .order("created_at", { ascending: false })
      .range(from, to);

    if (searchQuery) {
      query = query.ilike("name", `%${searchQuery}%`);
    }

    const { data, count, error } = await query;

    if (error) {
      console.error("Error fetching shops:", error);
    } else {
      shops = data || [];
      totalItems = count || 0;
    }
    loading = false;
  }

  function handleSearchInput() {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(() => {
      currentPage = 1;
      fetchShops();
    }, 500); // Debounce 500ms
  }

  function changePage(step: number) {
    currentPage += step;
    fetchShops();
  }

  async function toggleShopStatus(shop: any) {
    const newStatus = !shop.is_active;
    const { error } = await supabase
      .from("shops")
      .update({ is_active: newStatus })
      .eq("id", shop.id);

    if (error) {
      toasts.error("Gagal mengupdate status: " + error.message);
    } else {
      toasts.success(
        `Toko berhasil di-${newStatus ? "aktifkan" : "nonaktifkan"}`,
      );
      // Optimistic update
      shops = shops.map((s) =>
        s.id === shop.id ? { ...s, is_active: newStatus } : s,
      );
    }
  }

  async function deleteShop(shop: any) {
    if (
      !confirm(
        `Apakah anda yakin ingin menghapus toko "${shop.name}"? Aksi ini tidak dapat dibatalkan.`,
      )
    ) {
      return;
    }

    const { error } = await supabase.from("shops").delete().eq("id", shop.id);

    if (error) {
      toasts.error("Gagal menghapus toko: " + error.message);
    } else {
      toasts.success("Toko berhasil dihapus");
      fetchShops();
    }
  }

  function openShopDetail(shop: any) {
    selectedShop = shop;
    showDetailModal = true;
  }

  function closeDetailModal() {
    showDetailModal = false;
    selectedShop = null;
  }

  $: totalPages = Math.ceil(totalItems / itemsPerPage);
</script>

<PageWrapper>
  <!-- Search Bar -->
  <div class="mb-6 flex justify-between items-center">
    <div
      class="relative w-full md:w-96 bg-white rounded-lg border border-gray-200 flex items-center px-3 py-2"
    >
      <Search size={18} class="text-gray-400 mr-2" />
      <input
        type="text"
        bind:value={searchQuery}
        on:input={handleSearchInput}
        placeholder="Cari toko..."
        class="w-full bg-transparent outline-none text-sm"
      />
    </div>

    <div class="text-sm text-gray-500">
      Total: {totalItems} Toko
    </div>
  </div>

  {#if loading}
    <div class="flex justify-center p-12">
      <LoadingSpinner />
    </div>
  {:else if shops.length === 0}
    <EmptyState
      message={searchQuery
        ? "Tidak ada toko yang cocok dengan pencarian."
        : "Belum ada toko aktif."}
      icon="🏪"
    />
  {:else}
    <div
      class="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden overflow-x-auto"
    >
      <table class="w-full text-left border-collapse min-w-[800px]">
        <thead class="bg-gray-50/50 border-b border-gray-100">
          <tr>
            <th
              class="p-4 text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >Nama Toko</th
            >
            <th
              class="p-4 text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >Pemilik</th
            >
            <th
              class="p-4 text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >Status</th
            >
            <th
              class="p-4 text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >Keaktifan</th
            >
            <th
              class="p-4 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right"
              >Aksi</th
            >
          </tr>
        </thead>
        <tbody>
          {#each shops as shop}
            <tr
              class="hover:bg-gray-50/50 transition-colors border-b last:border-0 border-gray-50"
            >
              <td class="p-4">
                <div class="font-medium text-gray-900">{shop.name}</div>
                <div class="text-xs text-gray-500 mt-0.5">
                  {shop.address || "-"}
                </div>
              </td>
              <td class="p-4 text-sm text-gray-600">
                {shop.user_profiles?.display_name || "N/A"}
              </td>
              <td class="p-4">
                <span
                  class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800"
                >
                  Verified
                </span>
              </td>
              <td class="p-4">
                <button
                  on:click={() => toggleShopStatus(shop)}
                  class="group flex items-center gap-2 text-sm transition-colors py-1 px-2 rounded hover:bg-gray-100"
                  title={shop.is_active ? "Nonaktifkan Toko" : "Aktifkan Toko"}
                >
                  <Power
                    size={16}
                    class={shop.is_active ? "text-green-600" : "text-gray-400"}
                  />
                  <span
                    class="{shop.is_active
                      ? 'text-gray-900'
                      : 'text-gray-500'} text-xs font-medium"
                  >
                    {shop.is_active ? "Aktif" : "Nonaktif"}
                  </span>
                </button>
              </td>
              <td class="p-4 text-right">
                <div class="flex items-center justify-end gap-1">
                  <!-- View Detail -->
                  <button
                    on:click={() => openShopDetail(shop)}
                    class="p-1.5 text-gray-500 hover:text-blue-600 hover:bg-blue-50 rounded-md transition-colors"
                    title="Lihat Detail"
                  >
                    <Eye size={18} />
                  </button>

                  <!-- Delete -->
                  <button
                    on:click={() => deleteShop(shop)}
                    class="p-1.5 text-gray-500 hover:text-red-600 hover:bg-red-50 rounded-md transition-colors"
                    title="Hapus Toko"
                  >
                    <Trash2 size={18} />
                  </button>
                </div>
              </td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>

    <!-- Pagination Controls -->
    <div
      class="mt-6 flex flex-col md:flex-row items-center justify-between gap-4 bg-gray-50/50 p-4 rounded-xl border border-gray-100"
    >
      <div class="text-sm text-gray-500">
        Menampilkan <span class="font-semibold text-gray-900"
          >{shops.length}</span
        >
        dari
        <span class="font-semibold text-gray-900">{totalItems}</span> toko
      </div>

      <div class="flex items-center gap-2">
        <button
          on:click={() => changePage(-1)}
          disabled={currentPage === 1 || loading}
          class="p-2 border border-gray-200 rounded-lg hover:bg-white disabled:opacity-50 disabled:cursor-not-allowed transition-all flex items-center gap-1 text-sm font-medium text-gray-700"
        >
          <ChevronLeft size={16} />
          Prev
        </button>

        <div class="flex items-center gap-1 px-4">
          <span class="text-sm font-medium text-gray-900"
            >Halaman {currentPage}</span
          >
          <span class="text-sm text-gray-400">dari {totalPages}</span>
        </div>

        <button
          on:click={() => changePage(1)}
          disabled={currentPage === totalPages || loading}
          class="p-2 border border-gray-200 rounded-lg hover:bg-white disabled:opacity-50 disabled:cursor-not-allowed transition-all flex items-center gap-1 text-sm font-medium text-gray-700"
        >
          Next
          <ChevronRight size={16} />
        </button>
      </div>
    </div>
  {/if}

  <!-- Detail Modal Side Panel -->
  {#if showDetailModal && selectedShop}
    <div class="fixed inset-0 z-50 flex justify-end">
      <!-- Backdrop -->
      <button
        class="absolute inset-0 bg-black/20 backdrop-blur-sm transition-opacity w-full h-full border-0 cursor-default"
        on:click={closeDetailModal}
        on:keydown={(e) => e.key === "Escape" && closeDetailModal()}
        aria-label="Close modal"
      ></button>

      <!-- Panel -->
      <div
        class="relative w-full max-w-2xl bg-white h-full shadow-2xl p-6 overflow-y-auto transform transition-transform duration-300 translate-x-0"
      >
        <div class="flex justify-between items-start mb-6">
          <div>
            <h2 class="text-2xl font-bold text-gray-900">
              {selectedShop.name}
            </h2>
            <p class="text-gray-500 text-sm mt-1">
              Detail Toko & Riwayat Pesanan
            </p>
          </div>
          <button
            on:click={closeDetailModal}
            class="p-2 hover:bg-gray-100 rounded-full text-gray-500 transition-colors"
          >
            <X size={20} />
          </button>
        </div>

        <div class="space-y-8">
          <!-- Info Section -->
          <div
            class="grid grid-cols-2 gap-4 bg-gray-50 p-4 rounded-xl border border-gray-100"
          >
            <div>
              <p
                class="text-xs text-gray-500 uppercase tracking-wider font-semibold mb-1"
              >
                Pemilik
              </p>
              <p class="font-medium text-gray-900">
                {selectedShop.user_profiles?.display_name || "-"}
              </p>
            </div>
            <div>
              <p
                class="text-xs text-gray-500 uppercase tracking-wider font-semibold mb-1"
              >
                Kontak
              </p>
              <p class="font-medium text-gray-900">
                {selectedShop.whatsapp || "-"}
              </p>
            </div>
            <div class="col-span-2">
              <p
                class="text-xs text-gray-500 uppercase tracking-wider font-semibold mb-1"
              >
                Alamat
              </p>
              <p class="font-medium text-gray-900">
                {selectedShop.address || "-"}
              </p>
            </div>
          </div>

          <!-- Orders Section -->
          <div>
            <h3
              class="text-lg font-bold text-gray-900 mb-4 flex items-center gap-2"
            >
              <span>📦</span> Pesanan Toko
            </h3>
            <AdminOrders shopId={selectedShop.id} />
          </div>
        </div>
      </div>
    </div>
  {/if}
</PageWrapper>

<style>
  /* Custom scrollbar for modal */
  div::-webkit-scrollbar {
    width: 6px;
  }
  div::-webkit-scrollbar-track {
    background: transparent;
  }
  div::-webkit-scrollbar-thumb {
    background-color: #cbd5e1;
    border-radius: 4px;
  }
</style>
