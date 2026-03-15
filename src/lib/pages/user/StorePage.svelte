<script lang="ts">
  import { onMount, tick } from "svelte";
  import { supabase } from "../../services/supabase";
  import MenuCard from "../../components/cards/MenuCard.svelte";
  import CartBar from "../../components/navigation/CartBar.svelte";
  import MenuDetailModal from "../../components/ui/MenuDetailModal.svelte";
  import ShopConflictModal from "../../components/ui/ShopConflictModal.svelte";
  import { addToCart, cart, clearCart } from "../../stores/cartStore";
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
    Users,
    Plus,
    Search,
  } from "lucide-svelte";
  
  import GroupOrderCard from "../../components/cards/GroupOrderCard.svelte";
  import CreateGroupModal from "../../components/modals/CreateGroupModal.svelte";
  import GroupOrderStickyFooter from "../../components/ui/GroupOrderStickyFooter.svelte";
  import JoinGroupModal from "../../components/modals/JoinGroupModal.svelte";
  import PaymentInfoModal from "../../components/modals/PaymentInfoModal.svelte";
  import { groupOrderStore } from "../../stores/groupOrderStore";
  import type {
    OrderRoom,
    GroupOrderParticipant,
  } from "../../types/groupOrder";

  export let store: any;
  export let onBack: () => void;
  export let onViewCart: () => void;
  export let editIndex: number | null = null;
  export let editItem: any = null;
  export let onCloseEdit: () => void;
  export let user: any = null;

  let menuItems: any[] = [];
  let loading = true;
  let fullStoreData: any = null;
  let isNavVisible = true;
  let showConflictModal = false;
  let showDetailModal = false;
  let selectedMenu: any = null;
  let pendingItem: any = null;
  let menuSearchQuery = "";

  // Group Order State
  // Group Order State
  let showCreateGroupModal = false;
  let showJoinGroupModal = false;
  let showPaymentInfoModal = false;
  let selectedGroupForJoin: any = null;
  let creatingGroup = false;
  let groupTotal = 0;
  let isCreator = false;

  $: activeGroupOrder = $groupOrderStore;
  $: if (activeGroupOrder && activeGroupOrder.store_id !== store?.id) {
    // If we are in a room for another store, clear it when we visit a different store?
    // Or warn user? For now, we assume user can only be in one context.
    // If they manually navigated here, we might want to keep the sticky footer but
    // maybe disable actions? Let's just keep it simple: if store mismatch, ignore active room visually
    // or clear it if they try to interact.
  }

  // If we are in a group matching this store, load my total
  $: if (activeGroupOrder && activeGroupOrder.store_id === store?.id && user) {
    fetchGroupTotal();
    isCreator = activeGroupOrder.creator_id === user.id;
  }

  // React to editIndex change from parent (App.svelte)
  $: if (editIndex !== null && editItem) {
    selectedMenu = editItem;
    showDetailModal = true;
  }

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

    // Group order initialization removed fetchActiveGroups - as we now use codes only
  });

  async function fetchGroupTotal() {
    if (!activeGroupOrder || !user) return;
    const { data } = await supabase
      .from("order_history")
      .select("total_price")
      .eq("order_room_id", activeGroupOrder.id)
      .eq("user_id", user.id);

    if (data) {
      groupTotal = data.reduce((sum, order) => sum + order.total_price, 0);
    }
  }

  async function handleJoinByCode(event: CustomEvent) {
    const code = event.detail.code;
    if (!code) return;

    try {
      const { data: room, error } = await supabase
        .from("order_rooms")
        .select("*, shops(*)")
        .eq("short_code", code.toUpperCase())
        .eq("status", "open")
        .single();

      if (error || !room) {
        alert("Kode grup tidak valid atau grup sudah selesai.");
        return;
      }

      if (room.store_id !== store.id) {
        alert("Kode ini untuk toko yang lain!");
        return;
      }

      groupOrderStore.setGroup(room);
      showJoinGroupModal = false;
      const { toasts } = await import("../../stores/toastStore");
      toasts.success(`Berhasil gabung ke grup: ${room.name}`);
    } catch (e) {
      console.error("Error joining group:", e);
    }
  }

  async function handleCreateGroupSubmit(event: CustomEvent) {
    creatingGroup = true;
    const { name, closingTime, openingTime } = event.detail;

    // Create group (payment info now comes from user profile)
    const { data, error } = await supabase
      .from("order_rooms")
      .insert({
        store_id: store.id,
        creator_id: user?.id,
        name: name,
        closing_time: closingTime,
        opening_time: openingTime || null,
        is_shop_managed: user?.id === store.owner_id,
        status: "open",
      })
      .select()
      .single();

    creatingGroup = false;
    showCreateGroupModal = false;

    if (error) {
      const { toasts } = await import("../../stores/toastStore");
      toasts.error("Gagal membuat grup. Pastikan anda login.");
      console.error("Group creation error:", error);
      return;
    }

    if (data) {
      groupOrderStore.setGroup(data);
      const { toasts } = await import("../../stores/toastStore");
      toasts.success("Kode Grup Berhasil Dibuat!");
    }
  }

  async function handleJoinGroup(group: any) {
    // Check if already in a different group
    if (activeGroupOrder && activeGroupOrder.id !== group.id) {
      const { toasts } = await import("../../stores/toastStore");
      toasts.error(
        "Anda sudah di grup lain. Keluar dulu untuk gabung grup baru.",
      );
      return;
    }

    // Simplified: Join group immediately and let them order.
    // They will see payment info and upload proof in the CART.
    groupOrderStore.setGroup(group);
    showJoinGroupModal = false;
    const { toasts } = await import("../../stores/toastStore");
    toasts.success(`Berhasil gabung grup ${group.name}`);
  }

  async function handlePaymentInfoProceed() {
    if (selectedGroupForJoin) {
      groupOrderStore.setGroup(selectedGroupForJoin);
      showPaymentInfoModal = false;

      const { toasts } = await import("../../stores/toastStore");
      toasts.success(`Bergabung ke: ${selectedGroupForJoin.name}`);

      fetchGroupTotal();
      selectedGroupForJoin = null;
    }
  }

  function handleLeaveGroup() {
    groupOrderStore.clearGroup();
    import("../../stores/toastStore").then(({ toasts }) => {
      toasts.info("Anda telah keluar dari grup");
    });
  }

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

  function handleAddToCart(item: any) {
    if ($cart.length > 0 && $cart[0].shop_id !== item.shop_id) {
      pendingItem = item;
      showConflictModal = true;
    } else {
      addToCart(item);
    }
  }

  function handleOpenDetail(item: any) {
    selectedMenu = item;
    showDetailModal = true;
  }

  function confirmStoreSwitch() {
    clearCart();
    if (pendingItem) {
      addToCart(pendingItem);
      pendingItem = null;
    }
    showConflictModal = false;
  }

  $: filteredMenuItems = menuItems.filter((item) => {
    if (!menuSearchQuery.trim()) return true;
    const q = menuSearchQuery.toLowerCase();
    return (
      item.name?.toLowerCase().includes(q) ||
      item.description?.toLowerCase().includes(q)
    );
  });
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
  <header class="fixed top-0 left-0 right-0 z-50 px-3 py-2">
    <div
      class="bg-white/40 backdrop-blur-[30px] border border-white/20 rounded-2xl px-2.5 py-2 flex items-center gap-2 shadow-[0_8px_32px_0_rgba(31,38,135,0.07)] max-w-2xl mx-auto transition-all"
    >
      <button
        on:click={onBack}
        class="w-9 h-9 rounded-full bg-white/80 border border-white/20 grid place-items-center text-primary transition-all active:scale-95 flex-shrink-0"
        title="Kembali"
      >
        <ChevronLeft size={16} />
      </button>

      <div class="flex items-center gap-1.5 flex-shrink-0 pr-1">
        <div
          class="w-7 h-7 rounded-full overflow-hidden bg-white/80 border border-white/20"
        >
          <img
            src="/logo-orb.png"
            alt="OrbFood"
            class="w-full h-full object-cover scale-150"
          />
        </div>
        <span class="text-[15px] font-black text-primary tracking-tight"
          >OrbFood</span
        >
      </div>

      <div class="relative flex-1 min-w-0">
        <span
          class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500 z-10"
        >
          <Search size={14} />
        </span>
        <input
          type="text"
          bind:value={menuSearchQuery}
          placeholder="Cari menu toko..."
          class="w-full pl-9 pr-3 h-9 rounded-full bg-white/40 border border-white/20 focus:bg-white/60 focus:border-accent/50 text-gray-900 text-[13px] outline-none font-black transition-all placeholder:text-gray-500"
        />
      </div>

      <button
        class="w-9 h-9 rounded-full bg-accent/10 border border-accent/20 grid place-items-center text-accent transition-all active:scale-95 flex-shrink-0"
        title={`Lokasi: ${fullStoreData?.villages?.name || "Lokasi toko"}`}
        on:click={() => {
          if (fullStoreData?.google_maps_url) {
            window.open(fullStoreData.google_maps_url, "_blank");
            trackInteraction("google_maps");
          }
        }}
      >
        <MapPin size={15} />
      </button>

      <button
        on:click={handleShare}
        class="w-9 h-9 rounded-full bg-white/80 border border-white/20 grid place-items-center text-primary transition-all active:scale-95 flex-shrink-0"
        title="Bagikan toko"
      >
        <Share2 size={15} />
      </button>
    </div>
  </header>

  <main class="flex-1 overflow-y-auto" on:scroll={handleScroll}>
    <div class="max-w-2xl mx-auto">
      <!-- Enhanced Immersive Banner -->
      <div class="h-64 md:h-80 relative overflow-hidden">
        <img
          src={getOptimizedImageUrl(
            fullStoreData?.banner_url || store.image,
            1200,
          )}
          alt={store.name}
          class="w-full h-full object-cover"
        />
        <div
          class="absolute inset-0 bg-gradient-to-b from-black/50 via-transparent to-black/70"
        ></div>
      </div>

      <div class="px-3">
        <!-- Group Order Section Moved to Badge & Modal -->

        {#if fullStoreData}
          <!-- Ultra-Condensed Store Header Card -->
          <div
            class="relative z-10 -mt-8 bg-white/95 backdrop-blur-2xl rounded-[1.5rem] p-4 shadow-[0_10px_30px_rgba(0,0,0,0.06)] border border-white/60 mb-5 animate-in zoom-in-95 fade-in duration-500"
          >
            <div class="flex items-center gap-4 mb-3">
              <!-- Minimalist Logo -->
              <div
                class="w-14 h-14 rounded-2xl bg-white p-1 shadow-lg border border-gray-100 flex-shrink-0 relative"
              >
                <div
                  class="w-full h-full rounded-xl bg-gray-50 overflow-hidden"
                >
                  <img
                    src={getOptimizedImageUrl(
                      fullStoreData.logo_url || store.image,
                      150,
                    )}
                    alt="Logo"
                    class="w-full h-full object-cover"
                  />
                </div>
                {#if fullStoreData.is_open}
                  <div
                    class="absolute -bottom-0.5 -right-0.5 w-4 h-4 bg-green-500 border-[2.5px] border-white rounded-full"
                  ></div>
                {/if}
              </div>

              <div class="flex-1 min-w-0">
                <h2
                  class="text-lg font-black text-gray-900 tracking-tight leading-none mb-1.5 truncate"
                >
                  {store.name}
                </h2>

                <div
                  class="flex items-center gap-2 overflow-x-auto no-scrollbar pb-0.5"
                >
                  <div
                    class="flex items-center gap-1 text-[10px] font-black text-primary bg-primary/5 px-2 py-0.5 rounded-lg border border-primary/10 shrink-0"
                  >
                    <MapPin size={10} />
                    {fullStoreData.villages?.name || "Lokasi..."}
                  </div>
                  <div
                    class="text-[9px] font-bold text-gray-400 bg-gray-50 px-2 py-0.5 rounded-lg border border-gray-100 shrink-0"
                  >
                    {fullStoreData.category}
                  </div>
                </div>
              </div>

              <div class="shrink-0">
                <!-- Group Order Action (Primary CTA) -->
                {#if user?.id !== store.owner_id}
                  <button
                    on:click={() => (showJoinGroupModal = true)}
                    class="flex items-center gap-1.5 px-3 py-1.5 bg-primary text-white rounded-xl text-[10px] font-black shadow-lg shadow-primary/20 hover:scale-105 active:scale-95 transition-all relative overflow-hidden group"
                  >
                    <Users
                      size={14}
                      class="group-hover:rotate-12 transition-transform"
                    />
                    <span>Grup Order?</span>
                    <div
                      class="absolute inset-0 bg-white/20 translate-x-[-100%] group-hover:translate-x-[100%] transition-transform duration-500"
                    ></div>
                  </button>
                {/if}
              </div>
            </div>

            <!-- Integrated Interaction Strip -->
            <div
              class="flex items-center justify-between py-2.5 border-y border-gray-100 mb-3"
            >
              <div class="flex items-center gap-1.5">
                <div
                  class="flex items-center gap-1 px-2 py-1 {fullStoreData.is_delivery_available
                    ? 'text-primary'
                    : 'text-gray-400'} text-[9px] font-black bg-gray-50 rounded-lg border border-gray-100"
                >
                  <Truck size={10} />
                  {fullStoreData.is_delivery_available
                    ? "DELIVERY"
                    : "TAKEAWAY"}
                </div>

                <div
                  class="flex items-center gap-1 text-[9px] font-bold text-gray-400 ml-1"
                >
                  <Clock size={10} />
                  <span
                    >{fullStoreData.business_hours?.open_time || "00"} - {fullStoreData
                      .business_hours?.close_time || "00"}</span
                  >
                </div>
              </div>

              <div class="flex items-center gap-1.5">
                {#if fullStoreData.instagram_url}
                  <a
                    href="https://instagram.com/{fullStoreData.instagram_url.replace(
                      '@',
                      '',
                    )}"
                    target="_blank"
                    class="w-7 h-7 flex items-center justify-center bg-[#fdf2f8] text-pink-600 rounded-lg border border-pink-100 active:scale-90 transition-transform"
                    title="Instagram"
                  >
                    <Instagram size={14} />
                  </a>
                {/if}

                {#if fullStoreData.tiktok_url}
                  <a
                    href="https://tiktok.com/@{fullStoreData.tiktok_url.replace(
                      '@',
                      '',
                    )}"
                    target="_blank"
                    class="w-7 h-7 flex items-center justify-center bg-gray-50 text-gray-900 rounded-lg border border-gray-200 active:scale-90 transition-transform"
                    title="TikTok"
                  >
                    <svg class="w-3.5 h-3.5 fill-current" viewBox="0 0 24 24"
                      ><path
                        d="M12.53.02C13.84 0 15.14.01 16.44 0c.08 1.53.63 3.09 1.75 4.17 1.12 1.11 2.7 1.62 4.24 1.79v4.03c-1.44-.05-2.89-.35-4.2-.97-.57-.26-1.1-.59-1.62-.93-.01 2.92.01 5.84-.02 8.75-.03 1.4-.54 2.79-1.35 3.94-1.31 1.92-3.58 3.17-5.91 3.21-1.43.08-2.86-.31-4.08-1.03-2.02-1.1-3.34-3.12-3.35-5.47-.03-2.31 1.24-4.52 3.25-5.64 1.23-.74 2.67-1.05 4.1-1.11.01 1.74.01 3.48.01 5.22-.51.01-1.02.13-1.48.34-.84.4-1.36 1.25-1.36 2.18.01.96.6 1.85 1.5 2.17.61.23 1.29.23 1.91-.01.81-.31 1.34-1.14 1.35-2.01.01-4.48.01-8.96.01-13.44.02-.01.02-.02.03-.02"
                      /></svg
                    >
                  </a>
                {/if}

                {#if fullStoreData.google_maps_url}
                  <a
                    href={fullStoreData.google_maps_url}
                    target="_blank"
                    class="w-7 h-7 flex items-center justify-center bg-orange-50 text-orange-600 rounded-lg border border-orange-100 active:scale-90 transition-transform"
                    title="Maps"
                  >
                    <MapPin size={14} />
                  </a>
                {/if}
              </div>
            </div>

            <!-- Slim Description -->
            {#if fullStoreData.description}
              <p
                class="text-[10px] text-gray-500 leading-tight font-medium px-0.5"
              >
                {fullStoreData.description}
              </p>
            {/if}
          </div>

          <!-- Menus Grid -->
          <section class="mt-8 pb-32">
            <div class="flex items-center justify-between mb-4 px-2">
              <h3 class="text-lg font-black text-gray-900">Daftar Menu</h3>
              <span
                class="text-[10px] font-black bg-gray-100 text-gray-500 px-2 py-0.5 rounded-md"
                >{filteredMenuItems.length} ITEM</span
              >
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              {#each filteredMenuItems as item}
                <MenuCard {item} onAdd={() => handleOpenDetail(item)} />
              {/each}
            </div>

            {#if filteredMenuItems.length === 0}
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
              class="fixed bottom-32 right-6 z-40 bg-accent text-white p-4 rounded-3xl shadow-2xl hover:bg-accent/90 transition-all active:scale-95 flex items-center gap-2 font-black text-sm {isNavVisible
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

  <ShopConflictModal
    show={showConflictModal}
    newStoreName={store.name}
    on:cancel={() => (showConflictModal = false)}
    on:confirm={confirmStoreSwitch}
  />

  <JoinGroupModal
    show={showJoinGroupModal}
    on:close={() => (showJoinGroupModal = false)}
    on:join_code={handleJoinByCode}
    on:createNew={() => {
      showJoinGroupModal = false;
      showCreateGroupModal = true;
    }}
  />

  {#if showCreateGroupModal}
    <CreateGroupModal
      storeName={store.name}
      isLoading={creatingGroup}
      isShopOwner={user?.id === store.owner_id}
      on:close={() => (showCreateGroupModal = false)}
      on:submit={handleCreateGroupSubmit}
    />
  {/if}

  {#if showPaymentInfoModal && selectedGroupForJoin}
    <PaymentInfoModal
      roomName={selectedGroupForJoin.name}
      paymentMethod={selectedGroupForJoin.creator_payment?.payment_method}
      qrisImageUrl={selectedGroupForJoin.creator_payment?.qris_image_url}
      bankName={selectedGroupForJoin.creator_payment?.bank_name}
      bankAccountNumber={selectedGroupForJoin.creator_payment
        ?.bank_account_number}
      bankAccountName={selectedGroupForJoin.creator_payment?.bank_account_name}
      on:close={() => {
        showPaymentInfoModal = false;
        selectedGroupForJoin = null;
      }}
      on:proceed={handlePaymentInfoProceed}
    />
  {/if}

  {#if activeGroupOrder && activeGroupOrder.store_id === store.id}
    <GroupOrderStickyFooter
      room={activeGroupOrder}
      myTotal={groupTotal}
      onOpenCart={onViewCart}
    />
  {/if}

  {#if selectedMenu}
    <MenuDetailModal
      show={showDetailModal}
      item={selectedMenu}
      {editIndex}
      onAdd={handleAddToCart}
      on:close={() => {
        showDetailModal = false;
        if (editIndex !== null) onCloseEdit();
      }}
    />
  {/if}
</div>

<style>
  :global(body) {
    overflow: hidden;
  }
</style>
