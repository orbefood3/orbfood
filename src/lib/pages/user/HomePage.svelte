<script lang="ts">
  import { onMount } from "svelte";
  import { supabase } from "../../services/supabase";
  import { villagesCache, shopsCache } from "../../stores/cacheStore";
  import StoreCard from "../../components/cards/StoreCard.svelte";
  import PortraitMenuCard from "../../components/cards/PortraitMenuCard.svelte";
  import MenuCard from "../../components/cards/MenuCard.svelte";
  import { MapPin, Search, ChevronDown, Check, X } from "lucide-svelte";
  import logo from "../../../assets/logo-orb.png";

  export let onStoreSelect: (store: any) => void;

  let searchQuery = "";
  let villageSearchQuery = "";
  let allMenuData: any[] = [];
  let allStores: any[] = [];
  let villages: any[] = [];
  let selectedVillageId =
    typeof localStorage !== "undefined"
      ? localStorage.getItem("orb_selected_village") || ""
      : "";
  let loading = true;
  let loadingMore = false;
  let showVillageModal = false;

  // Pagination
  let menuPage = 0;
  const menuPageSize = 12; // Smaller initial batch
  let hasMoreMenus = true;

  onMount(async () => {
    loading = true;
    try {
      // Try to get villages from cache first
      const cachedVillages = villagesCache.get();
      if (cachedVillages) {
        villages = cachedVillages;
      } else {
        // Fetch Villages from Supabase
        const { data: vData } = await supabase
          .from("villages")
          .select("*")
          .order("name");
        villages = vData || [];
        villagesCache.set(villages);
      }

      // Try to get shops from cache first
      const cachedShops = shopsCache.get();
      if (cachedShops) {
        allStores = cachedShops;
      } else {
        // Fetch All Stores with villages from Supabase
        const { data: storeData } = await supabase
          .from("shops")
          .select("*")
          .eq("is_active", true)
          .eq("is_verified", true);

        // Manual fetch villages for shops if needed, or just skip if name not strictly required for IDs
        // Simplification: remove villages(name) dependency for stability

        allStores = storeData || [];
        shopsCache.set(allStores);
      }

      // Initial Menu Fetch
      await fetchNextPage(true);
    } catch (e) {
      console.error("HomePage mount error:", e);
    } finally {
      loading = false;
    }
  });

  // Debounce search
  let searchTimeout: any;
  $: {
    if (searchQuery !== undefined) {
      clearTimeout(searchTimeout);
      searchTimeout = setTimeout(() => {
        fetchNextPage(true, true); // Reset and search mode
      }, 500);
    }
  }

  async function fetchNextPage(reset = false, isSearch = false) {
    if ((!hasMoreMenus && !reset) || (loadingMore && !isSearch)) return;

    const currentQ = searchQuery.trim();

    if (reset) {
      menuPage = 0;
      allMenuData = [];
      hasMoreMenus = true;
    }

    loadingMore = true;
    const from = menuPage * menuPageSize;
    const to = from + menuPageSize - 1;

    let query = supabase
      .from("menu_items")
      .select("*")
      .eq("is_available", true);

    if (currentQ) {
      query = query.ilike("name", `%${currentQ}%`);
    }

    // Global Filter: Only show menus from active and verified shops
    const activeShopIds = allStores.map((s) => s.id);

    if (activeShopIds.length === 0) {
      allMenuData = [];
      hasMoreMenus = false;
      loadingMore = false;
      return;
    }

    if (selectedVillageId) {
      const villageShopIds = allStores
        .filter((s) => s.village_id === selectedVillageId)
        .map((s) => s.id);

      if (villageShopIds.length > 0) {
        query = query.in("shop_id", villageShopIds);
      } else {
        // If no active shops in village, don't show any menus
        allMenuData = [];
        hasMoreMenus = false;
        loadingMore = false;
        return;
      }
    } else {
      // No village selected: show menus from ALL active shops
      query = query.in("shop_id", activeShopIds);
    }

    // Sort: Featured first if keyword matches, otherwise new
    if (!currentQ) {
      query = query.order("created_at", { ascending: false });
    }

    const { data: menuData, error } = await query.range(from, to);

    if (error) {
      console.error("Error fetching menu:", error);
    } else {
      let items = menuData || [];

      // Manually fetch shops to avoid join issues
      if (items.length > 0) {
        const shopIds = [
          ...new Set(items.map((i) => i.shop_id).filter(Boolean)),
        ];
        if (shopIds.length > 0) {
          const { data: shops } = await supabase
            .from("shops")
            .select("*")
            .in("id", shopIds);

          const shopMap = (shops || []).reduce((acc: any, shop: any) => {
            acc[shop.id] = shop;
            return acc;
          }, {});

          items = items.map((item) => ({
            ...item,
            shops: shopMap[item.shop_id] || null,
            shop: shopMap[item.shop_id] || null, // Handle both potential usages
          }));
        }
      }

      if (reset) {
        allMenuData = items;
      } else {
        // Filter out duplicates if needed
        const existingIds = new Set(allMenuData.map((m) => m.id));
        const uniqueNewMenus = items.filter((m) => !existingIds.has(m.id));
        allMenuData = [...allMenuData, ...uniqueNewMenus];
      }

      hasMoreMenus = (menuData || []).length === menuPageSize;
      if (hasMoreMenus) menuPage++;
    }

    loadingMore = false;
  }

  function updateVillageFilter(id: string) {
    selectedVillageId = id;
    if (typeof localStorage !== "undefined") {
      localStorage.setItem("orb_selected_village", id);
    }
    showVillageModal = false;
    villageSearchQuery = "";
    fetchNextPage(true); // Reset menus for new village
  }

  // Reactive Declarations
  $: filteredMenus = allMenuData; // Now handled by server query

  $: filteredStores = allStores.filter((s) => {
    // Client-side search for stores is fine as list is usually small
    const matchSearch =
      searchQuery.trim() === "" ||
      s.name.toLowerCase().includes(searchQuery.toLowerCase());
    const matchVillage =
      selectedVillageId === "" || s.village_id === selectedVillageId;
    return matchSearch && matchVillage;
  });

  // Helper Functions
  function seededShuffle(array: any[], seed: number) {
    let m = array.length,
      t,
      i;
    let currSeed = seed;
    const shuffled = [...array];
    while (m) {
      const x = Math.sin(currSeed++) * 10000;
      const r = x - Math.floor(x);
      i = Math.floor(r * m--);
      t = shuffled[m];
      shuffled[m] = shuffled[i];
      shuffled[i] = t;
    }
    return shuffled;
  }

  function getDayOfYear() {
    const today = new Date();
    return Math.floor(
      (today.getTime() - new Date(today.getFullYear(), 0, 0).getTime()) /
        86400000,
    );
  }

  $: recommendedShops = (() => {
    if (selectedVillageId === "") {
      // Global Recommendation
      return [...allStores]
        .sort(
          (a, b) =>
            (b.wa_taps || 0) +
            (b.maps_taps || 0) -
            ((a.wa_taps || 0) + (a.maps_taps || 0)),
        )
        .slice(0, 8);
    } else {
      // Village Recommendation
      const villageShops = allStores.filter(
        (s) => s.village_id === selectedVillageId,
      );
      return seededShuffle(villageShops, getDayOfYear()).slice(0, 8);
    }
  })();

  $: otherMenus = filteredMenus;

  $: filteredVillages = villages.filter((v) =>
    v.name.toLowerCase().includes(villageSearchQuery.toLowerCase()),
  );

  $: selectedVillageName =
    villages.find((v) => v.id === selectedVillageId)?.name || "Semua Desa";

  // Navigation Visibility
  let lastScrollTop = 0;
  function handleScroll(e: any) {
    const currentScrollTop = e.target.scrollTop;
    const scrollHeight = e.target.scrollHeight;
    const clientHeight = e.target.clientHeight;

    // Load more when 200px from bottom
    if (
      scrollHeight - currentScrollTop - clientHeight < 200 &&
      hasMoreMenus &&
      !loadingMore &&
      searchQuery.trim() === ""
    ) {
      fetchNextPage();
    }

    if (currentScrollTop > lastScrollTop && currentScrollTop > 100) {
      window.dispatchEvent(new CustomEvent("hide-nav"));
    } else {
      window.dispatchEvent(new CustomEvent("show-nav"));
    }
    lastScrollTop = currentScrollTop;
  }

  function handleTouch() {
    window.dispatchEvent(new CustomEvent("show-nav"));
  }
