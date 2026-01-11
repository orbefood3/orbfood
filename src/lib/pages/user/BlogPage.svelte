<script lang="ts">
  import { onMount } from "svelte";
  import { supabase } from "../../services/supabase";
  import LoadingSpinner from "../../components/ui/LoadingSpinner.svelte";
  import { getOptimizedImageUrl } from "../../services/cloudinary";
  import { Search, ChevronRight, Calendar, User, Tag } from "lucide-svelte";

  export let onArticleSelect: (article: any) => void;

  let articles: any[] = [];
  let loading = true;
  let searchQuery = "";
  let selectedCategory = "all";

  const categories = [
    { value: "all", label: "Semua", icon: "🌟" },
    { value: "kuliner", label: "Kuliner", icon: "🍱" },
    { value: "tips", label: "Tips & Trik", icon: "💡" },
    { value: "promo", label: "Promo", icon: "🏷️" },
    { value: "serba-serbi", label: "Serba-serbi", icon: "🌈" },
    { value: "berita", label: "Berita", icon: "📰" },
  ];

  onMount(fetchArticles);

  async function fetchArticles() {
    loading = true;
    const { data } = await supabase
      .from("blog_posts")
      .select("*, author:user_profiles(display_name)")
      .eq("status", "published")
      .order("created_at", { ascending: false });

    articles = data || [];
    loading = false;
  }

  $: filteredArticles = articles.filter((a) => {
    const matchSearch =
      searchQuery.trim() === "" ||
      a.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      a.excerpt?.toLowerCase().includes(searchQuery.toLowerCase());
    const matchCategory =
      selectedCategory === "all" || a.category === selectedCategory;
    return matchSearch && matchCategory;
  });

  $: featuredArticle = filteredArticles[0];
  $: normalArticles = filteredArticles.slice(1);
</script>

