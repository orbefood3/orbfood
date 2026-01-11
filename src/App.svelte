<script lang="ts">
  import { onMount } from "svelte";
  import { supabase } from "./lib/services/supabase";
  import HomePage from "./lib/pages/user/HomePage.svelte";
  import StorePage from "./lib/pages/user/StorePage.svelte";
  import BlogPage from "./lib/pages/user/BlogPage.svelte";
  import BlogDetailPage from "./lib/pages/user/BlogDetailPage.svelte";
  import OrdersPage from "./lib/pages/user/OrdersPage.svelte";
  import ProfilePage from "./lib/pages/user/ProfilePage.svelte";
  import CartPage from "./lib/pages/user/CartPage.svelte";
  import CartBar from "./lib/components/navigation/CartBar.svelte";
  import BukaTokoPage from "./lib/pages/user/BukaTokoPage.svelte";
  import ShopDashboard from "./lib/pages/shop/ShopDashboard.svelte";
  import AdminDashboard from "./lib/pages/admin/AdminDashboard.svelte";
  import BottomNav from "./lib/components/navigation/BottomNav.svelte";
  import PlaceholderPage from "./lib/pages/user/PlaceholderPage.svelte";
  import PrivacyPolicyPage from "./lib/pages/legal/PrivacyPolicyPage.svelte";
  import TermsOfServicePage from "./lib/pages/legal/TermsOfServicePage.svelte";
  import ToastContainer from "./lib/components/ui/ToastContainer.svelte";
  import "./app.css";

  let activeTab = "home";
  let selectedStore: any = null;
  let selectedArticle: any = null;
  let showCart = false;
  let showBukaToko = false;
  let currentLegalPage: "privacy" | "terms" | null = null;
  let user: any = null;
  let profile: any = null;

  let isNavVisible = true;

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

    const hideNav = () => (isNavVisible = false);
    const showNav = () => (isNavVisible = true);

    window.addEventListener("hide-nav", hideNav);
    window.addEventListener("show-nav", showNav);

    // Initial routing handle
    handleHashChange();
    window.addEventListener("hashchange", handleHashChange);

    return () => {
      subscription.unsubscribe();
      window.removeEventListener("hide-nav", hideNav);
      window.removeEventListener("show-nav", showNav);
      window.removeEventListener("hashchange", handleHashChange);
    };
  });

  async function handleHashChange() {
    const hash = window.location.hash;
    if (hash.startsWith("#/shop/")) {
      const slug = hash.replace("#/shop/", "");
      if (selectedStore?.slug !== slug) {
        const { data } = await supabase
          .from("shops")
          .select("*")
          .eq("slug", slug)
          .single();
        if (data) selectedStore = data;
      }
    } else if (hash.startsWith("#/blog/")) {
      const slug = hash.replace("#/blog/", "");
      if (selectedArticle?.slug !== slug) {
        const { data } = await supabase
          .from("blog_posts")
          .select("*")
          .eq("slug", slug)
          .single();
        if (data) {
          selectedArticle = data;
          activeTab = "blog";
        }
      }
    } else if (hash === "" || hash === "#/") {
      selectedStore = null;
      selectedArticle = null;
      currentLegalPage = null;
    } else if (hash === "#/blog") {
      selectedArticle = null;
      activeTab = "blog";
      currentLegalPage = null;
    } else if (hash === "#/privacy") {
      currentLegalPage = "privacy";
    } else if (hash === "#/terms") {
      currentLegalPage = "terms";
    }
  }

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
    window.location.hash = `#/shop/${store.slug}`;
  }

  function handleBack() {
    selectedStore = null;
    selectedArticle = null;
    window.location.hash = "#/";
  }

  function handleArticleSelect(article: any) {
    selectedArticle = article;
    window.location.hash = `#/blog/${article.slug || article.id}`;
  }

  function handleArticleBack() {
    selectedArticle = null;
    window.location.hash = "#/blog";
  }

  function handleBlogBack() {
    selectedArticle = null;
    window.location.hash = "#/blog";
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
  {#if currentLegalPage === "privacy"}
    <PrivacyPolicyPage
      onBack={() => {
        currentLegalPage = null;
        window.location.hash = "#/";
      }}
    />
  {:else if currentLegalPage === "terms"}
    <TermsOfServicePage
      onBack={() => {
        currentLegalPage = null;
        window.location.hash = "#/";
      }}
    />
  {:else if profile?.role === "shop"}
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
  {:else if activeTab === "blog"}
    {#if selectedArticle}
      <BlogDetailPage article={selectedArticle} onBack={handleArticleBack} />
    {:else}
      <BlogPage onArticleSelect={handleArticleSelect} />
    {/if}
  {:else if activeTab === "home"}
    <HomePage onStoreSelect={handleStoreSelect} />
  {:else if activeTab === "pesanan"}
    <OrdersPage {user} />
  {:else if activeTab === "akun"}
    {#if user}
      <ProfilePage
        {user}
        {profile}
        onBukaToko={handleBukaToko}
        onNavigate={(tab) => (activeTab = tab)}
      />
    {:else}
      <PlaceholderPage title="Profil Saya" {user} />
    {/if}
  {/if}
</main>

{#if !selectedStore && !selectedArticle && !showCart && !showBukaToko && !currentLegalPage && profile?.role !== "shop" && profile?.role !== "admin"}
  <BottomNav bind:activeTab isVisible={isNavVisible} />
{/if}

<ToastContainer />

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