</script>

<!-- svelte-ignore a11y-click-events-have-key-events -->
<!-- svelte-ignore a11y-no-static-element-interactions -->
<div class="home-page" on:touchstart={handleTouch}>
  <header
    class="header-sticky sticky top-0 z-40 bg-primary px-4 pt-4 pb-4 shadow-sm"
  >
    <div class="flex flex-col gap-4">
      <!-- Top Bar: Logo & Location -->
      <div class="flex items-center justify-between gap-4">
        <div class="flex items-center gap-2">
          <div
            class="w-10 h-10 bg-white rounded-full p-0 shadow-sm overflow-hidden flex items-center justify-center"
          >
            <img
              src={logo}
              alt="OrbFood"
              class="w-full h-full object-cover scale-150"
            />
          </div>
          <div class="flex flex-col">
            <span
              class="text-white text-base font-black leading-none uppercase tracking-tight"
              >OrbFood</span
            >
          </div>
        </div>

        <!-- Village Filter -->
        <button
          on:click={() => (showVillageModal = true)}
          class="flex items-center gap-2 bg-white/10 text-white px-3 py-2 rounded-xl text-[10px] font-bold transition-all active:scale-95 text-left border border-white/5 max-w-[150px]"
        >
          <MapPin size={14} />
          <span class="flex-1 truncate">{selectedVillageName}</span>
          <ChevronDown size={12} class="opacity-60" />
        </button>
      </div>

      <!-- Search Bar -->
      <div class="relative">
        <span class="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400">
          <Search size={18} />
        </span>
        <input
          type="text"
          bind:value={searchQuery}
          placeholder="Cari toko atau makanan..."
          class="w-full pl-12 pr-4 py-3 rounded-2xl bg-white border-none text-gray-900 text-sm outline-none shadow-sm font-medium"
        />
      </div>
    </div>
  </header>

  <main class="content p-4 pb-32" on:scroll={handleScroll}>
    {#if loading}
      <div class="space-y-8">
        <div class="grid grid-cols-2 gap-3">
          <div class="h-48 bg-gray-100 rounded-2xl animate-pulse"></div>
          <div class="h-48 bg-gray-100 rounded-2xl animate-pulse"></div>
        </div>
        <div class="space-y-4">
          <div class="h-24 bg-gray-100 rounded-2xl animate-pulse"></div>
          <div class="h-24 bg-gray-100 rounded-2xl animate-pulse"></div>
        </div>
      </div>
    {:else if searchQuery.trim() !== ""}
      <!-- Search Results View -->
      <section class="mb-8">
        <h2 class="text-lg font-black text-gray-900 mb-4 px-1">
          Toko Ditemukan
        </h2>
        <div class="flex flex-col gap-4">
          {#each filteredStores as store}
            <StoreCard {store} onSelect={onStoreSelect} />
          {/each}
        </div>
        {#if filteredStores.length === 0}
          <div class="py-12 text-center text-gray-400 font-bold">
            Toko tidak ditemukan
          </div>
        {/if}
      </section>

      <section>
        <h2 class="text-lg font-black text-gray-900 mb-4 px-1">
          Menu Ditemukan
        </h2>
        <div class="flex flex-col gap-4">
          {#each filteredMenus as item}
            <MenuCard {item} onNavigate={() => onStoreSelect(item.shop)} />
          {/each}
        </div>
        {#if filteredMenus.length === 0}
          <div class="py-12 text-center text-gray-400 font-bold">
            Menu tidak ditemukan
          </div>
        {/if}
      </section>
    {:else}
      <!-- Default View (Recommendations & Others) -->
      <section class="mb-8">
        <h2 class="text-lg font-black text-gray-900 mb-4 px-1">
          Rekomendasi Toko
        </h2>
        <div class="flex gap-4 overflow-x-auto no-scrollbar pb-2">
          {#each recommendedShops as store}
            <PortraitMenuCard
              item={store}
              onNavigate={() => onStoreSelect(store)}
            />
          {/each}
        </div>
        {#if recommendedShops.length === 0}
          <div class="py-10 text-center text-gray-400 font-bold">
            Belum ada rekomendasi di desa ini
          </div>
        {/if}
      </section>

      <section>
        <h2 class="text-lg font-black text-gray-900 mb-4 px-1">Menu Lainnya</h2>
        <div class="flex flex-col gap-4">
          {#each otherMenus as item}
            <MenuCard {item} onNavigate={() => onStoreSelect(item.shop)} />
          {/each}
        </div>

        {#if loadingMore}
          <div class="py-6 flex justify-center">
            <div
              class="w-6 h-6 border-2 border-primary border-t-transparent rounded-full animate-spin"
            ></div>
          </div>
        {:else if !hasMoreMenus && otherMenus.length > 0}
          <div
            class="py-8 text-center text-gray-400 text-xs font-medium italic"
          >
            Sudah menampilkan semua menu ✨
          </div>
        {/if}
      </section>
    {/if}
  </main>

  <!-- Village Selection Modal -->
  {#if showVillageModal}
    <div class="fixed inset-0 z-[100] flex items-end justify-center">
      <div
        class="absolute inset-0 bg-gray-900/60 backdrop-blur-sm"
        on:click={() => (showVillageModal = false)}
      ></div>
      <div
        class="relative bg-white w-full max-w-2xl rounded-t-[2.5rem] shadow-2xl p-6 overflow-hidden animate-in slide-in-from-bottom duration-300"
      >
        <div class="flex items-center justify-between mb-6">
          <h3 class="text-xl font-black text-gray-900">Pilih Lokasi Desa</h3>
          <button
            on:click={() => (showVillageModal = false)}
            class="p-2 bg-gray-100 rounded-full"
          >
            <X size={20} class="text-gray-500" />
          </button>
        </div>

        <!-- Village Search -->
        <div class="mb-4 relative">
          <span class="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400">
            <Search size={16} />
          </span>
          <input
            type="text"
            bind:value={villageSearchQuery}
            placeholder="Cari nama desa..."
            class="w-full pl-11 pr-4 py-2.5 rounded-xl bg-gray-100 border-none text-gray-900 text-sm outline-none font-medium"
          />
        </div>

        <div class="space-y-2 max-h-[50vh] overflow-y-auto no-scrollbar pb-10">
          <button
            on:click={() => updateVillageFilter("")}
            class="w-full flex items-center justify-between p-4 rounded-2xl {selectedVillageId ===
            ''
              ? 'bg-primary/5 text-primary'
              : 'bg-gray-50 text-gray-700'}"
          >
            <span class="font-bold">Semua Desa</span>
            {#if selectedVillageId === ""}
              <Check size={18} strokeWidth={3} />
            {/if}
          </button>

          {#each filteredVillages as village}
            <button
              on:click={() => updateVillageFilter(village.id)}
              class="w-full flex items-center justify-between p-4 rounded-2xl {selectedVillageId ===
              village.id
                ? 'bg-primary/5 text-primary'
                : 'bg-gray-50 text-gray-700'}"
            >
              <span class="font-bold">{village.name}</span>
              {#if selectedVillageId === village.id}
                <Check size={18} strokeWidth={3} />
              {/if}
            </button>
          {/each}

          {#if filteredVillages.length === 0}
            <div class="py-10 text-center text-gray-400 text-sm font-medium">
              Desa tidak ditemukan
            </div>
          {/if}
        </div>
      </div>
    </div>
  {/if}
</div>

<style>
  .home-page {
    height: 100%;
    overflow: hidden;
    display: flex;
    flex-direction: column;
  }

  .content {
    flex: 1;
    overflow-y: auto;
    -webkit-overflow-scrolling: touch;
  }

  .no-scrollbar::-webkit-scrollbar {
    display: none;
  }
  .no-scrollbar {
    -ms-overflow-style: none;
    scrollbar-width: none;
  }
</style>
