<script lang="ts">
  import { onMount, createEventDispatcher } from "svelte";
  import {
    cart,
    cartTotal,
    updateQuantityByIndex,
    removeItemByIndex,
    clearCart,
  } from "../../stores/cartStore";
  import { groupOrderStore } from "../../stores/groupOrderStore";
  import { supabase, getAuthRedirectUrl } from "../../services/supabase";
  import {
    Camera,
    Paperclip,
    CheckCircle2,
    Loader2,
    X,
    Info,
    Users,
  } from "lucide-svelte";
  import GroupOrderSummaryModal from "../../components/modals/GroupOrderSummaryModal.svelte";

  export let user: any = null;
  export let onBack: () => void;
  export let onEditItem: (index: number, item: any) => void;

  let customerName = user?.user_metadata?.full_name || "";
  let notes = "";
  let showLoginPrompt = false;
  let isSubmitting = false;
  let loginAgreed = false;
  let transferProofFile: File | null = null;
  let isUploadingProof = false;
  let proofPreviewUrl: string | null = null;

  // Track if we've already fetched shop info to avoid redundant calls
  let shopInfo: any = null;

  $: activeGroupOrder = $groupOrderStore;
  $: isCreator = !!(
    activeGroupOrder && user?.id === activeGroupOrder.creator_id
  );
  let creatorProfile: any = null;
  let showSummaryModal = false;
  let roomParticipants: any[] = [];

  $: if (activeGroupOrder && !isCreator && activeGroupOrder.creator_id) {
    fetchCreatorProfile();
  }

  async function fetchCreatorProfile() {
    const { data: profile } = await supabase
      .from("user_profiles")
      .select(
        "phone, payment_method, qris_image_url, bank_name, bank_account_number, bank_account_name",
      )
      .eq("id", activeGroupOrder?.creator_id)
      .single();
    creatorProfile = profile;
  }

  $: if (user && !customerName) {
    customerName = user.user_metadata.full_name;
  }

  async function fetchRoomParticipants() {
    if (!activeGroupOrder) return;

    const { data } = await supabase
      .from("order_history")
      .select(
        "id, user_id, participant_name, total_price, items, status, transfer_proof_url, payment_status",
      )
      .eq("order_room_id", activeGroupOrder.id);

    roomParticipants = data || [];
  }

  onMount(async () => {
    // Persistence: Check if we should re-open the summary modal
    const persistRoomId = localStorage.getItem("active_group_recap_id");
    if (
      persistRoomId &&
      activeGroupOrder &&
      persistRoomId === activeGroupOrder.id
    ) {
      await fetchRoomParticipants();
      showSummaryModal = true;
    }
  });

  async function handleOpenSummary() {
    await fetchRoomParticipants();
    if (activeGroupOrder) {
      localStorage.setItem("active_group_recap_id", activeGroupOrder.id);
    }
    showSummaryModal = true;
  }

  function handleCheckout() {
    if (!customerName) {
      alert("Silakan masukkan nama Anda");
      return;
    }

    if (activeGroupOrder && !isCreator && !transferProofFile) {
      alert("Silakan unggah bukti transfer terlebih dahulu untuk Group Order");
      return;
    }

    if (!user) {
      showLoginPrompt = true;
      return;
    }
    submitOrder();
  }

  async function processTransferProof(file: File): Promise<Blob> {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = (e) => {
        const img = new Image();
        img.onload = () => {
          const canvas = document.createElement("canvas");
          let width = img.width;
          let height = img.height;
          const maxDim = 1000; // Better quality for storage
          if (width > height) {
            if (width > maxDim) {
              height *= maxDim / width;
              width = maxDim;
            }
          } else {
            if (height > maxDim) {
              width *= maxDim / height;
              height = maxDim;
            }
          }
          canvas.width = width;
          canvas.height = height;
          const ctx = canvas.getContext("2d");
          ctx?.drawImage(img, 0, 0, width, height);
          canvas.toBlob(
            (blob) => {
              if (blob) resolve(blob);
              else reject(new Error("Gagal kompres gambar"));
            },
            "image/jpeg",
            0.7,
          );
        };
        img.src = e.target?.result as string;
      };
      reader.onerror = reject;
      reader.readAsDataURL(file);
    });
  }

  async function uploadTransferProof(): Promise<string | null> {
    if (!transferProofFile) return null;
    isUploadingProof = true;
    try {
      const compressedBlob = await processTransferProof(transferProofFile);
      const fileName = `${Math.random().toString(36).substring(2)}-${Date.now()}.jpg`;
      const filePath = `${activeGroupOrder?.id}/${fileName}`;

      const { error } = await supabase.storage
        .from("transfer_proofs")
        .upload(filePath, compressedBlob);

      if (error) throw error;

      const {
        data: { publicUrl },
      } = supabase.storage.from("transfer_proofs").getPublicUrl(filePath);

      return publicUrl;
    } catch (error) {
      console.error("Error uploading proof:", error);
      throw new Error("Gagal mengunggah bukti transfer");
    } finally {
      isUploadingProof = false;
    }
  }

  async function submitOrder() {
    if ($cart.length === 0) return;
    isSubmitting = true;

    try {
      // 1. Get the shop_id from the first item (assuming all items are from the same shop)
      const shopId = $cart[0].shop_id;

      // 2. Fetch the latest shop info (especially the WhatsApp number)
      const { data: shop, error: shopError } = await supabase
        .from("shops")
        .select("name, whatsapp")
        .eq("id", shopId)
        .single();

      if (shopError || !shop) {
        throw new Error("Gagal mengambil informasi toko");
      }

      let proofUrl = null;
      if (activeGroupOrder && !isCreator && transferProofFile) {
        proofUrl = await uploadTransferProof();
      }

      // 3. Save order to database for history
      const { data: order, error: orderError } = await supabase
        .from("order_history")
        .insert({
          user_id: user?.id || null,
          shop_id: shopId,
          order_room_id: activeGroupOrder?.id || null,
          participant_name: customerName,
          items: $cart.map((item) => ({
            menu_id: item.id,
            name: item.name,
            price: item.final_price || item.price,
            qty: item.quantity || 1,
            image: item.primary_image || item.image,
            customizations: item.customizations || [],
          })),
          total_price: $cartTotal,
          customer_name: customerName,
          customer_phone: "",
          notes: notes,
          transfer_proof_url: proofUrl,
          payment_status: isCreator
            ? "verified"
            : proofUrl
              ? "pending"
              : "none",
          status: activeGroupOrder ? "submitted" : "sent_to_wa",
        })
        .select()
        .single();

      if (orderError) throw orderError;

      if (activeGroupOrder) {
        const { toasts } = await import("../../stores/toastStore");
        toasts.success(
          isCreator
            ? "Pesanan Anda berhasil ditambahkan ke rekap grup!"
            : "Pesanan kamu sudah masuk ke Group Order!",
        );

        if (isCreator) {
          clearCart();
          await handleOpenSummary();
          return; // Stay on CartPage to show modal
        }

        clearCart();
        onBack();
        return;
      } else {
        // 4. Proceed to WhatsApp (ONLY if not group order)
        const itemsText = getWhatsAppItemsText($cart);

        const message = `Halo ${shop.name}! Saya ${customerName}.

Saya mau pesan:
${itemsText}

Total: Rp ${$cartTotal.toLocaleString()}

Catatan:
${notes || "-"}

Order ID: ${order.id.split("-")[0].toUpperCase()}
Lokasi saya akan saya kirimkan setelah ini.`;

        const encodedMessage = encodeURIComponent(message);
        const cleanWhatsApp = shop.whatsapp
          .replace(/^0/, "62")
          .replace(/\D/g, "");

        window.open(
          `https://wa.me/${cleanWhatsApp}?text=${encodedMessage}`,
          "_blank",
        );
      }

      // Clear cart after success
      clearCart();
      onBack();
    } catch (error: any) {
      alert("Terjadi kesalahan: " + error.message);
    } finally {
      isSubmitting = false;
    }
  }

  async function loginWithGoogle() {
    await supabase.auth.signInWithOAuth({
      provider: "google",
      options: { redirectTo: getAuthRedirectUrl() },
    });
  }

  function handleFileChange(e: Event) {
    const target = e.target as HTMLInputElement;
    if (target.files && target.files.length > 0) {
      transferProofFile = target.files[0];
      proofPreviewUrl = URL.createObjectURL(transferProofFile);
    }
  }

  // Typed helpers to avoid linting issues in template
  function formatCustomization(group: any): string {
    if (!group.selected_items) return "";
    return group.selected_items
      .map((si: any) => `${si.name}${si.qty > 1 ? ` (x${si.qty})` : ""}`)
      .join(", ");
  }

  function getWhatsAppItemsText(cartItems: any[]): string {
    return cartItems
      .map((item) => {
        let text = `- ${item.name} (${item.quantity || 1}) - Rp ${((item.final_price || item.price) * (item.quantity || 1)).toLocaleString()}`;
        if (item.customizations && item.customizations.length > 0) {
          const custText = item.customizations
            .map((c: any) => {
              const choices = formatCustomization(c);
              return `  • ${c.group_name}: ${choices}`;
            })
            .join("\n");
          text += `\n${custText}`;
        }
        return text;
      })
      .join("\n");
  }
