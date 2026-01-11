<script lang="ts">
  import logo from "../../../assets/logo-orb.png";
  export let activeTab: string = "home";
  export let isVisible: boolean = true;
</script>

<nav
  class="bottom-nav sticky-bottom shadow-soft transition-transform duration-300 {isVisible
    ? 'translate-y-0'
    : 'translate-y-full'}"
>
  <button
    class="nav-item {activeTab === 'home' ? 'active' : ''}"
    on:click={() => (activeTab = "home")}
  >
    <span class="icon">🏠</span>
    <span class="label">Beranda</span>
  </button>
  <button
    class="nav-item {activeTab === 'blog' ? 'active' : ''}"
    on:click={() => (activeTab = "blog")}
  >
    <span class="icon">🗞️</span>
    <span class="label">Blog</span>
  </button>
  <button
    class="nav-item {activeTab === 'pesanan' ? 'active' : ''}"
    on:click={() => (activeTab = "pesanan")}
  >
    <span class="icon">📜</span>
    <span class="label">Pesanan</span>
  </button>
  <button
    class="nav-item {activeTab === 'akun' ? 'active' : ''}"
    on:click={() => (activeTab = "akun")}
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
