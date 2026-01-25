<script lang="ts">
  import { onMount } from "svelte";
  import { supabase, getAuthRedirectUrl } from "../../services/supabase";
  export let user: any = null;

  let activeTab = "Semua";
  const tabs = ["Semua", "Diproses", "Selesai", "Batal"];

  let orders: any[] = [];
  let loading = true;
  let agreed = false;

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
      .select("id, user_id, status, total_price, created_at, shops(name)")
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
                  <button class="action-btn text-muted">Detail</button>
                  <button class="action-btn bg-accent">Pesan Lagi</button>
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
    padding: 16px;
    color: white;
    text-align: center;
  }

  .header h1 {
    margin: 0;
    font-size: 18px;
  }

  .content {
    padding: 16px;
    display: flex;
    flex-direction: column;
    flex: 1;
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
    padding-bottom: 4px;
  }

  .tabs-scroll::-webkit-scrollbar {
    display: none;
  }

  .tab-chip {
    white-space: nowrap;
    padding: 8px 16px;
    border-radius: 20px;
    font-size: 13px;
    font-weight: 600;
    background: var(--bg-soft);
    color: var(--text-muted);
  }

  .tab-chip.active {
    background: var(--primary);
    color: white;
  }

  .order-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .order-card {
    background: white;
    padding: 16px;
    border: 1px solid var(--bg-soft);
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
  }

  .action-btn {
    padding: 6px 12px;
    border-radius: 6px;
    font-size: 12px;
    font-weight: 600;
  }

  .action-btn.bg-accent {
    color: white;
  }
</style>
