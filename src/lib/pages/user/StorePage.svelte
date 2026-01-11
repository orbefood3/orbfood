<script lang="ts">
  import { onMount, tick } from "svelte";
  import { supabase } from "../../services/supabase";
  import MenuCard from "../../components/cards/MenuCard.svelte";
  import CartBar from "../../components/navigation/CartBar.svelte";
  import { addToCart } from "../../stores/cartStore";
  import { getOptimizedImageUrl } from "../../services/cloudinary";
  import {
    MapPin,
    Instagram,
    Truck,
    MessageSquare,
    ChevronLeft,
    Clock,
    Info,
    Share2,
  } from "lucide-svelte";

  export let store: any;
  export let onBack: () => void;
  export let onViewCart: () => void;

  let menuItems: any[] = [];
  let loading = true;
  let fullStoreData: any = null;
  let isNavVisible = true;

  onMount(async () => {
    if (!store?.id) return;
    loading = true;

    const { data: storeData } = await supabase
      .from("shops")
      .select("*, villages(name)")
      .eq("id", store.id)
      .eq("is_active", true)
      .eq("is_verified", true)
      .single();

    if (!storeData) {
      fullStoreData = null;
      loading = false;
      return;
    }

    fullStoreData = storeData;

    const { data } = await supabase
      .from("menu_items")
      .select("*")
      .eq("shop_id", store.id)
      .eq("is_available", true);

    menuItems = data || [];
    loading = false;

    // Track shop view
    try {
      await supabase.rpc("increment_shop_views", { shop_uuid: store.id });
    } catch (e) {
      console.error("Failed to track shop view:", e);
    }
  });

  const daysLabels: Record<string, string> = {
    monday: "Senin",
    tuesday: "Selasa",
    wednesday: "Rabu",
    thursday: "Kamis",
    friday: "Jumat",
    saturday: "Sabtu",
    sunday: "Minggu",
  };

  function getOperatingHours(hours: any) {
    if (!hours || !hours.start_day) return "Jam tidak diatur";
    return `Buka: ${daysLabels[hours.start_day]} - ${daysLabels[hours.end_day]}, ${hours.open_time} - ${hours.close_time}`;
  }

  async function trackInteraction(type: "whatsapp" | "google_maps") {
    if (!store?.id) return;
    try {
      await supabase.rpc("increment_shop_interaction", {
        shop_id: store.id,
        interaction_type: type,
      });
    } catch (e) {
      console.error("Failed to track interaction:", e);
    }
  }

  // Scroll visibility logic
  let lastScrollTop = 0;
  function handleScroll(e: any) {
    const currentScrollTop = e.target.scrollTop;
    const scrollHeight = e.target.scrollHeight;
    const clientHeight = e.target.clientHeight;

    // Hide on scroll down, show on scroll up
    // Don't hide if near bottom (200px)
    if (scrollHeight - currentScrollTop - clientHeight < 200) {
      isNavVisible = true;
      window.dispatchEvent(new CustomEvent("show-nav"));
    } else if (currentScrollTop > lastScrollTop && currentScrollTop > 100) {
      isNavVisible = false;
      window.dispatchEvent(new CustomEvent("hide-nav"));
    } else {
      isNavVisible = true;
      window.dispatchEvent(new CustomEvent("show-nav"));
    }
    lastScrollTop = currentScrollTop;
  }

  function handleTouch() {
    isNavVisible = true;
    window.dispatchEvent(new CustomEvent("show-nav"));
  }

  async function handleShare() {
    const shareData = {
      title: `${store.name} - OrbFood`,
      text: `Lihat toko ${store.name} di OrbFood! ${fullStoreData?.description || ""}`,
      url: window.location.href,
    };

    try {
      if (navigator.share) {
        await navigator.share(shareData);
      } else {
        await navigator.clipboard.writeText(window.location.href);
        const { toasts } = await import("../../stores/toastStore");
        toasts.success("Link toko berhasil disalin ke clipboard!");
      }
    } catch (err) {
      console.error("Error sharing:", err);
    }
  }
</script>