</script>

<div class="cart-page">
  <header class="header bg-primary sticky-top">
    <button class="back-btn" on:click={onBack}>←</button>
    <h1>Keranjang Belanja</h1>
  </header>

  <main class="content">
    {#if $cart.length === 0}
      <div class="empty-cart">
        <div class="illustration">🛒</div>
        <p>Keranjang kamu masih kosong</p>
        <button class="bg-accent" on:click={onBack}>Cari Makanan</button>
      </div>
    {:else}
      <section class="cart-items">
        <div class="shop-info">
          <h3>📦 Pesanan Anda</h3>
          <button class="clear-btn" on:click={clearCart}>Hapus Semua</button>
        </div>

        {#each $cart as item, index}
          <div class="cart-item shadow-soft rounded-lg">
            <div class="item-info">
              <span class="item-name">{item.name}</span>
              <span class="item-price"
                >Rp {(item.final_price || item.price).toLocaleString()}</span
              >
              {#if item.customizations && item.customizations.length > 0}
                <div class="customization-details mt-1">
                  {#each item.customizations as group}
                    <div class="mb-1">
                      <p
                        class="text-[9px] font-black text-primary uppercase leading-none"
                      >
                        {group.group_name}:
                      </p>
                      <p class="text-[11px] text-gray-500 leading-tight">
                        {formatCustomization(group)}
                      </p>
                    </div>
                  {/each}
                </div>
              {/if}
              <button
                on:click={() => onEditItem(index, item)}
                class="text-[10px] font-black text-blue-500 uppercase mt-2 self-start hover:underline"
              >
                Ubah Pilihan
              </button>
            </div>
            <div class="qty-controls">
              <button
                class="qty-btn"
                on:click={() =>
                  item.quantity > 1
                    ? updateQuantityByIndex(index, -1)
                    : removeItemByIndex(index)}>−</button
              >
              <span class="qty">{item.quantity || 1}</span>
              <button
                class="qty-btn"
                on:click={() => updateQuantityByIndex(index, 1)}>+</button
              >
            </div>
          </div>
        {/each}
      </section>

      <section class="checkout-form">
        <div class="input-group">
          <label for="name">Nama Pembeli</label>
          <input
            type="text"
            id="name"
            bind:value={customerName}
            placeholder="Masukkan nama Anda..."
          />
        </div>
        <div class="input-group">
          <label for="notes">Catatan Pesanan</label>
          <textarea
            id="notes"
            bind:value={notes}
            placeholder="Contoh: Pedas sedang, tanpa sayur..."
          ></textarea>
        </div>
      </section>

      {#if activeGroupOrder && !isCreator && creatorProfile}
        <section
          class="creator-payment-info bg-white p-5 rounded-2xl border-2 border-primary/20 mb-4 mx-4 shadow-sm"
        >
          <div class="flex items-center gap-2 mb-4">
            <div
              class="w-10 h-10 bg-primary/10 rounded-xl flex items-center justify-center"
            >
              <Users size={20} class="text-primary" />
            </div>
            <div>
              <h3 class="text-sm font-black text-gray-900 uppercase">
                Bayar ke Ketua Room
              </h3>
              <p class="text-[11px] text-gray-500 font-bold">
                {activeGroupOrder.name}
              </p>
            </div>
          </div>

          <div class="space-y-3">
            <div class="p-4 bg-primary/5 rounded-2xl border border-primary/10">
              <p class="text-[11px] font-bold text-primary uppercase mb-2">
                Instruksi
              </p>
              <p class="text-xs text-gray-600 leading-relaxed font-medium">
                Silakan transfer sesuai total belanja. Setelah klik pesan,
                <b>lampirkan bukti transfer</b> secara manual di chat WhatsApp ketua
                room.
              </p>
            </div>

            {#if creatorProfile.payment_method === "qris" && creatorProfile.qris_image_url}
              <div class="text-center">
                <p class="text-[10px] font-bold text-gray-400 mb-2 uppercase">
                  Scan QRIS Di Bawah
                </p>
                <img
                  src={creatorProfile.qris_image_url}
                  alt="QRIS"
                  class="w-48 mx-auto rounded-xl shadow-sm border border-gray-100"
                />
              </div>
            {:else if creatorProfile.payment_method === "bank_transfer"}
              <div class="bg-white p-3 rounded-xl border border-gray-100">
                <p class="text-[9px] font-bold text-gray-400 uppercase">Bank</p>
                <p class="text-sm font-black text-gray-900">
                  {creatorProfile.bank_name}
                </p>
                <div class="mt-2">
                  <p class="text-[9px] font-bold text-gray-400 uppercase">
                    No. Rekening
                  </p>
                  <p class="text-sm font-black text-gray-900 tracking-wider">
                    {creatorProfile.bank_account_number}
                  </p>
                </div>
                <div class="mt-2">
                  <p class="text-[9px] font-bold text-gray-400 uppercase">
                    Atas Nama
                  </p>
                  <p class="text-sm font-black text-gray-900">
                    {creatorProfile.bank_account_name}
                  </p>
                </div>
              </div>
            {/if}
          </div>
        </section>
      {/if}

      {#if activeGroupOrder && !isCreator}
        <section
          class="payment-proof bg-blue-50/50 p-5 rounded-2xl border border-blue-100/50 mb-4 mx-4 shadow-sm"
        >
          <div class="flex items-center gap-2 mb-3">
            <div
              class="w-10 h-10 bg-blue-100 rounded-xl flex items-center justify-center"
            >
              <Paperclip size={20} class="text-blue-600" />
            </div>
            <div>
              <h3 class="text-sm font-black text-blue-900">Upload Bukti Pay</h3>
              <p
                class="text-[10px] text-blue-600 font-bold uppercase tracking-wider"
              >
                Agar bisa diverifikasi di web
              </p>
            </div>
          </div>

          <div class="mt-4 p-4 bg-white rounded-2xl border border-gray-100">
            <input
              type="file"
              id="proof"
              accept="image/*"
              on:change={handleFileChange}
              class="hidden"
            />
            <button
              on:click={() => document.getElementById("proof")?.click()}
              class="w-full py-5 px-4 border-2 border-dashed border-gray-200 rounded-xl flex flex-col items-center gap-2 hover:border-primary/50 transition-all active:scale-[0.98]"
            >
              {#if proofPreviewUrl}
                <div class="relative w-full group">
                  <img
                    src={proofPreviewUrl}
                    alt="Preview"
                    class="w-full h-40 object-contain rounded-lg"
                  />
                  <div
                    class="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 rounded-lg flex items-center justify-center transition-opacity"
                  >
                    <Camera class="text-white" size={24} />
                  </div>
                </div>
                <span class="text-[10px] font-black text-primary uppercase"
                  >Klik untuk Ganti Foto</span
                >
              {:else}
                <div
                  class="w-12 h-12 bg-gray-50 rounded-full flex items-center justify-center mb-1"
                >
                  <Camera size={28} class="text-gray-300" />
                </div>
                <span
                  class="text-xs font-black text-gray-400 uppercase tracking-wider"
                  >Klik & Ambil Foto</span
                >
                <p class="text-[10px] text-gray-400 font-medium">
                  Format: JPG, PNG, Max 5MB
                </p>
              {/if}
            </button>
          </div>
        </section>
      {/if}

      {#if activeGroupOrder && !isCreator}
        <section
          class="payment-proof bg-blue-50/50 p-5 rounded-2xl border border-blue-100/50 mb-4 mx-4"
        >
          <div class="flex items-center gap-2 mb-3">
            <div
              class="w-8 h-8 bg-blue-100 rounded-lg flex items-center justify-center"
            >
              <Paperclip size={18} class="text-blue-600" />
            </div>
            <div>
              <h3 class="text-sm font-black text-blue-900">Bukti Transfer</h3>
              <p
                class="text-[10px] text-blue-600 font-bold uppercase tracking-wider"
              >
                Wajib untuk Group Order
              </p>
            </div>
          </div>
          <p
            class="text-[9px] text-blue-500/70 mb-3 bg-white/50 p-1.5 rounded-lg border border-blue-100/50"
          >
            <Info size={10} class="inline mr-1" />
            Privasi Keamanan: Bukti transfer hanya dapat dilihat oleh Pembuat Room
            dan Toko untuk verifikasi pesanan.
          </p>

          {#if proofPreviewUrl}
            <div
              class="relative rounded-xl overflow-hidden border-2 border-white shadow-sm mb-3"
            >
              <img
                src={proofPreviewUrl}
                alt="Proof"
                class="w-full h-40 object-cover"
              />
              <button
                class="absolute top-2 right-2 p-1.5 bg-black/50 text-white rounded-full backdrop-blur-md"
                on:click={() => {
                  transferProofFile = null;
                  proofPreviewUrl = null;
                }}
              >
                <X size={14} />
              </button>
            </div>
          {:else}
            <label
              class="flex flex-col items-center justify-center py-8 border-2 border-dashed border-blue-200 rounded-xl bg-white/50 hover:bg-white transition-all cursor-pointer group"
            >
              <input
                type="file"
                accept="image/*"
                class="hidden"
                on:change={handleFileChange}
              />
              <Camera
                size={24}
                class="text-blue-400 group-hover:scale-110 transition-transform mb-2"
              />
              <span class="text-xs font-bold text-blue-600 underline"
                >Pilih Foto Bukti TF</span
              >
              <p class="text-[10px] text-gray-400 mt-1">
                Format JPG, PNG (Max 5MB)
              </p>
            </label>
          {/if}

          {#if isUploadingProof}
            <div class="flex items-center gap-2 mt-2 text-blue-600">
              <Loader2 size={12} class="animate-spin" />
              <span class="text-[10px] font-black uppercase">Mengunggah...</span
              >
            </div>
          {/if}
        </section>
      {/if}

      <section class="summary">
        <div class="summary-row">
          <span>Subtotal</span>
          <span>Rp {$cartTotal.toLocaleString()}</span>
        </div>
        <div class="summary-row total">
          <span>Total Pembayaran</span>
          <span>Rp {$cartTotal.toLocaleString()}</span>
        </div>
      </section>
    {/if}
  </main>

  {#if $cart.length > 0}
    <footer
      class="footer sticky-bottom shadow-soft flex flex-col gap-2 p-4 bg-white border-t"
    >
      {#if activeGroupOrder}
        <button
          class="w-full py-2.5 rounded-xl border-2 border-primary/20 bg-primary/5 text-primary text-xs font-black uppercase tracking-widest hover:bg-primary/10 transition-all flex items-center justify-center gap-2"
          on:click={handleOpenSummary}
        >
          <Users size={16} />
          Pesanan Room Kamu
        </button>
      {/if}

      <button
        class="checkout-btn w-full py-4 rounded-xl font-black text-sm uppercase tracking-widest shadow-lg transition-all active:scale-[0.98] {activeGroupOrder
          ? 'bg-blue-600 text-white shadow-blue-200'
          : 'bg-accent text-white shadow-accent/20'} disabled:opacity-50"
        on:click={handleCheckout}
        disabled={isSubmitting}
      >
        {#if isSubmitting}
          MEMPROSES...
        {:else if activeGroupOrder && !isCreator}
          PESAN ORDER GRUP
        {:else}
          PESAN VIA WHATSAPP
        {/if}
      </button>
    </footer>
  {/if}

  {#if showLoginPrompt}
    <div class="modal-overlay">
      <div class="modal rounded-lg shadow-soft">
        <h3>
          {activeGroupOrder
            ? "🔐 Login Wajib untuk Group Order"
            : "🔐 Simpan pesanan kamu?"}
        </h3>
        <p>
          {activeGroupOrder
            ? "Untuk mengikuti Group Order, Anda harus masuk agar pesanan dan bukti transfer tercatat dengan benar."
            : "Masuk agar pesanan masuk riwayat dan kamu bisa memberi ulasan nantinya."}
        </p>
        <div class="modal-actions">
          <label class="agreement">
            <input type="checkbox" bind:checked={loginAgreed} />
            <span>
              Dengan login, saya menyetujui
              <a href="#/privacy">Kebijakan Privasi</a>
              dan
              <a href="#/terms">Syarat Layanan</a>
            </span>
          </label>
          <button
            class="login-btn google-btn"
            on:click={loginWithGoogle}
            disabled={!loginAgreed}>Login dengan Google</button
          >

          {#if !activeGroupOrder}
            <button class="skip-btn" on:click={submitOrder}
              >Lanjut Tanpa Login</button
            >
          {/if}
        </div>
      </div>
    </div>
  {/if}

  {#if showSummaryModal && activeGroupOrder}
    <GroupOrderSummaryModal
      room={activeGroupOrder}
      participants={roomParticipants}
      {isCreator}
      currentUserId={user?.id}
      shopName={shopInfo?.name || "Toko"}
      on:close={() => {
        showSummaryModal = false;
        localStorage.removeItem("active_group_recap_id");
        onBack(); // Close cart after finishing recap
      }}
    />
  {/if}
</div>

<style>
  .cart-page {
    display: flex;
    flex-direction: column;
    flex: 1;
    background: var(--bg-soft);
  }

  .header {
    display: flex;
    align-items: center;
    padding: 10px 16px;
    color: white;
    gap: 12px;
  }

  .back-btn {
    background: none;
    color: white;
    font-size: 24px;
    padding: 0;
  }

  .header h1 {
    margin: 0;
    font-size: 16px;
    font-weight: 900;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }

  .content {
    padding: 12px;
    display: flex;
    flex-direction: column;
    gap: 12px;
    flex: 1;
    padding-bottom: 120px;
  }

  .empty-cart {
    text-align: center;
    padding: 60px 20px;
  }

  .illustration {
    font-size: 64px;
    margin-bottom: 16px;
  }

  .shop-info {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 12px;
  }

  .shop-info h3 {
    margin: 0;
    font-size: 16px;
  }

  .clear-btn {
    font-size: 12px;
    color: var(--danger);
    background: none;
  }

  .cart-item {
    background: white;
    padding: 10px 12px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-radius: 12px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
  }

  .item-info {
    display: flex;
    flex-direction: column;
  }

  .item-name {
    font-weight: 600;
    font-size: 14px;
  }

  .item-price {
    font-size: 13px;
    color: var(--text-muted);
  }

  .qty-controls {
    display: flex;
    align-items: center;
    gap: 12px;
    background: var(--bg-soft);
    padding: 4px 8px;
    border-radius: 20px;
  }

  .qty-btn {
    width: 28px;
    height: 28px;
    border-radius: 50%;
    background: white;
    color: var(--primary);
    font-weight: 700;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
  }

  .qty {
    font-size: 14px;
    font-weight: 700;
    min-width: 20px;
    text-align: center;
  }

  .checkout-form {
    display: flex;
    flex-direction: column;
    gap: 16px;
  }

  .input-group {
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  .input-group label {
    font-size: 14px;
    font-weight: 600;
  }

  .input-group input,
  .input-group textarea {
    padding: 12px;
    border-radius: 8px;
    border: 1px solid #ddd;
    font-size: 14px;
  }

  .input-group textarea {
    height: 80px;
    resize: none;
  }

  .summary {
    background: white;
    padding: 16px;
    border-radius: 12px;
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .summary-row {
    display: flex;
    justify-content: space-between;
    font-size: 14px;
    color: var(--text-muted);
  }

  .summary-row.total {
    margin-top: 8px;
    padding-top: 8px;
    border-top: 1px solid var(--bg-soft);
    font-weight: 700;
    color: var(--text-main);
    font-size: 16px;
  }

  .footer {
    padding: 16px;
    background: white;
  }

  .checkout-btn {
    width: 100%;
    padding: 16px;
    border-radius: 12px;
    font-weight: 800;
    color: white;
    font-size: 16px;
    letter-spacing: 0.5px;
  }

  /* Modal */
  .modal-overlay {
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 20px;
    z-index: 100;
  }

  .modal {
    background: white;
    padding: 24px;
    max-width: 400px;
    width: 100%;
    text-align: center;
  }

  .modal h3 {
    margin: 0 0 12px 0;
  }

  .modal p {
    font-size: 14px;
    color: var(--text-muted);
    margin-bottom: 24px;
  }

  .modal-actions {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .login-btn {
    padding: 12px;
    border-radius: 8px;
    font-weight: 700;
  }

  .google-btn {
    background: var(--primary);
    color: white;
  }

  .google-btn:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }

  .skip-btn {
    background: none;
    color: var(--text-hint);
    font-size: 13px;
  }

  .agreement {
    display: flex;
    align-items: flex-start;
    gap: 10px;
    font-size: 13px;
    color: var(--text-main);
    cursor: pointer;
    text-align: left;
  }

  .agreement input[type="checkbox"] {
    width: 18px;
    height: 18px;
    margin-top: 2px;
    accent-color: var(--primary);
    cursor: pointer;
    flex-shrink: 0;
  }

  .agreement span {
    flex: 1;
    line-height: 1.5;
  }

  .agreement a {
    color: var(--primary);
    text-decoration: underline;
    font-weight: 600;
  }
</style>
