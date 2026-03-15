<script lang="ts">
  import { House, Newspaper, ReceiptText, CircleUserRound } from "lucide-svelte";
  export let activeTab: string = "home";
  export let isVisible: boolean = true;
</script>

<nav
  class="bottom-nav fixed bottom-0 left-0 right-0 z-50 transition-transform duration-300 {isVisible
    ? 'translate-y-0'
    : 'translate-y-full'}"
>
  <button
    class="nav-item {activeTab === 'home' ? 'active' : ''}"
    on:click={() => (activeTab = "home")}
  >
    <House class="icon" size={21} strokeWidth={1.8} />
    <span class="label">Beranda</span>
  </button>
  <button
    class="nav-item {activeTab === 'blog' ? 'active' : ''}"
    on:click={() => (activeTab = "blog")}
  >
    <Newspaper class="icon" size={21} strokeWidth={1.8} />
    <span class="label">Blog</span>
  </button>
  <button
    class="nav-item {activeTab === 'pesanan' ? 'active' : ''}"
    on:click={() => (activeTab = "pesanan")}
  >
    <ReceiptText class="icon" size={21} strokeWidth={1.8} />
    <span class="label">Pesanan</span>
  </button>
  <button
    class="nav-item {activeTab === 'akun' ? 'active' : ''}"
    on:click={() => (activeTab = "akun")}
  >
    <CircleUserRound class="icon" size={21} strokeWidth={1.8} />
    <span class="label">Akun</span>
  </button>
</nav>

<style>
  .bottom-nav {
    display: flex;
    justify-content: space-around;
    height: calc(68px + env(safe-area-inset-bottom, 0px));
    padding-bottom: env(safe-area-inset-bottom, 0px);
    background: rgba(250, 250, 248, 0.93);
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
    border-top: 1px solid #eceae6;
  }

  .nav-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 3px;
    background: none;
    border-radius: 0;
    padding: 0;
    color: #8896a4;
    flex: 1;
    transition: transform 0.18s ease, color 0.18s ease;
  }

  .nav-item.active {
    color: #f97316;
  }

  .nav-item:active {
    transform: scale(0.9);
  }

  .label {
    font-size: 10px;
    font-weight: 600;
  }
</style>
