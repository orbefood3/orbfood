<script lang="ts">
  import { getOptimizedImageUrl } from "../../services/cloudinary";
  import { cart } from "../../stores/cartStore";
  import { Check } from "lucide-svelte";

  export let item: {
    id: string | number;
    name: string;
    price: number;
    description: string;
    image?: string;
    primary_image?: string;
  };
  export let onAdd: ((item: any) => void) | undefined = undefined;
  export let onNavigate: (() => void) | undefined = undefined;

  $: isInCart = $cart.some((i) => i.id === item.id);

  function handleClick() {
    if (onNavigate) {
      onNavigate();
    } else if (onAdd) {
      onAdd(item);
    }
  }
</script>

<!-- svelte-ignore a11y-click-events-have-key-events -->
<!-- svelte-ignore a11y-no-static-element-interactions -->
<div
  class="menu-card rounded-2xl transition-all duration-300 {isInCart
    ? 'is-selected'
    : 'is-default'}"
  on:click={handleClick}
  class:cursor-pointer={onNavigate || onAdd}
>
  <div class="menu-info">
    <div class="flex items-center justify-between mb-1">
      <h4 class="menu-name">{item.name}</h4>
      {#if isInCart}
        <div class="text-primary animate-in zoom-in">
          <Check size={18} strokeWidth={3} />
        </div>
      {/if}
    </div>
    <p class="menu-desc">{item.description}</p>
    <div class="menu-footer">
      <span class="menu-price">Rp {item.price.toLocaleString()}</span>
    </div>
  </div>
  <img
    src={getOptimizedImageUrl(item.image || item.primary_image || "", 150)}
    alt={item.name}
    class="menu-image"
    loading="lazy"
  />
</div>

<style>
  .menu-card {
    display: flex;
    padding: 16px;
    background: white;
    gap: 16px;
    border: none; /* Removed border as requested */
    box-shadow:
      0 4px 6px -1px rgba(0, 0, 0, 0.05),
      0 2px 4px -1px rgba(0, 0, 0, 0.03);
  }

  /* Glow effect when selected - Soft Orange Shadow */
  .is-selected {
    box-shadow:
      0 10px 25px -5px rgba(255, 126, 0, 0.4),
      0 8px 10px -6px rgba(255, 126, 0, 0.4);
    transform: translateY(-2px);
  }

  .is-default:active {
    transform: scale(0.98);
  }

  .menu-info {
    flex: 1;
    display: flex;
    flex-direction: column;
  }

  .menu-name {
    margin: 0;
    font-size: 16px;
    font-weight: 800;
    color: #1a1a1a;
    line-height: 1.2;
  }

  .menu-desc {
    margin: 4px 0 12px 0;
    font-size: 12px;
    color: #777;
    line-height: 1.5;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }

  .menu-footer {
    margin-top: auto;
    display: flex;
    align-items: center;
  }

  .menu-price {
    font-size: 15px;
    font-weight: 900;
    color: var(--primary);
  }

  .menu-image {
    width: 90px;
    height: 90px;
    border-radius: 16px;
    object-fit: cover;
  }
</style>
