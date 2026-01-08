<script lang="ts">
  export let activeTab: string = 'home';
</script>

<nav class="bottom-nav sticky-bottom shadow-soft">
  <button 
    class="nav-item {activeTab === 'home' ? 'active' : ''}" 
    on:click={() => activeTab = 'home'}
  >
    <span class="icon">🏠</span>
    <span class="label">Home</span>
  </button>
  <button 
    class="nav-item {activeTab === 'favorit' ? 'active' : ''}" 
    on:click={() => activeTab = 'favorit'}
  >
    <span class="icon">❤️</span>
    <span class="label">Favorit</span>
  </button>
  <button 
    class="nav-item {activeTab === 'pesanan' ? 'active' : ''}" 
    on:click={() => activeTab = 'pesanan'}
  >
    <span class="icon">📜</span>
    <span class="label">Pesanan</span>
  </button>
  <button 
    class="nav-item {activeTab === 'akun' ? 'active' : ''}" 
    on:click={() => activeTab = 'akun'}
  >
    <span class="icon">👤</span>
    <span class="label">Akun</span>
  </button>
</nav>

<style>
  .bottom-nav {
    display: flex;
    justify-content: space-around;
    background-color: var(--bg-white);
    padding: 8px 0;
    border-top: 1px solid var(--bg-soft);
    padding-bottom: calc(8px + env(safe-area-inset-bottom, 0px));
  }

  .nav-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    background: none;
    padding: 4px 12px;
    color: var(--text-hint);
    flex: 1;
  }

  .nav-item.active {
    color: var(--primary);
  }

  .icon {
    font-size: 20px;
    margin-bottom: 2px;
  }

  .label {
    font-size: 10px;
    font-weight: 500;
  }
</style>
