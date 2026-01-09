<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase } from '../../services/supabase';
  import StoreCard from '../../components/cards/StoreCard.svelte';
  import PortraitMenuCard from '../../components/cards/PortraitMenuCard.svelte';
  import MenuCard from '../../components/cards/MenuCard.svelte';
  import { addToCart } from '../../stores/cartStore';

  export let onStoreSelect: (store: any) => void;

  let searchQuery = "";
  let recommendedItems: any[] = [];
  let menuList: any[] = [];
  let allStores: any[] = [];
  let loading = true;

  onMount(async () => {
    loading = true;
    
    // Fetch Recommended Menus (limit 10)
    const { data: menuData } = await supabase
      .from('menu_items')
      .select('*, shops(*)')
      .limit(10);
    
    recommendedItems = (menuData || []).map(m => ({
      ...m,
      shop: m.shops // Flatten for component compatibility
    }));

    // Fetch All Stores
    const { data: storeData } = await supabase
      .from('shops')
      .select('*')
      .eq('is_active', true)
      .eq('is_verified', true);
    
    allStores = storeData || [];
    
    // Use first few as "Other Menus"
    menuList = (menuData || []).slice(0, 5);
    
    loading = false;
  });

  $: filteredStores = searchQuery.trim() === "" 
    ? [] 
    : allStores.filter(s => s.name.toLowerCase().includes(searchQuery.toLowerCase()));

  $: filteredStores = searchQuery.trim() === "" 
    ? [] 
    : allStores.filter(s => s.name.toLowerCase().includes(searchQuery.toLowerCase()));
</script>

<div class="home-page">
  <div class="header-sticky sticky-top bg-primary shadow-soft">
    <div class="search-container">
      <input type="text" bind:value={searchQuery} placeholder="Cari toko atau makanan..." class="search-input" />
    </div>
    <button class="location-filter">
      <span class="loc-icon">📍</span>
      <span class="loc-text">Dikirim ke: <b>Pilih Lokasi...</b></span>
      <span class="loc-arrow">⌄</span>
    </button>
  </div>

  <main class="content">
    {#if searchQuery.trim() === ""}
      <section class="section">
        <div class="section-header">
          <h2 class="section-title">Rekomendasi Menu</h2>
        </div>
        <div class="slider horizontal-scroll no-scrollbar">
          {#each recommendedItems as item}
            <div class="slider-item">
              <PortraitMenuCard {item} onNavigate={() => onStoreSelect(item.shop)} />
            </div>
          {/each}
        </div>
      </section>

      <section class="section">
        <div class="section-header">
          <h2 class="section-title">Menu Lainnya</h2>
        </div>
        <div class="menu-list">
          {#each menuList as item}
            <MenuCard {item} onAdd={() => addToCart(item)} />
          {/each}
        </div>
      </section>
    {:else}
      <section class="section search-results">
        <div class="section-header">
          <h2 class="section-title">Hasil Pencarian Toko</h2>
        </div>
        <div class="store-list">
          {#if filteredStores.length > 0}
            {#each filteredStores as store}
              <StoreCard {store} onSelect={onStoreSelect} />
            {/each}
          {:else}
            <p class="empty-results">Toko tidak ditemukan.</p>
          {/if}
        </div>
      </section>
    {/if}
  </main>
</div>

<style>
  .home-page {
    display: flex;
    flex-direction: column;
    flex: 1;
  }

  .header-sticky {
    padding: 16px;
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .search-input {
    width: 100%;
    padding: 12px 16px;
    border-radius: 24px;
    border: none;
    background: var(--bg-white);
    font-size: 14px;
    outline: none;
  }

  .location-filter {
    display: flex;
    align-items: center;
    background: rgba(255,255,255,0.1);
    border: none;
    padding: 8px 16px;
    border-radius: 12px;
    color: white;
    font-size: 12px;
    gap: 8px;
    text-align: left;
  }

  .loc-icon {
    font-size: 16px;
  }

  .loc-text {
    flex: 1;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .loc-arrow {
    font-size: 16px;
    opacity: 0.7;
  }

  .content {
    padding: 16px;
    display: flex;
    flex-direction: column;
    gap: 28px;
  }

  .section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 12px;
  }

  .section-title {
    margin: 0;
    font-size: 18px;
    font-weight: 700;
  }

  .horizontal-scroll {
    display: flex;
    overflow-x: auto;
    gap: 12px;
    padding-bottom: 4px;
    scroll-snap-type: x mandatory;
    -webkit-overflow-scrolling: touch;
  }

  .no-scrollbar::-webkit-scrollbar {
    display: none;
  }

  .no-scrollbar {
    -ms-overflow-style: none;
    scrollbar-width: none;
  }

  .slider-item {
    flex: 0 0 auto;
    scroll-snap-align: start;
  }

  .menu-list, .store-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .empty-results {
    text-align: center;
    padding: 40px;
    color: var(--text-hint);
    font-size: 14px;
  }
</style>
