<script lang="ts">
  import {
    cart,
    cartTotal,
    updateQuantity,
    removeFromCart,
    clearCart,
  } from "../../stores/cartStore";
  import { supabase } from "../../services/supabase";

  export let user: any = null;
  export let onBack: () => void;

  let customerName = user?.user_metadata?.full_name || "";
  let notes = "";
  let showLoginPrompt = false;
  let isSubmitting = false;
  let loginAgreed = false;

  // Track if we've already fetched shop info to avoid redundant calls
  let shopInfo: any = null;

  $: if (user && !customerName) {
    customerName = user.user_metadata.full_name;
  }

  function handleCheckout() {
    if (!customerName) {
      alert("Silakan masukkan nama Anda");
      return;
    }

    if (!user) {
      showLoginPrompt = true;
      return;
    }
    submitOrder();
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

      // 3. Save order to database for history
      const { data: order, error: orderError } = await supabase
        .from("order_history")
        .insert({
          user_id: user?.id || null, // Allow anonymous orders
          shop_id: shopId,
          items: $cart.map((item) => ({
            menu_id: item.id,
            name: item.name,
            price: item.price,
            qty: item.quantity || 1,
            image: item.primary_image || item.image,
          })),
          total_price: $cartTotal,
          customer_name: customerName,
          customer_phone: "", // We don't have this yet, but we have their WA later
          notes: notes,
          status: "sent_to_wa",
        })
        .select()
        .single();

      if (orderError) throw orderError;

      // 4. Proceed to WhatsApp
      const itemsText = $cart
        .map(
          (item) =>
            `- ${item.name} (${item.quantity || 1}) - Rp ${(item.price * (item.quantity || 1)).toLocaleString()}`,
        )
        .join("\n");

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
      options: { redirectTo: window.location.origin },
    });
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

        {#each $cart as item}
          <div class="cart-item shadow-soft rounded-lg">
            <div class="item-info">
              <span class="item-name">{item.name}</span>
              <span class="item-price">Rp {item.price.toLocaleString()}</span>
            </div>
            <div class="qty-controls">
              <button
                class="qty-btn"
                on:click={() =>
                  item.quantity > 1
                    ? updateQuantity(item.id, -1)
                    : removeFromCart(item.id)}>−</button
              >
              <span class="qty">{item.quantity || 1}</span>
              <button
                class="qty-btn"
                on:click={() => updateQuantity(item.id, 1)}>+</button
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
    <footer class="footer sticky-bottom shadow-soft">
      <button
        class="checkout-btn bg-accent disabled:opacity-50"
        on:click={handleCheckout}
        disabled={isSubmitting}
      >
        {isSubmitting ? "MEMPROSES..." : "PESAN VIA WHATSAPP"}
      </button>
    </footer>
  {/if}

  {#if showLoginPrompt}
    <div class="modal-overlay">
      <div class="modal rounded-lg shadow-soft">
        <h3>🔐 Simpan pesanan kamu?</h3>
        <p>
          Masuk agar pesanan masuk riwayat dan kamu bisa memberi ulasan
          nantinya.
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
          <button class="skip-btn" on:click={submitOrder}
            >Lanjut Tanpa Login</button
          >
        </div>
      </div>
    </div>
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
    padding: 12px 16px;
    color: white;
    gap: 16px;
  }

  .back-btn {
    background: none;
    color: white;
    font-size: 24px;
    padding: 0;
  }

  .header h1 {
    margin: 0;
    font-size: 18px;
    font-weight: 700;
  }

  .content {
    padding: 16px;
    display: flex;
    flex-direction: column;
    gap: 20px;
    flex: 1;
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
    padding: 12px 16px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 10px;
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
