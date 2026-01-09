<script lang="ts">
  import { getOptimizedImageUrl } from "../../services/cloudinary";
  export let item: {
    id: string | number;
    name: string;
    price: number;
    description: string;
    image?: string;
    primary_image?: string;
  }; // This might be 'primary_image' or 'image' depending on mapping
  export let onAdd: (item: any) => void;
</script>

<div class="menu-card shadow-soft rounded-lg">
  <div class="menu-info">
    <h4 class="menu-name">{item.name}</h4>
    <p class="menu-desc">{item.description}</p>
    <div class="menu-footer">
      <span class="menu-price">Rp {item.price.toLocaleString()}</span>
      <button class="add-btn bg-accent" on:click={() => onAdd(item)}
        >+ Tambah</button
      >
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
    padding: 12px;
    background: var(--bg-white);
    margin-bottom: 12px;
    gap: 12px;
    border: 1px solid var(--bg-soft);
  }

  .menu-info {
    flex: 1;
    display: flex;
    flex-direction: column;
  }

  .menu-name {
    margin: 0 0 4px 0;
    font-size: 16px;
    font-weight: 600;
  }

  .menu-desc {
    margin: 0 0 8px 0;
    font-size: 12px;
    color: var(--text-hint);
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }

  .menu-footer {
    margin-top: auto;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .menu-price {
    font-size: 14px;
    font-weight: 600;
    color: var(--text-main);
  }

  .add-btn {
    padding: 4px 12px;
    border-radius: 6px;
    font-size: 12px;
    font-weight: 600;
    color: white;
  }

  .menu-image {
    width: 80px;
    height: 80px;
    border-radius: 8px;
    object-fit: cover;
  }
</style>
