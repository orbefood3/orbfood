<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase } from './lib/supabase';
  import HomePage from './lib/HomePage.svelte';
  import StorePage from './lib/StorePage.svelte';
  import BottomNav from './lib/BottomNav.svelte';
  import PlaceholderPage from './lib/PlaceholderPage.svelte';
  import './app.css';

  let activeTab = 'home';
  let selectedStore: any = null;
  let user: any = null;

  onMount(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      user = session?.user ?? null;
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      user = session?.user ?? null;
    });

    return () => subscription.unsubscribe();
  });

  function handleStoreSelect(store: any) {
    selectedStore = store;
  }

  function handleBack() {
    selectedStore = null;
  }
</script>

<main id="main-content">
  {#if selectedStore}
    <StorePage store={selectedStore} onBack={handleBack} />
  {:else}
    {#if activeTab === 'home'}
      <HomePage onStoreSelect={handleStoreSelect} />
    {:else if activeTab === 'favorit'}
      <PlaceholderPage title="Favorit Saya" {user} />
    {:else if activeTab === 'pesanan'}
      <PlaceholderPage title="Riwayat Pesanan" {user} />
    {:else if activeTab === 'akun'}
      {#if user}
        <div class="profile-page">
          <div class="header bg-primary">
            <h1>Profil Saya</h1>
          </div>
          <div class="content">
            <img src={user.user_metadata.avatar_url} alt="Avatar" class="avatar" />
            <h2>{user.user_metadata.full_name}</h2>
            <p>{user.email}</p>
            <button class="logout-btn" on:click={() => supabase.auth.signOut()}>Logout</button>
          </div>
        </div>
      {:else}
        <PlaceholderPage title="Profil Saya" {user} />
      {/if}
    {/if}
  {/if}
</main>

{#if !selectedStore}
  <BottomNav bind:activeTab />
{/if}

<style>
  .profile-page {
    display: flex;
    flex-direction: column;
    flex: 1;
    text-align: center;
  }

  .header {
    padding: 20px;
    color: white;
  }

  .header h1 {
    margin: 0;
    font-size: 20px;
  }

  .content {
    padding: 40px 20px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 12px;
  }

  .avatar {
    width: 80px;
    height: 80px;
    border-radius: 50%;
    margin-bottom: 8px;
  }

  .logout-btn {
    margin-top: 24px;
    padding: 10px 20px;
    color: var(--danger);
    background: none;
    font-weight: 600;
  }

  #main-content {
    flex: 1;
    display: flex;
    flex-direction: column;
    overflow-y: auto;
    padding-bottom: 20px;
    -webkit-overflow-scrolling: touch;
  }
</style>
