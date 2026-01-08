<script lang="ts">
  import MenuCard from './MenuCard.svelte';
  import CartBar from './CartBar.svelte';

  export let store = {
    name: "Sate Kambing Bang Kumis",
    status: "Buka",
    location: "Jl. Merdeka No. 123",
    image: "https://picsum.photos/seed/sate/400/200"
  };
  export let onBack: () => void;

  let menuItems = [
    { id: 1, name: "Sate Kambing (10 Tusuk)", price: 45000, description: "Sate kambing muda dengan bumbu kacang/kecap.", image: "https://picsum.photos/seed/sate/200/200" },
    { id: 2, name: "Gulai Kambing", price: 35000, description: "Kuah gulai kental dengan daging kambing empuk.", image: "https://picsum.photos/seed/gulai/200/200" },
    { id: 3, name: "Nasi Putih", price: 5000, description: "Nasi putih hangat.", image: "https://picsum.photos/seed/rice/200/200" },
    { id: 4, name: "Es Teh Manis", price: 5000, description: "Es teh manis segar.", image: "https://picsum.photos/seed/tea/200/200" },
  ];

  let cart: any[] = [];
  $: cartCount = cart.reduce((acc, item) => acc + (item.quantity || 1), 0);
  $: cartTotal = cart.reduce((acc, item) => acc + (item.price * (item.quantity || 1)), 0);

  function addToCart(item: any) {
    const existing = cart.find(i => i.id === item.id);
    if (existing) {
      existing.quantity = (existing.quantity || 1) + 1;
      cart = [...cart];
    } else {
      cart = [...cart, { ...item, quantity: 1 }];
    }
  }

  function handleViewCart() {
    alert("Checkout via WhatsApp akan muncul di sini!");
  }
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
      <MenuCard {item} onAdd={addToCart} />
    {/each}
  </main>

  <CartBar {cartCount} {cartTotal} onViewCart={handleViewCart} />
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
