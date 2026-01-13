<script lang="ts">
  import { getOptimizedImageUrl } from "../../services/cloudinary";
  import { Truck } from "lucide-svelte";
  export let item: any;
  export let onNavigate: () => void;
</script>

<!-- svelte-ignore a11y-click-events-have-key-events -->
<!-- svelte-ignore a11y-no-static-element-interactions -->
<div
  class="portrait-card rounded-2xl shadow-soft transition-all active:scale-95 cursor-pointer overflow-hidden border-none flex flex-col {item.price !==
  undefined
    ? 'h-[180px]'
    : 'h-[155px]'} w-[140px] flex-shrink-0"
  on:click={onNavigate}
>
  <div class="image-container h-[100px] w-full relative">
    <img
      src={getOptimizedImageUrl(
        item.image || item.primary_image || item.logo_url || "",
        400,
      )}
      alt={item.name}
      class="menu-image w-full h-full object-cover"
    />
    {#if item.is_delivery_available}
      <div
        class="absolute top-2 right-2 p-1.5 bg-white/90 backdrop-blur-sm rounded-lg shadow-sm text-blue-600 animate-in zoom-in duration-300"
      >
        <Truck size={12} strokeWidth={3} />
      </div>
    {/if}
  </div>
  <div class="info p-2 flex flex-col justify-start flex-1 bg-white">
    <div>
      <h4 class="menu-name text-xs font-black text-gray-900 truncate">
        {item.name}
      </h4>
      <p class="shop-name text-[10px] text-gray-500 font-medium truncate">
        {item.villages?.name || item.shop?.name || item.shop || ""}
      </p>
    </div>
    {#if item.price !== undefined}
      <div class="footer mt-auto pt-1 border-t border-gray-50">
        <span class="price text-xs font-black text-primary"
          >Rp {item.price.toLocaleString()}</span
        >
      </div>
    {/if}
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
