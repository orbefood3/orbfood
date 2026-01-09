<script lang="ts">
  import { addToCart } from '../../stores/cartStore';
  export let item: any;
  export let onNavigate: () => void;
</script>

<!-- svelte-ignore a11y-click-events-have-key-events -->
<div class="portrait-card rounded-lg shadow-soft" on:click={onNavigate} role="button" tabindex="0">
  <div class="image-container">
    <img src={item.image} alt={item.name} class="menu-image" />
  </div>
  <div class="info">
    <h4 class="menu-name">{item.name}</h4>
    <p class="shop-name">{item.shop?.name || item.shop}</p>
    <div class="footer">
      <span class="price">Rp {item.price.toLocaleString()}</span>
      <button class="add-btn bg-accent" on:click|stopPropagation={() => addToCart(item)}>
        + Tambah
      </button>
    </div>
  </div>
</div>

<style>
  .portrait-card {
    min-width: 160px;
    width: 160px;
    background: white;
    overflow: hidden;
    display: flex;
    flex-direction: column;
    border: 1px solid var(--bg-soft);
  }

  .image-container {
    height: 140px;
  }

  .menu-image {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }

  .info {
    padding: 10px;
    display: flex;
    flex-direction: column;
    gap: 2px;
  }

  .menu-name {
    margin: 0;
    font-size: 14px;
    font-weight: 700;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .shop-name {
    margin: 0;
    font-size: 11px;
    color: var(--text-hint);
  }

  .footer {
    margin-top: 8px;
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  .price {
    font-size: 14px;
    font-weight: 700;
    color: var(--text-main);
  }

  .add-btn {
    width: 100%;
    padding: 6px;
    border-radius: 6px;
    font-size: 12px;
    font-weight: 700;
    color: white;
  }
</style>
