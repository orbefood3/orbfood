<script lang="ts">
  import { onMount } from "svelte";
  import { supabase, getAuthRedirectUrl } from "../../services/supabase";
  import { ArrowRight } from "lucide-svelte";
  import { groupOrderStore } from "../../stores/groupOrderStore";
  export let user: any = null;

  let activeTab = "Semua";
  const tabs = ["Semua", "Diproses", "Selesai", "Batal"];

  let orders: any[] = [];
  let loading = true;
  let agreed = false;

  $: activeGroupOrder = $groupOrderStore;
  $: isExpired =
    activeGroupOrder &&
    activeGroupOrder.closing_time &&
    new Date(activeGroupOrder.closing_time) < new Date();

  // Pagination
  let page = 0;
  const pageSize = 5;
  let hasMore = true;
  let loadingMore = false;

  onMount(() => fetchOrders(true));

  async function fetchOrders(reset = false) {
    if (!user) return;
    if ((!hasMore && !reset) || loadingMore) return;

    if (reset) {
      page = 0;
      orders = [];
      hasMore = true;
      loading = true;
    } else {
      loadingMore = true;
    }

    const from = page * pageSize;
    const to = from + pageSize - 1;

    // Fetch orders joined with shop names, optimized select
    const { data, error } = await supabase
      .from("order_history")
      .select(
        "id, user_id, status, total_price, created_at, order_room_id, shops(name)",
      )
      .eq("user_id", user.id)
      .order("created_at", { ascending: false })
      .range(from, to);

    if (error) {
      console.error("Error fetching orders:", error);
    } else {
      const newOrders = data || [];
      if (reset) {
        orders = newOrders;
      } else {
        orders = [...orders, ...newOrders];
      }

      hasMore = newOrders.length === pageSize;
      if (hasMore) page++;
    }
    loading = false;
    loadingMore = false;
  }

  const statusMap: Record<string, { label: string; color: string }> = {
    sent_to_wa: { label: "Diproses", color: "var(--accent)" },
    completed: { label: "Selesai", color: "var(--success)" },
    cancelled: { label: "Batal", color: "var(--danger)" },
    pending: { label: "Pending", color: "var(--text-hint)" },
  };

  async function loginWithGoogle() {
    if (!agreed) return;
    await supabase.auth.signInWithOAuth({
      provider: "google",
      options: { redirectTo: getAuthRedirectUrl() },
    });
  }

  async function handleCopyDraft(roomId: string, shopName: string) {
    try {
      // 1. Fetch all participants for this room
      const { data: participants, error } = await supabase
        .from("order_history")
        .select("participant_name, total_price, items, payment_status")
        .eq("order_room_id", roomId);

      if (error || !participants)
        throw error || new Error("Data tidak ditemukan");

      // 2. Generate Draft (Same logic as Summary Modal)
      const header = `*ORDER GROUP - ${shopName.toUpperCase()}*\n_(Salinan Cadangan)_\n\n`;
      let itemsText = "";
      let total = 0;
      let aggregatedItems: any = {};

      participants.forEach((p) => {
        if (p.payment_status === "verified") {
          total += p.total_price;
          const items = Array.isArray(p.items) ? p.items : [];
          items.forEach((item: any) => {
            const key = item.name + (item.variant ? ` (${item.variant})` : "");
            if (!aggregatedItems[key]) {
              aggregatedItems[key] = { qty: 0, name: key };
            }
            aggregatedItems[key].qty += item.qty;
          });
        }
      });

      Object.values(aggregatedItems).forEach((item: any) => {
        itemsText += `- ${item.name} x${item.qty}\n`;
      });

      const footer = `\n*Total Terverifikasi: Rp ${total.toLocaleString("id-ID")}*\n\n`;
      let userDetails = "*Rincian:* \n";
      participants.forEach((p) => {
        const icon = p.payment_status === "verified" ? "✅" : "⏳";
        userDetails += `${icon} ${p.participant_name}: Rp ${p.total_price.toLocaleString()}\n`;
      });

      const fullText = header + itemsText + footer + userDetails;

      // 3. Copy to Clipboard
      await navigator.clipboard.writeText(fullText);
      alert("Draft pesanan berhasil disalin ke clipboard!");
    } catch (err) {
      console.error("Failed to copy draft:", err);
      alert("Gagal menyalin draft.");
    }
  }

  function handleTouch() {
    window.dispatchEvent(new CustomEvent("show-nav"));
  }

  onMount(() => {
    fetchOrders(true);
    window.addEventListener("touchstart", handleTouch, { passive: true });
    return () => {
      window.removeEventListener("touchstart", handleTouch);
    };
  });
