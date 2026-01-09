<script lang="ts">
  import { getOptimizedImageUrl } from "../../services/cloudinary";
  export let item: any;
  export let onNavigate: () => void;
</script>

<!-- svelte-ignore a11y-click-events-have-key-events -->
<!-- svelte-ignore a11y-no-static-element-interactions -->
<div
  class="portrait-card rounded-2xl shadow-soft transition-all active:scale-95 cursor-pointer overflow-hidden border-none flex flex-col h-[200px] w-full"
  on:click={onNavigate}
>
  <div class="image-container h-[130px] w-full relative">
    <img
      src={getOptimizedImageUrl(item.image || item.primary_image || "", 400)}
      alt={item.name}
      class="menu-image w-full h-full object-cover"
    />
  </div>
  <div class="info p-2 flex flex-col justify-between flex-1 bg-white">
    <div>
      <h4 class="menu-name text-xs font-black text-gray-900 truncate">
        {item.name}
      </h4>
      <p class="shop-name text-[10px] text-gray-500 font-medium truncate">
        {item.shop?.name || item.shop}
      </p>
    </div>
    <div class="footer mt-auto pt-1 border-t border-gray-50">
      <span class="price text-xs font-black text-primary"
        >Rp {item.price.toLocaleString()}</span
      >
    </div>
  </div>
</div>

<style>
  .portrait-card {
    background: white;
  }

  .image-container {
    aspect-ratio: 4/3;
  }

  .menu-name {
    line-height: 1.2;
  }

  .shop-name {
    line-height: 1.2;
  }

  .price {
    line-height: 1;
  }
</style>
