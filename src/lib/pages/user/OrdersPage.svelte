<script lang="ts">
  import { supabase } from '../../services/supabase';
  export let user: any = null;

  let activeTab = 'Semua';
  const tabs = ['Semua', 'Diproses', 'Selesai', 'Batal'];

  const mockOrders = [
    { store: "Sate Bang Kumis", status: "Selesai", date: "8 Jan 2024, 12:30", total: 45000, color: "var(--success)" },
    { store: "Es Teh Jumbo", status: "Diproses", date: "8 Jan 2024, 14:15", total: 10000, color: "var(--accent)" },
    { store: "Bakso Granat", status: "Batal", date: "7 Jan 2024, 19:00", total: 25000, color: "var(--danger)" },
  ];

  async function loginWithGoogle() {
    await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: { redirectTo: window.location.origin }
    });
  }
</script>

<div class="orders-page">
  <header class="header bg-primary sticky-top shadow-soft">
    <h1>Riwayat Pesanan</h1>
  </header>

  <main class="content">
    {#if !user}
      <div class="empty-state">
        <div class="illustration">🍱</div>
        <h2>Masuk untuk melihat riwayat pesanan</h2>
        <p>Login agar riwayat pesanan dan ulasan kamu tersimpan rapi di sini.</p>
        <div class="actions">
          <button class="login-btn google-btn" on:click={loginWithGoogle}>
            Login dengan Google
          </button>
          <button class="login-btn wa-btn">
            Login dengan WhatsApp
          </button>
        </div>
      </div>
    {:else}
      <section class="tabs-scroll">
        {#each tabs as tab}
          <button 
            class="tab-chip {activeTab === tab ? 'active' : ''}" 
            on:click={() => activeTab = tab}
          >
            {tab}
          </button>
        {/each}
      </section>

      <div class="order-list">
        {#each mockOrders as order}
          <div class="order-card shadow-soft rounded-lg">
            <div class="order-header">
              <span class="store-name">{order.store}</span>
              <span class="status-badge" style="color: {order.color}; background: {order.color}22">
                {order.status}
              </span>
            </div>
            <p class="order-date">{order.date}</p>
            <div class="order-footer">
              <span class="order-total">Rp {order.total.toLocaleString()}</span>
              <div class="order-actions">
                <button class="action-btn text-muted">Detail</button>
                <button class="action-btn bg-accent">Pesan Lagi</button>
              </div>
            </div>
          </div>
        {/each}
      </div>
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

  .wa-btn {
    background: #25D366;
    color: white;
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