<svelte:head>
  <title>{store.name} - OrbFood</title>
  <meta
    name="description"
    content={fullStoreData?.description ||
      `Pesan makanan dan minuman terbaik dari ${store.name} di OrbFood.`}
  />
  <meta property="og:title" content={`${store.name} - OrbFood`} />
  <meta
    property="og:description"
    content={fullStoreData?.description || `Cek menu lezat di ${store.name}!`}
  />
  {#if fullStoreData?.banner_url}
    <meta property="og:image" content={fullStoreData.banner_url} />
  {/if}
</svelte:head>

<!-- svelte-ignore a11y-click-events-have-key-events -->
<!-- svelte-ignore a11y-no-static-element-interactions -->
<div
  class="store-page bg-white h-screen flex flex-col overflow-hidden"
  on:touchstart={handleTouch}
>
  <!-- Fixed Navbar -->
  <header class="fixed top-0 left-0 right-0 z-50 bg-white shadow-sm">
    <div class="flex items-center justify-between px-4 py-3 max-w-2xl mx-auto">
      <div class="flex items-center gap-3">
        <button
          on:click={onBack}
          class="p-2 hover:bg-gray-100 rounded-full transition-all"
        >
          <ChevronLeft class="w-6 h-6 text-gray-900" />
        </button>
        <span class="text-sm font-bold text-gray-900 truncate max-w-[150px]"
          >{store.name}</span
        >
      </div>
      <button on:click={handleShare} class="p-2 hover:bg-gray-100 rounded-full">
        <Share2 class="w-5 h-5 text-gray-400" />
      </button>
    </div>
  </header>

  <main class="flex-1 overflow-y-auto pt-[60px]" on:scroll={handleScroll}>
    <div class="max-w-2xl mx-auto">
      <!-- Banner Section -->
      <div class="h-48 md:h-60 relative overflow-hidden">
        <img
          src={getOptimizedImageUrl(
            fullStoreData?.banner_url || store.image,
            800,
          )}
          alt={store.name}
          class="w-full h-full object-cover"
        />
        <div
          class="absolute inset-x-0 bottom-0 h-24 bg-gradient-to-t from-black/40 to-transparent"
        ></div>
      </div>

      <div class="px-4">
        {#if fullStoreData}
          <!-- Store Header Card -->
          <div
            class="relative z-10 -mt-10 bg-white rounded-3xl p-5 shadow-xl border border-gray-50 mb-6"
          >
            <div class="flex items-start gap-4 mb-4">
              <!-- Logo -->
              <div
                class="w-20 h-20 rounded-2xl bg-white p-1 shadow-lg border border-gray-50 flex-shrink-0"
              >
                <div
                  class="w-full h-full rounded-xl bg-gray-50 overflow-hidden"
                >
                  <img
                    src={getOptimizedImageUrl(
                      fullStoreData.logo_url || store.image,
                      200,
                    )}
                    alt="Logo"
                    class="w-full h-full object-cover"
                  />
                </div>
              </div>

              <div class="flex-1 pt-1">
                <h2 class="text-xl font-black text-gray-900 mb-1">
                  {store.name}
                </h2>
                <div class="flex items-center gap-2 text-xs">
                  <span class="flex items-center gap-1 text-primary font-bold">
                    <MapPin class="w-3 h-3" />
                    {fullStoreData.villages?.name || "Lokasi..."}
                  </span>
                  <span class="w-1 h-1 rounded-full bg-gray-300"></span>
                  <span class="text-gray-500">{fullStoreData.category}</span>
                </div>
              </div>

              {#if fullStoreData.is_open}
                <div
                  class="px-2 py-1 bg-green-50 text-green-600 rounded-lg text-[10px] font-black border border-green-100"
                >
                  BUKA
                </div>
              {:else}
                <div
                  class="px-2 py-1 bg-red-50 text-red-600 rounded-lg text-[10px] font-black border border-red-100"
                >
                  TUTUP
                </div>
              {/if}
            </div>

            <!-- Social & Map Links Bar -->
            <div
              class="flex items-center gap-4 py-3 border-y border-gray-50 justify-between"
            >
              <div class="flex items-center gap-4">
                {#if fullStoreData.instagram_url}
                  <a
                    href="https://instagram.com/{fullStoreData.instagram_url.replace(
                      '@',
                      '',
                    )}"
                    target="_blank"
                    class="flex items-center gap-1.5 text-xs font-bold text-gray-600 hover:text-pink-600 transition-all"
                  >
                    <Instagram class="w-4 h-4 text-pink-500" /> Instagram
                  </a>
                {/if}
                {#if fullStoreData.tiktok_url}
                  <a
                    href="https://tiktok.com/@{fullStoreData.tiktok_url.replace(
                      '@',
                      '',
                    )}"
                    target="_blank"
                    class="flex items-center gap-1.5 text-xs font-bold text-gray-600 hover:text-gray-900 transition-all"
                  >
                    <svg class="w-4 h-4 fill-current" viewBox="0 0 24 24"
                      ><path
                        d="M12.53.02C13.84 0 15.14.01 16.44 0c.08 1.53.63 3.09 1.75 4.17 1.12 1.11 2.7 1.62 4.24 1.79v4.03c-1.44-.05-2.89-.35-4.2-.97-.57-.26-1.1-.59-1.62-.93-.01 2.92.01 5.84-.02 8.75-.03 1.4-.54 2.79-1.35 3.94-1.31 1.92-3.58 3.17-5.91 3.21-1.43.08-2.86-.31-4.08-1.03-2.02-1.1-3.34-3.12-3.35-5.47-.03-2.31 1.24-4.52 3.25-5.64 1.23-.74 2.67-1.05 4.1-1.11.01 1.74.01 3.48.01 5.22-.51.01-1.02.13-1.48.34-.84.4-1.36 1.25-1.36 2.18.01.96.6 1.85 1.5 2.17.61.23 1.29.23 1.91-.01.81-.31 1.34-1.14 1.35-2.01.01-4.48.01-8.96.01-13.44.02-.01.02-.02.03-.02"
                      /></svg
                    >
                    TikTok
                  </a>
                {/if}
                {#if fullStoreData.google_maps_url}
                  <a
                    href={fullStoreData.google_maps_url}
                    target="_blank"
                    on:click={() => trackInteraction("google_maps")}
                    class="flex items-center gap-1.5 text-xs font-bold text-gray-600 hover:text-blue-600 transition-all"
                  >
                    <MapPin class="w-4 h-4 text-blue-500" /> Lokasi
                  </a>
                {/if}
              </div>

              <div
                class="flex items-center gap-1.5 text-xs font-bold {fullStoreData.is_delivery_available
                  ? 'text-blue-600'
                  : 'text-gray-400'}"
              >
                <Truck class="w-4 h-4" />
                {fullStoreData.is_delivery_available ? "Delivery" : "Takeaway"}
              </div>
            </div>

            <div class="pt-3 flex flex-col gap-1">
              <div
                class="flex items-center gap-2 text-[11px] font-bold text-gray-400"
              >
                <Clock class="w-3 h-3" />
                <span>{getOperatingHours(fullStoreData.business_hours)}</span>
              </div>
              <p
                class="text-xs text-gray-500 leading-relaxed line-clamp-2 mt-1"
              >
                {fullStoreData.description ||
                  "Selamat datang di toko kami! Kami menyediakan menu terbaik untuk Anda."}
              </p>
            </div>
          </div>

          <!-- Menus Grid -->
          <section class="mt-8 pb-32">
            <div class="flex items-center justify-between mb-4 px-2">
              <h3 class="text-lg font-black text-gray-900">Daftar Menu</h3>
              <span
                class="text-[10px] font-black bg-gray-100 text-gray-500 px-2 py-0.5 rounded-md"
                >{menuItems.length} ITEM</span
              >
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              {#each menuItems as item}
                <MenuCard {item} onAdd={() => addToCart(item)} />
              {/each}
            </div>

            {#if menuItems.length === 0}
              <div class="py-20 text-center">
                <Info class="w-12 h-12 text-gray-200 mx-auto mb-3" />
                <p class="text-gray-400 font-bold">Belum ada menu tersedia</p>
              </div>
            {/if}
          </section>

          <!-- Floating WA Button -->
          {#if fullStoreData.whatsapp}
            <a
              href="https://wa.me/62{fullStoreData.whatsapp.replace(/^0/, '')}"
              target="_blank"
              on:click={() => trackInteraction("whatsapp")}
              class="fixed bottom-32 right-6 z-40 bg-green-500 text-white p-4 rounded-3xl shadow-2xl hover:bg-green-600 transition-all active:scale-95 flex items-center gap-2 font-black text-sm {isNavVisible
                ? 'translate-y-0'
                : 'translate-y-24'} duration-300"
            >
              <MessageSquare class="w-6 h-6" />
              <span>Chat</span>
            </a>
          {/if}
        {:else}
          <!-- Shop Not Found / Inactive -->
          <div class="py-24 text-center px-6">
            <div
              class="w-20 h-20 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-6 text-3xl"
            >
              🚫
            </div>
            <h2 class="text-xl font-black text-gray-900 mb-2">
              Toko Tidak Ditemukan
            </h2>
            <p class="text-gray-500 text-sm mb-8">
              Toko ini mungkin sudah tidak aktif atau dalam proses verifikasi
              admin. Silakan cari toko lain yang tersedia.
            </p>
            <button
              on:click={onBack}
              class="px-8 py-3 bg-primary text-white rounded-2xl font-black text-sm shadow-lg shadow-primary/20 transition-all active:scale-95"
            >
              Kembali ke Beranda
            </button>
          </div>
        {/if}
      </div>
    </div>
  </main>

  <!-- Sticky Bottom Cart -->
  <footer class="fixed bottom-0 left-0 right-0 z-50">
    <CartBar {onViewCart} isVisible={isNavVisible} />
  </footer>
</div>

<style>
  :global(body) {
    overflow: hidden;
  }
</style>
