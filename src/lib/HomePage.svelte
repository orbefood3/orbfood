<script lang="ts">
  import StoreCard from './StoreCard.svelte';

  export let onStoreSelect: (store: any) => void;

  const categories = ["Semua", "Nasi", "Minuman", "Cemilan", "Pedas", "Manis"];
  const stores = [
    { name: "Sate Kambing Bang Kumis", status: "Buka", location: "Jl. Merdeka No. 123", priceRange: "Rp 20k - 60k", image: "https://picsum.photos/seed/sate/400/200" },
    { name: "Es Teh Manis Jumbo", status: "Buka", location: "Jl. Sudirman No. 45", priceRange: "Rp 5k - 15k", image: "https://picsum.photos/seed/drink/400/200" },
    { name: "Bakso Granat", status: "Tutup", location: "Gg. Mawar No. 7", priceRange: "Rp 15k - 30k", image: "https://picsum.photos/seed/bakso/400/200" },
  ];
</script>

<div class="home-page">
  <div class="header-sticky sticky-top bg-primary shadow-soft">
    <div class="search-container">
      <input type="text" placeholder="Cari toko atau makanan..." class="search-input" />
    </div>
  </div>

  <main class="content">
    <section class="categories-tab">
      {#each categories as category}
        <button class="category-chip">{category}</button>
      {/each}
    </section>

    <section class="store-list">
      {#each stores as store}
        <StoreCard {store} onSelect={onStoreSelect} />
      {/each}
    </section>
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

  .content {
    padding: 16px;
  }

  .categories-tab {
    display: flex;
    overflow-x: auto;
    gap: 8px;
    margin-bottom: 24px;
    padding-bottom: 4px;
  }

  .categories-tab::-webkit-scrollbar {
    display: none;
  }

  .category-chip {
    white-space: nowrap;
    padding: 8px 16px;
    border-radius: 20px;
    background: var(--bg-soft);
    color: var(--text-muted);
    font-size: 14px;
    font-weight: 500;
  }

  .category-chip:first-child {
    background: var(--accent);
    color: white;
  }

  .store-list {
    display: flex;
    flex-direction: column;
  }
</style>