<div class="blog-container bg-gray-50 pb-24">
  <!-- Header Section -->
  <header class="bg-white border-b border-gray-100 sticky top-0 z-30 px-4 py-4">
    <div class="max-w-2xl mx-auto space-y-4">
      <div class="flex items-center justify-between">
        <h1 class="text-2xl font-black text-gray-900 tracking-tight">
          OrbFood <span class="text-primary">Blog</span>
        </h1>
        <div
          class="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center text-primary"
        >
          <User size={20} />
        </div>
      </div>

      <!-- Search Bar -->
      <div class="relative">
        <Search
          class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"
          size={18}
        />
        <input
          type="text"
          bind:value={searchQuery}
          placeholder="Cari artikel menarik..."
          class="w-full bg-gray-100 border-none rounded-2xl py-3 pl-10 pr-4 text-sm focus:ring-2 focus:ring-primary transition-all outline-none"
        />
      </div>
    </div>
  </header>

  <!-- Categories Section -->
  <div
    class="bg-white border-b border-gray-100 overflow-x-auto no-scrollbar py-3"
  >
    <div class="flex gap-2 px-4 max-w-2xl mx-auto">
      {#each categories as cat}
        <button
          on:click={() => (selectedCategory = cat.value)}
          class="flex-shrink-0 flex items-center gap-1.5 px-4 py-2 rounded-full text-xs font-bold transition-all border
          {selectedCategory === cat.value
            ? 'bg-primary border-primary text-white shadow-lg shadow-primary/20 scale-105'
            : 'bg-white border-gray-100 text-gray-600 hover:border-primary/50'}"
        >
          <span>{cat.icon}</span>
          {cat.label}
        </button>
      {/each}
    </div>
  </div>

  <main class="max-w-2xl mx-auto px-4 py-6 space-y-8">
    {#if loading}
      <div class="flex flex-col items-center justify-center py-20 gap-4">
        <LoadingSpinner />
        <p class="text-gray-400 text-sm font-medium">
          Menjangkau berita terbaru...
        </p>
      </div>
    {:else if filteredArticles.length === 0}
      <div
        class="flex flex-col items-center justify-center py-20 text-center gap-6"
      >
        <div
          class="w-24 h-24 bg-gray-100 rounded-full flex items-center justify-center text-5xl"
        >
          🏜️
        </div>
        <div class="space-y-1">
          <h3 class="font-bold text-gray-900">Artikel tidak ditemukan</h3>
          <p class="text-gray-500 text-sm">
            Coba kata kunci atau kategori lain.
          </p>
        </div>
        <button
          on:click={() => {
            searchQuery = "";
            selectedCategory = "all";
          }}
          class="text-primary font-bold text-sm"
        >
          Reset Filter
        </button>
      </div>
    {:else}
      <!-- Featured Post -->
      {#if featuredArticle && searchQuery === "" && selectedCategory === "all"}
        <button
          class="featured-post group cursor-pointer w-full p-0 border-none bg-transparent text-left"
          on:click={() => onArticleSelect(featuredArticle)}
        >
          <div
            class="relative aspect-[16/9] rounded-3xl overflow-hidden shadow-xl mb-4"
          >
            <img
              src={getOptimizedImageUrl(featuredArticle.cover_image || "", 800)}
              alt={featuredArticle.title}
              class="w-full h-full object-cover transition-transform duration-700 group-hover:scale-110"
            />
            <div
              class="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent"
            ></div>
            <div class="absolute bottom-6 left-6 right-6 text-white space-y-2">
              <span
                class="bg-primary px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-wider"
              >
                Terpopuler
              </span>
              <h2 class="text-xl font-black leading-tight text-white">
                {featuredArticle.title}
              </h2>
            </div>
          </div>
        </button>
      {/if}

      <!-- Article List -->
      <div class="grid gap-6">
        {#each searchQuery !== "" || selectedCategory !== "all" ? filteredArticles : normalArticles as article}
          <button
            class="bg-white rounded-3xl p-4 flex gap-4 shadow-soft border border-gray-100/50 hover:shadow-lg transition-all active:scale-[0.98] cursor-pointer w-full text-left appearance-none"
            on:click={() => onArticleSelect(article)}
          >
            <div
              class="w-24 h-24 flex-shrink-0 rounded-2xl overflow-hidden shadow-sm"
            >
              <img
                src={getOptimizedImageUrl(article.cover_image || "", 300)}
                alt={article.title}
                class="w-full h-full object-cover"
              />
            </div>
            <div class="flex-1 flex flex-col justify-between py-1">
              <div class="space-y-1">
                <div class="flex items-center gap-2">
                  <span
                    class="text-[9px] font-black text-primary uppercase tracking-widest px-1.5 py-0.5 bg-primary/5 rounded"
                  >
                    {article.category}
                  </span>
                </div>
                <h3
                  class="text-sm font-black text-gray-900 leading-snug line-clamp-2"
                >
                  {article.title}
                </h3>
              </div>
              <div
                class="flex items-center gap-3 text-[10px] text-gray-400 font-medium"
              >
                <span class="flex items-center gap-1">
                  <Calendar size={10} />
                  {new Date(article.created_at).toLocaleDateString("id-ID", {
                    month: "short",
                    day: "numeric",
                  })}
                </span>
                {#if article.author?.display_name}
                  <span class="flex items-center gap-1">
                    <User size={10} />
                    {article.author.display_name}
                  </span>
                {/if}
              </div>
            </div>
            <div class="flex items-center pr-1">
              <div class="p-2 bg-gray-50 rounded-full text-gray-300">
                <ChevronRight size={16} />
              </div>
            </div>
          </button>
        {/each}
      </div>
    {/if}
  </main>
</div>

<style>
  .no-scrollbar::-webkit-scrollbar {
    display: none;
  }
  .no-scrollbar {
    -ms-overflow-style: none;
    scrollbar-width: none;
  }
</style>
