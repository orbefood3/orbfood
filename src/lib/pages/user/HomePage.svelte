<script lang="ts">
  import { onMount } from "svelte";
  import { supabase } from "../../services/supabase";
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
  let selectedVillageId = "";
  let loading = true;
  let showVillageModal = false;

  onMount(async () => {
    loading = true;

    // Fetch Villages
    const { data: vData } = await supabase
      .from("villages")
      .select("*")
      .order("name");
    villages = vData || [];

    // Fetch All Menu Items with Shops
    const { data: menuData } = await supabase
      .from("menu_items")
      .select("*, shops(*)")
      .eq("is_available", true);

    allMenuData = (menuData || []).map((m) => ({
      ...m,
      shop: m.shops,
    }));

    // Fetch All Stores
    const { data: storeData } = await supabase
      .from("shops")
      .select("*, villages(name)")
      .eq("is_active", true)
      .eq("is_verified", true);

    allStores = storeData || [];
    loading = false;
  });

  // Filter Logic
  $: filteredMenus = allMenuData.filter((m) => {
    const matchSearch =
      searchQuery.trim() === "" ||
      m.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      m.shop?.name.toLowerCase().includes(searchQuery.toLowerCase());
    const matchVillage =
      selectedVillageId === "" || m.shop?.village_id === selectedVillageId;
    return matchSearch && matchVillage;
  });

  $: filteredStores = allStores.filter((s) => {
    const matchSearch =
      searchQuery.trim() === "" ||
      s.name.toLowerCase().includes(searchQuery.toLowerCase());
    const matchVillage =
      selectedVillageId === "" || s.village_id === selectedVillageId;
    return matchSearch && matchVillage;
  });

  $: recommendedItems = filteredMenus.slice(0, 10);
  $: otherMenus = filteredMenus.slice(10, 20);

  $: filteredVillages = villages.filter((v) =>
    v.name.toLowerCase().includes(villageSearchQuery.toLowerCase()),
  );

  $: selectedVillageName =
    villages.find((v) => v.id === selectedVillageId)?.name || "Semua Desa";

  // Navigation Visiblity dispatching via custom events for App.svelte or global state
  let lastScrollTop = 0;
  function handleScroll(e: any) {
    const currentScrollTop = e.target.scrollTop;
    if (currentScrollTop > lastScrollTop && currentScrollTop > 100) {
      // Scrolling down
      window.dispatchEvent(new CustomEvent("hide-nav"));
    } else {
      // Scrolling up
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
            <span class="text-white/60 text-[10px] font-bold">Pesan Antar</span>
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
    {:else if searchQuery.trim() === "" && selectedVillageId === ""}
      <!-- Recommendations Grid -->
      <section class="mb-8">
        <h2 class="text-lg font-black text-gray-900 mb-4 px-1">
          Rekomendasi Menu
        </h2>
        <div class="grid grid-cols-2 gap-4">
          {#each recommendedItems as item}
            <PortraitMenuCard
              {item}
              onNavigate={() => onStoreSelect(item.shop)}
            />
          {/each}
        </div>
      </section>

      <!-- Other Menus -->
      <section>
        <h2 class="text-lg font-black text-gray-900 mb-4 px-1">Menu Lainnya</h2>
        <div class="flex flex-col gap-4">
          {#each otherMenus as item}
            <MenuCard {item} onNavigate={() => onStoreSelect(item.shop)} />
          {/each}
        </div>
      </section>
    {:else}
      <!-- Search Results Grid -->
      <section class="mb-8">
        <h2 class="text-lg font-black text-gray-900 mb-4 px-1">
          Hasil Pencarian Toko
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
        <h2 class="text-lg font-black text-gray-900 mb-4 px-1">Hasil Menu</h2>
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
            on:click={() => {
              selectedVillageId = "";
              showVillageModal = false;
              villageSearchQuery = "";
            }}
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
              on:click={() => {
                selectedVillageId = village.id;
                showVillageModal = false;
                villageSearchQuery = "";
              }}
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
