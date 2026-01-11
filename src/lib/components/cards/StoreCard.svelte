<script lang="ts">
  import { getOptimizedImageUrl } from "../../services/cloudinary";
  export let store: any;
  export let onSelect: (store: any) => void;
</script>

<!-- svelte-ignore a11y-click-events-have-key-events -->
<div
  class="store-card shadow-soft rounded-lg"
  on:click={() => onSelect(store)}
  role="button"
  tabindex="0"
  on:keydown={(e) => {
    if (e.key === "Enter" || e.key === " ") onSelect(store);
  }}
>
  <div class="relative h-40">
    <img
      src={getOptimizedImageUrl(store.banner_url || store.image || "", 600)}
      alt={store.name}
      class="store-image"
    />
    <div
      class="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent"
    ></div>

    <!-- Logo Overlay -->
    <div
      class="absolute -bottom-4 left-4 w-12 h-12 rounded-xl bg-white p-1 shadow-lg border border-gray-100 overflow-hidden"
    >
      <img
        src={getOptimizedImageUrl(store.logo_url || store.image || "", 100)}
        alt="Logo"
        class="w-full h-full object-cover rounded-lg"
      />
    </div>
  </div>

  <div class="store-info mt-2">
    <div class="store-header">
      <h3 class="store-name">{store.name}</h3>
      <span class="status-badge {store.is_open ? 'open' : 'closed'}">
        {store.is_open ? "🟢 Buka" : "🔴 Tutup"}
      </span>
    </div>
    <div class="flex items-center gap-2 mb-3">
      <span
        class="text-[10px] bg-primary/10 text-primary px-2 py-0.5 rounded font-bold uppercase"
        >{store.category}</span
      >
      {#if store.villages?.name}
        <span class="text-[10px] text-gray-400 font-medium"
          >📍 {store.villages.name}</span
        >
      {/if}
    </div>
    <button class="view-menu-btn bg-primary text-white">Lihat Menu</button>
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
