<script lang="ts">
  import { cartCount, cartTotal } from "../../stores/cartStore";
  export let onViewCart: () => void;
  export let isVisible: boolean = true;
</script>

{#if $cartCount > 0}
  <div
    class="cart-bar fixed bottom-0 left-0 right-0 z-50 shadow-soft transition-transform duration-300 {isVisible
      ? 'translate-y-0'
      : 'translate-y-24'}"
  >
    <div class="cart-summary bg-primary">
      <div class="cart-info">
        <span class="cart-icon">🛒</span>
        <span class="cart-text"
          >{$cartCount} Item | Rp {$cartTotal.toLocaleString()}</span
        >
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
