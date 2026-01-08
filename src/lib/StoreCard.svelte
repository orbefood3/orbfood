<script lang="ts">
  export let store = {
    name: "Toko Enak",
    status: "Buka",
    priceRange: "Rp 15k - 50k",
    image: "https://picsum.photos/seed/food1/400/200"
  };
  export let onSelect: (store: any) => void;
</script>

<!-- svelte-ignore a11y-click-events-have-key-events -->
<div class="store-card rounded-lg shadow-soft" on:click={() => onSelect(store)}>
  <img src={store.image} alt={store.name} class="store-image" />
  <div class="store-info">
    <div class="store-header">
      <h3 class="store-name">{store.name}</h3>
      <span class="status-badge {store.status === 'Buka' ? 'open' : 'closed'}">
        {store.status === 'Buka' ? '🟢 Buka' : '🔴 Tutup'}
      </span>
    </div>
    <p class="store-price">{store.priceRange}</p>
    <button class="view-menu-btn bg-accent">Lihat Menu</button>
  </div>
</div>

<style>
  .store-card {
    background: var(--bg-white);
    margin-bottom: 20px;
    overflow: hidden;
    border: 1px solid var(--bg-soft);
  }

  .store-image {
    width: 100%;
    height: 160px;
    object-fit: cover;
  }

  .store-info {
    padding: 16px;
  }

  .store-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 4px;
  }

  .store-name {
    margin: 0;
    font-size: 18px;
    font-weight: 600;
    color: var(--text-main);
  }

  .status-badge {
    font-size: 12px;
    font-weight: 500;
  }

  .store-price {
    margin: 0 0 12px 0;
    font-size: 14px;
    color: var(--text-muted);
  }

  .view-menu-btn {
    width: 100%;
    padding: 10px;
    border-radius: 8px;
    font-weight: 600;
    color: white;
  }
</style>
