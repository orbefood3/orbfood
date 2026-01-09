<script lang="ts">
  import { supabase } from '../../services/supabase';
  export let user: any;
  export let onBack: () => void;
  export let onSuccess: () => void;

  let name = "";
  let village = "";
  let whatsapp = "";
  let loading = false;
  let submitted = false;

  async function handleSubmit() {
    if (!name || !whatsapp || !village) {
      alert("Mohon isi semua data");
      return;
    }

    loading = true;
    const slug = name.toLowerCase().replace(/[^a-z0-9]/g, '-');
    
    const { error } = await supabase.from('shops').insert({
      owner_id: user.id,
      name,
      slug,
      category: 'makanan', // Default category
      whatsapp,
      phone: whatsapp,
      address: village, // Village used as address
      is_verified: false,
      is_active: true
    });

    loading = false;
    if (error) {
      alert("Error: " + error.message);
    } else {
      submitted = true;
    }
  }
</script>

<div class="registration-page">
  <header class="header bg-primary sticky-top">
    <button class="back-btn" on:click={onBack}>←</button>
    <h1>Buka Toko</h1>
  </header>

  <main class="content">
    {#if submitted}
      <div class="status-feedback">
        <div class="illustration">⏳</div>
        <h2>Pengajuan Toko Dikirim</h2>
        <p>Toko Anda sedang menunggu verifikasi admin.</p>
        <button class="bg-accent" on:click={onSuccess}>Kembali ke Profil</button>
      </div>
    {:else}
      <div class="form-card rounded-lg shadow-soft">
        <div class="input-group">
          <label for="name">Nama Toko</label>
          <input type="text" id="name" bind:value={name} placeholder="Contoh: Warung Bu Sari" />
        </div>

        <div class="input-group">
          <label for="village">Desa</label>
          <input type="text" id="village" bind:value={village} placeholder="Contoh: Desa Sukamaju" />
        </div>

        <div class="input-group">
          <label for="wa">No WhatsApp</label>
          <input type="tel" id="wa" bind:value={whatsapp} placeholder="Contoh: 08123456789" />
        </div>

        <button class="submit-btn bg-accent" on:click={handleSubmit} disabled={loading}>
          {loading ? 'Mengirim...' : 'AJUKAN TOKO'}
        </button>
      </div>
    {/if}
  </main>
</div>

<style>
  .registration-page {
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
  }

  .content {
    padding: 20px;
    display: flex;
    flex-direction: column;
    gap: 20px;
    flex: 1;
  }

  .form-card {
    background: white;
    padding: 20px;
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
    font-size: 13px;
    font-weight: 700;
  }

  .input-group input, .input-group select, .input-group textarea {
    padding: 12px;
    border: 1px solid #ddd;
    border-radius: 8px;
    font-size: 14px;
    background: white;
  }

  .flex-row {
    display: flex;
    gap: 12px;
  }

  .flex-row .input-group {
    flex: 1;
  }

  .submit-btn {
    margin-top: 12px;
    padding: 14px;
    border-radius: 12px;
    color: white;
    font-weight: 800;
  }

  .status-feedback {
    text-align: center;
    padding: 60px 20px;
    background: white;
    border-radius: 12px;
    box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1);
  }

  .illustration {
    font-size: 64px;
    margin-bottom: 16px;
  }

  .status-feedback h2 {
    font-size: 20px;
    margin-bottom: 8px;
  }

  .status-feedback p {
    color: var(--text-muted);
    font-size: 14px;
    margin-bottom: 24px;
  }

  .status-feedback button {
    padding: 12px 24px;
    border-radius: 20px;
    font-weight: 700;
    color: white;
  }
</style>
