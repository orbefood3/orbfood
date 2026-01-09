<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase } from '../../services/supabase';

  let menus: any[] = [];
  let loading = true;

  onMount(fetchMenus);

  async function fetchMenus() {
    loading = true;
    const { data } = await supabase
      .from('menu_items')
      .select('*, shops(name)')
      .order('created_at', { ascending: false });
    menus = data || [];
    loading = false;
  }

  async function toggleMenuStatus(menu: any) {
    const newStatus = !menu.is_available;
    const { error } = await supabase
      .from('menu_items')
      .update({ is_available: newStatus })
      .eq('id', menu.id);
    
    if (error) {
      alert("Error updating status: " + error.message);
    } else {
      fetchMenus();
    }
  }

  async function deleteMenu(menu: any) {
    if (!confirm(`Hapus menu ${menu.name}? Tindakan ini permanen.`)) return;
    
    const { error } = await supabase
      .from('menu_items')
      .delete()
      .eq('id', menu.id);
    
    if (error) {
      alert("Error deleting menu: " + error.message);
    } else {
      fetchMenus();
    }
  }
</script>

<div class="p-6">
  <h2 class="text-2xl font-bold mb-6">🍔 Semua Menu</h2>

  {#if loading}
    <p>Memuat menu...</p>
  {:else}
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      {#each menus as menu}
        <div class="menu-card bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex gap-4 items-center">
          <div class="w-16 h-16 bg-gray-100 rounded-lg overflow-hidden flex-shrink-0">
            {#if menu.image_url}
              <img src={menu.image_url} alt={menu.name} class="w-full h-full object-cover" />
            {:else}
              <div class="w-full h-full flex items-center justify-center text-gray-400">🍔</div>
            {/if}
          </div>
          <div class="flex-1">
            <h3 class="font-bold">{menu.name}</h3>
            <p class="text-xs text-gray-500">{menu.shops?.name}</p>
            <p class="text-sm font-bold text-accent">Rp{menu.price.toLocaleString()}</p>
          </div>
          <div class="flex flex-col gap-2">
            <button 
              on:click={() => toggleMenuStatus(menu)}
              class="text-[10px] font-bold px-2 py-1 rounded {menu.is_available ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}"
            >
              {menu.is_available ? 'Sembunyikan' : 'Tampilkan'}
            </button>
            <button 
              on:click={() => deleteMenu(menu)}
              class="text-[10px] font-bold px-2 py-1 rounded bg-gray-100 text-gray-600 hover:bg-red-50 hover:text-red-600"
            >
              Hapus
            </button>
          </div>
        </div>
      {/each}
    </div>
  {/if}
</div>
