<script lang="ts">
  export let cartCount: number = 0;
  export let cartTotal: number = 0;
  export let onViewCart: () => void;
</script>

{#if cartCount > 0}
  <div class="cart-bar sticky-bottom shadow-soft">
    <div class="cart-summary bg-primary">
      <div class="cart-info">
        <span class="cart-icon">🛒</span>
        <span class="cart-text">{cartCount} Item | Rp {cartTotal.toLocaleString()}</span>
      </div>
      <button class="view-cart-btn" on:click={onViewCart}>
        Lihat Keranjang
      </button>
    </div>
  </div>
{/if}

<style>
  .cart-bar {
    padding: 12px 16px;
    background: transparent;
    pointer-events: none;
    margin-bottom: calc(env(safe-area-inset-bottom, 0px));
  }

  .cart-summary {
    pointer-events: auto;
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12px 16px;
    border-radius: 12px;
    color: white;
  }

  .cart-info {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .cart-text {
    font-size: 14px;
    font-weight: 600;
  }

  .view-cart-btn {
    background: none;
    color: white;
    font-weight: 700;
    font-size: 14px;
  }
</style>
