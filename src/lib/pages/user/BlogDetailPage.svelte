<script lang="ts">
    import { onMount } from "svelte";
    import { supabase } from "../../services/supabase";
    import { getOptimizedImageUrl } from "../../services/cloudinary";
    import {
        ArrowLeft,
        Calendar,
        User,
        Share2,
        ChevronRight,
    } from "lucide-svelte";
    import LoadingSpinner from "../../components/ui/LoadingSpinner.svelte";

    export let article: any;
    export let onBack: () => void;
    export let onArticleSelect: (article: any) => void;

    let otherArticles: any[] = [];
    let loadingOther = true;

    onMount(async () => {
        window.scrollTo({ top: 0, behavior: "smooth" });
        fetchOtherArticles();
    });

    async function fetchOtherArticles() {
        loadingOther = true;
        const { data } = await supabase
            .from("blog_posts")
            .select("*, author:user_profiles(full_name)")
            .eq("is_published", true)
            .neq("id", article.id)
            .limit(4);

        otherArticles = data || [];
        loadingOther = false;
    }

    function handleShare() {
        if (navigator.share) {
            navigator.share({
                title: article.title,
                text: article.excerpt,
                url: window.location.href,
            });
        } else {
            alert("Link disalin!");
        }
    }
</script>

<div class="min-h-screen bg-white pb-20">
    <!-- Sticky Header -->
    <header
        class="fixed top-0 inset-x-0 bg-white/80 backdrop-blur-lg z-40 border-b border-gray-100 px-4 py-3"
    >
        <div class="max-w-2xl mx-auto flex items-center justify-between">
            <button
                on:click={onBack}
                class="w-10 h-10 rounded-full flex items-center justify-center text-gray-900 border border-gray-200"
            >
                <ArrowLeft size={20} />
            </button>
            <div class="flex-1 px-4 truncate">
                <span
                    class="text-xs font-black text-gray-400 uppercase tracking-tighter"
                    >Membaca Artikel</span
                >
                <h1 class="text-sm font-black text-gray-900 truncate">
                    {article.title}
                </h1>
            </div>
            <button
                on:click={handleShare}
                class="w-10 h-10 rounded-full flex items-center justify-center text-primary border border-primary/20"
            >
                <Share2 size={18} />
            </button>
        </div>
    </header>

    <!-- Big Hero Image -->
    <div class="pt-16">
        <div class="aspect-[16/10] w-full relative overflow-hidden">
            <img
                src={getOptimizedImageUrl(article.cover_image || "", 1200)}
                alt={article.title}
                class="w-full h-full object-cover"
            />
            <div
                class="absolute inset-x-0 bottom-0 p-6 bg-gradient-to-t from-black/80 to-transparent text-white"
            >
                <span
                    class="inline-block bg-primary px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest mb-3"
                >
                    {article.category}
                </span>
                <h1 class="text-2xl font-black leading-tight drop-shadow-md">
                    {article.title}
                </h1>
            </div>
        </div>
    </div>

    <main class="max-w-2xl mx-auto px-6 py-8">
        <!-- Meta Info -->
        <div
            class="flex items-center gap-6 pb-6 border-b border-gray-100 mb-8 overflow-x-auto no-scrollbar"
        >
            <div class="flex items-center gap-2 flex-shrink-0">
                <div
                    class="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center text-gray-400"
                >
                    <User size={16} />
                </div>
                <div>
                    <p class="text-[10px] text-gray-400 font-bold uppercase">
                        Penulis
                    </p>
                    <p class="text-xs font-black text-gray-900 leading-none">
                        {article.author?.full_name || "Admin OrbFood"}
                    </p>
                </div>
            </div>
            <div class="flex items-center gap-2 flex-shrink-0">
                <div
                    class="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center text-gray-400"
                >
                    <Calendar size={16} />
                </div>
                <div>
                    <p class="text-[10px] text-gray-400 font-bold uppercase">
                        Diterbitkan
                    </p>
                    <p class="text-xs font-black text-gray-900 leading-none">
                        {new Date(article.created_at).toLocaleDateString(
                            "id-ID",
                            {
                                day: "numeric",
                                month: "long",
                                year: "numeric",
                            },
                        )}
                    </p>
                </div>
            </div>
        </div>

        <!-- Article Content -->
        <article
            class="prose prose-sm max-w-none text-gray-700 leading-relaxed font-normal"
        >
            {#each article.content.split("\n") as paragraph}
                {#if paragraph.trim() !== ""}
                    <p class="mb-4">{paragraph}</p>
                {/if}
            {/each}
        </article>

        <!-- Other Posts Section -->
        <section class="mt-16 pt-12 border-t-2 border-dashed border-gray-100">
            <div class="flex items-center justify-between mb-6">
                <h2 class="text-xl font-black text-gray-900 tracking-tight">
                    Artikel Menarik Lainnya
                </h2>
            </div>

            {#if loadingOther}
                <div class="flex justify-center p-8">
                    <LoadingSpinner />
                </div>
            {:else}
                <div class="grid gap-4">
                    {#each otherArticles as other}
                        <!-- svelte-ignore a11y-click-events-have-key-events -->
                        <!-- svelte-ignore a11y-no-static-element-interactions -->
                        <div
                            class="flex gap-4 items-center group cursor-pointer"
                            on:click={() => {
                                onArticleSelect(other);
                                window.scrollTo({ top: 0, behavior: "smooth" });
                            }}
                        >
                            <div
                                class="w-20 h-20 rounded-2xl overflow-hidden flex-shrink-0 shadow-sm"
                            >
                                <img
                                    src={getOptimizedImageUrl(
                                        other.cover_image || "",
                                        200,
                                    )}
                                    alt={other.title}
                                    class="w-full h-full object-cover transition-transform group-hover:scale-110"
                                />
                            </div>
                            <div class="flex-1 space-y-1">
                                <span
                                    class="text-[9px] font-black text-primary uppercase"
                                    >{other.category}</span
                                >
                                <h4
                                    class="text-sm font-black text-gray-800 line-clamp-2 leading-tight"
                                >
                                    {other.title}
                                </h4>
                            </div>
                            <ChevronRight size={18} class="text-gray-300" />
                        </div>
                    {/each}
                </div>
            {/if}
        </section>
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

    article p {
        font-size: 15px;
        line-height: 1.6;
        color: #4a5568;
    }
</style>