</script>

<!-- svelte-ignore a11y-click-events-have-key-events -->
<!-- svelte-ignore a11y-no-static-element-interactions -->
<div class="orders-page" on:touchstart|stopPropagation={handleTouch}>
  <header class="header bg-primary sticky-top shadow-soft">
    <h1>Riwayat Pesanan</h1>
  </header>

  <main class="content">
    {#if !user}
      <div class="empty-state">
        <div class="illustration">🍱</div>
        <h2>Masuk untuk melihat riwayat pesanan</h2>
        <p>
          Login agar riwayat pesanan dan ulasan kamu tersimpan rapi di sini.
        </p>
        <div class="actions">
          <label class="agreement">
            <input type="checkbox" bind:checked={agreed} />
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
            disabled={!agreed}
          >
            Login dengan Google
          </button>
        </div>
      </div>
    {:else}
      <section class="tabs-scroll">
        {#each tabs as tab}
          <button
            class="tab-chip {activeTab === tab ? 'active' : ''}"
            on:click={() => (activeTab = tab)}
          >
            {tab}
          </button>
        {/each}
      </section>

      <div class="order-list">
        {#if activeGroupOrder}
          <div
            class="{isExpired
              ? 'bg-red-50 border-red-200'
              : 'bg-primary/5 border-primary/20'} border-2 p-5 rounded-2xl mb-6 shadow-sm animate-in fade-in slide-in-from-top duration-300"
          >
            <div class="flex justify-between items-start mb-4">
              <div>
                <span
                  class="text-[10px] font-black {isExpired
                    ? 'bg-red-100 text-red-600'
                    : 'bg-primary/10 text-primary'} px-2 py-0.5 rounded-lg uppercase tracking-widest"
                  >{isExpired ? "Grup Berakhir" : "Grup Berlangsung"}</span
                >
                <h3 class="text-lg font-black text-gray-900 mt-1">
                  {activeGroupOrder.name}
                </h3>
                <p class="text-xs font-mono text-gray-400">
                  Kode: #{activeGroupOrder.short_code}
                </p>
              </div>
              <button
                on:click={() =>
                  (window.location.hash = `#/shop/${activeGroupOrder.shops?.slug}`)}
                class="w-10 h-10 bg-white border border-gray-100 rounded-xl flex items-center justify-center text-primary shadow-sm"
              >
                <ArrowRight size={20} />
              </button>
            </div>
            <div class="flex items-center gap-3">
              <button
                on:click={() => (window.location.hash = `#/cart`)}
                class="flex-1 py-3 bg-primary text-white rounded-xl font-black text-xs uppercase tracking-widest shadow-lg shadow-primary/10"
              >
                Lihat Detail Grup
              </button>
              {#if isExpired}
                <button
                  on:click={() => groupOrderStore.clearGroup()}
                  class="px-4 py-3 bg-white border border-red-100 text-red-500 rounded-xl font-black text-xs uppercase tracking-widest shadow-sm"
                >
                  Hapus
                </button>
              {/if}
            </div>
          </div>
        {/if}

        {#if loading}
          {#each Array(3) as _}
            <div class="h-24 bg-gray-100 rounded-lg animate-pulse mb-3"></div>
          {/each}
        {:else if orders.length === 0}
          <div class="py-12 text-center text-gray-400">
            <p>Belum ada riwayat pesanan.</p>
          </div>
        {:else}
          {#each orders as order}
            {@const status = statusMap[order.status] || statusMap["pending"]}
            <div class="order-card shadow-soft rounded-lg">
              <div class="order-header">
                <span class="store-name">{order.shops?.name || "Toko"}</span>
                <span
                  class="status-badge"
                  style="color: {status.color}; background: {status.color}22"
                >
                  {status.label}
                </span>
              </div>
              <p class="order-date">
                {new Date(order.created_at).toLocaleDateString("id-ID", {
                  day: "numeric",
                  month: "short",
                  year: "numeric",
                  hour: "2-digit",
                  minute: "2-digit",
                })}
              </p>
              <div class="order-footer">
                <span class="order-total"
                  >Rp {order.total_price.toLocaleString()}</span
                >
                <div class="order-actions">
                  {#if order.order_room_id}
                    <button
                      class="action-btn action-soft"
                      on:click={() =>
                        handleCopyDraft(
                          order.order_room_id,
                          order.shops?.name || "Toko",
                        )}
                    >
                      Salin Draft
                    </button>
                  {/if}
                  <button class="action-btn action-ghost">Detail</button>
                  <button class="action-btn action-main">Pesan Lagi</button>
                </div>
              </div>
            </div>
          {/each}
        {/if}
      </div>

      {#if hasMore}
        <div class="flex justify-center mt-4 pb-4">
          <button
            class="text-xs font-bold text-primary bg-primary/5 px-4 py-2 rounded-full hover:bg-primary/10 transition-colors"
            on:click={() => fetchOrders()}
            disabled={loadingMore}
          >
            {#if loadingMore}
              Memuat...
            {:else}
              Lihat Lebih Banyak
            {/if}
          </button>
        </div>
      {/if}
    {/if}
  </main>
</div>

<style>
  .orders-page {
    display: flex;
    flex-direction: column;
    flex: 1;
  }

  .header {
    padding: 14px 16px;
    color: white;
    text-align: center;
    border-radius: 0 0 18px 18px;
    box-shadow: 0 14px 26px -24px rgba(15, 42, 68, 0.9);
  }

  .header h1 {
    margin: 0;
    font-size: 18px;
  }

  .content {
    padding: 14px;
    display: flex;
    flex-direction: column;
    flex: 1;
    background: var(--bg-soft);
  }

  /* Empty State */
  .empty-state {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    text-align: center;
    gap: 16px;
    padding: 40px 20px;
  }

  .illustration {
    font-size: 64px;
  }

  .empty-state h2 {
    font-size: 20px;
    margin: 0;
  }

  .empty-state p {
    color: var(--text-muted);
    font-size: 14px;
    margin: 0;
  }

  .actions {
    display: flex;
    flex-direction: column;
    width: 100%;
    gap: 10px;
    margin-top: 12px;
  }

  .login-btn {
    padding: 12px;
    border-radius: 8px;
    font-weight: 600;
  }

  .google-btn {
    background: var(--accent);
    color: white;
  }

  .google-btn:disabled {
    opacity: 0.5;
    cursor: not-allowed;
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

  /* Logged In */
  .tabs-scroll {
    display: flex;
    gap: 8px;
    overflow-x: auto;
    margin-bottom: 20px;
    padding: 4px;
    background: white;
    border: 1px solid #e2e8f0;
    border-radius: 14px;
  }

  .tabs-scroll::-webkit-scrollbar {
    display: none;
  }

  .tab-chip {
    white-space: nowrap;
    padding: 8px 14px;
    border-radius: 10px;
    font-size: 12px;
    font-weight: 700;
    background: transparent;
    color: var(--text-muted);
  }

  .tab-chip.active {
    background: var(--primary);
    color: white;
    box-shadow: 0 8px 14px -10px rgba(15, 42, 68, 0.8);
  }

  .order-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .order-card {
    background: white;
    padding: 16px;
    border: 1px solid #e2e8f0;
    border-radius: 14px;
    box-shadow: 0 12px 20px -24px rgba(15, 42, 68, 0.7);
    cursor: pointer;
  }

  .order-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 4px;
  }

  .store-name {
    font-weight: 700;
    font-size: 16px;
  }

  .status-badge {
    font-size: 12px;
    font-weight: 700;
    padding: 4px 8px;
    border-radius: 6px;
  }

  .order-date {
    font-size: 12px;
    color: var(--text-hint);
    margin: 0 0 16px 0;
  }

  .order-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-top: 12px;
    border-top: 1px dashed var(--bg-soft);
  }

  .order-total {
    font-weight: 700;
    font-size: 14px;
  }

  .order-actions {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
    justify-content: flex-end;
  }

  .action-btn {
    padding: 7px 11px;
    border-radius: 8px;
    font-size: 11px;
    font-weight: 700;
    border: 1px solid transparent;
  }

  .action-main {
    background: var(--accent);
    color: white;
    border-color: var(--accent);
  }

  .action-soft {
    background: var(--primary);
    color: white;
    border-color: var(--primary);
  }

  .action-ghost {
    background: white;
    color: var(--text-muted);
    border-color: #cbd5e1;
  }
</style>
