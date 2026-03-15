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
        <div class="cart-meta">
          <span class="cart-label">Keranjang Aktif</span>
          <span class="cart-text"
            >{$cartCount} Item • Rp {$cartTotal.toLocaleString()}</span
          >
        </div>
      </div>
      <button class="view-cart-btn" on:click={onViewCart}>
        Lihat Keranjang
      </button>
    </div>
  </div>
{/if}

<style>
  .cart-bar {
    padding: 10px 12px;
    background: transparent;
    pointer-events: none;
    margin-bottom: calc(env(safe-area-inset-bottom, 0px));
  }

  .cart-summary {
    pointer-events: auto;
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12px 12px;
    border-radius: 16px;
    color: white;
    border: 1px solid rgba(255, 255, 255, 0.08);
    box-shadow:
      0 14px 24px -16px rgba(15, 42, 68, 0.9),
      0 8px 20px -16px rgba(15, 42, 68, 0.8);
  }

  .cart-info {
    display: flex;
    align-items: center;
    gap: 10px;
  }

  .cart-icon {
    font-size: 18px;
  }

  .cart-meta {
    display: flex;
    flex-direction: column;
    line-height: 1.15;
  }

  .cart-label {
    font-size: 10px;
    font-weight: 700;
    opacity: 0.8;
    letter-spacing: 0.3px;
    text-transform: uppercase;
  }

  .cart-text {
    font-size: 13px;
    font-weight: 800;
  }

  .view-cart-btn {
    background: var(--accent);
    color: white;
    font-weight: 800;
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 0.3px;
    padding: 9px 12px;
    border-radius: 11px;
    box-shadow: 0 10px 16px -12px rgba(249, 115, 22, 0.9);
  }
</style>
