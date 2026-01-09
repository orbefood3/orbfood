<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase } from '../../services/supabase';
  import MenuCard from '../../components/cards/MenuCard.svelte';
  import CartBar from '../../components/navigation/CartBar.svelte';
  import { addToCart } from '../../stores/cartStore';

  export let store: any;
  export let onBack: () => void;
  export let onViewCart: () => void;

  let menuItems: any[] = [];
  let loading = true;

  onMount(async () => {
    if (!store?.id) return;
    loading = true;
    const { data } = await supabase
      .from('menu_items')
      .select('*')
      .eq('shop_id', store.id)
      .eq('is_available', true);
    
    menuItems = data || [];
    loading = false;
  });
</script>

<div class="store-page">
  <div class="header sticky-top bg-primary">
    <button class="back-btn" on:click={onBack}>←</button>
    <h1 class="header-title">{store.name}</h1>
  </div>

  <div class="store-banner">
    <img src={store.image} alt={store.name} class="banner-image" />
    <div class="store-details">
      <h2>{store.name}</h2>
      <p class="location">📍 {store.location}</p>
      <span class="status-badge open">🟢 Buka</span>
    </div>
  </div>

  <main class="menu-list">
    <h3>Menu Unggulan</h3>
    {#each menuItems as item}
      <MenuCard {item} onAdd={() => addToCart(item)} />
    {/each}
  </main>

  <div class="bottom-spacer"></div>
  <CartBar {onViewCart} />
</div>

<style>
  .store-page {
    display: flex;
    flex-direction: column;
    flex: 1;
    background: var(--bg-soft);
  }

  .header {
    display: flex;
    align-items: center;
    padding: 12px 16px;
    color: white;
    gap: 16px;
  }

  .back-btn {
    background: none;
    color: white;
    font-size: 24px;
    padding: 0;
  }

  .header-title {
    margin: 0;
    font-size: 18px;
    font-weight: 600;
  }

  .store-banner {
    background: var(--bg-white);
    padding-bottom: 16px;
    box-shadow: 0 1px 2px rgba(0,0,0,0.05);
  }

  .banner-image {
    width: 100%;
    height: 180px;
    object-fit: cover;
  }

  .store-details {
    padding: 16px;
  }

  .store-details h2 {
    margin: 0 0 8px 0;
    font-size: 22px;
  }

  .location {
    margin: 0 0 8px 0;
    font-size: 14px;
    color: var(--text-muted);
  }

  .menu-list {
    padding: 16px;
  }

  .menu-list h3 {
    font-size: 18px;
    margin-bottom: 16px;
  }
</style>
