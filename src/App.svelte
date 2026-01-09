<script lang="ts">
  import { onMount } from "svelte";
  import { supabase } from "./lib/services/supabase";
  import HomePage from "./lib/pages/user/HomePage.svelte";
  import StorePage from "./lib/pages/user/StorePage.svelte";
  import BlogPage from "./lib/pages/user/BlogPage.svelte";
  import OrdersPage from "./lib/pages/user/OrdersPage.svelte";
  import ProfilePage from "./lib/pages/user/ProfilePage.svelte";
  import CartPage from "./lib/pages/user/CartPage.svelte";
  import CartBar from "./lib/components/navigation/CartBar.svelte";
  import BukaTokoPage from "./lib/pages/user/BukaTokoPage.svelte";
  import ShopDashboard from "./lib/pages/shop/ShopDashboard.svelte";
  import AdminDashboard from "./lib/pages/admin/AdminDashboard.svelte";
  import BottomNav from "./lib/components/navigation/BottomNav.svelte";
  import PlaceholderPage from "./lib/pages/user/PlaceholderPage.svelte";
  import "./app.css";

  let activeTab = "home";
  let selectedStore: any = null;
  let showCart = false;
  let showBukaToko = false;
  let user: any = null;
  let profile: any = null;

  onMount(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      user = session?.user ?? null;
      if (user) {
        fetchProfile();
        setupProfileListener();
      }
    });

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      user = session?.user ?? null;
      if (user) {
        fetchProfile();
        setupProfileListener();
      } else {
        profile = null;
      }
    });

    return () => {
      subscription.unsubscribe();
    };
  });

  let profileSubscription: any = null;

  function setupProfileListener() {
    if (profileSubscription) profileSubscription.unsubscribe();

    profileSubscription = supabase
      .channel("profile-changes")
      .on(
        "postgres_changes",
        {
          event: "*",
          schema: "public",
          table: "user_profiles",
          filter: `id=eq.${user.id}`,
        },
        (payload) => {
          profile = payload.new;
        },
      )
      .subscribe();
  }

  async function fetchProfile() {
    const { data } = await supabase
      .from("user_profiles")
      .select("*")
      .eq("id", user.id)
      .single();
    profile = data;
  }

  function handleStoreSelect(store: any) {
    selectedStore = store;
  }

  function handleBack() {
    selectedStore = null;
  }

  function handleViewCart() {
    showCart = true;
  }

  function handleCloseCart() {
    showCart = false;
  }

  function handleBukaToko() {
    showBukaToko = true;
  }
</script>

<svelte:head>
  {#if profile?.role === "admin"}
    <script>
      document.getElementById("app")?.classList.add("admin-mode");
    </script>
  {:else if profile?.role === "shop"}
    <script>
      document.getElementById("app")?.classList.add("shop-mode");
    </script>
  {/if}
</svelte:head>

<main
  id="main-content"
  class:full-width={profile?.role === "admin" || profile?.role === "shop"}
>
  {#if profile?.role === "shop"}
    <ShopDashboard {user} {profile} />
  {:else if profile?.role === "admin"}
    <AdminDashboard />
  {:else if showCart}
    <CartPage {user} onBack={handleCloseCart} />
  {:else if showBukaToko}
    <BukaTokoPage
      {user}
      onBack={() => (showBukaToko = false)}
      onSuccess={() => (showBukaToko = false)}
    />
  {:else if selectedStore}
    <StorePage
      store={selectedStore}
      onBack={handleBack}
      onViewCart={handleViewCart}
    />
  {:else if activeTab === "home"}
    <HomePage onStoreSelect={handleStoreSelect} />
  {:else if activeTab === "blog"}
    <BlogPage />
  {:else if activeTab === "pesanan"}
    <OrdersPage {user} />
  {:else if activeTab === "akun"}
    {#if user}
      <ProfilePage {user} {profile} onBukaToko={handleBukaToko} />
    {:else}
      <PlaceholderPage title="Profil Saya" {user} />
    {/if}
  {/if}
</main>

{#if !selectedStore && !showCart && !showBukaToko && profile?.role !== "shop" && profile?.role !== "admin"}
  <BottomNav bind:activeTab />
{/if}

<style>
  #main-content {
    flex: 1;
    display: flex;
    flex-direction: column;
    overflow-y: auto;
    padding-bottom: 20px;
    -webkit-overflow-scrolling: touch;
  }

  #main-content.full-width {
    width: 100%;
    max-width: none;
    padding-bottom: 0;
  }
</style>
