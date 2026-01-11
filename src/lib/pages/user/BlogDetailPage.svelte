<script lang="ts">
    import { onMount } from "svelte";
    import { getOptimizedImageUrl } from "../../services/cloudinary";
    import { ChevronLeft, Calendar, User, Tag, Share2 } from "lucide-svelte";
    // import { marked } from "marked"; // Removed to avoid missing dependency

    export let article: any;
    export let onBack: () => void;

    let contentHtml = "";

    onMount(() => {
        if (article.content) {
            // Simple custom parser to avoid external dependencies
            contentHtml = article.content
                .replace(/\n/g, "<br/>")
                .replace(/\*\*(.*?)\*\*/g, "<strong>$1</strong>");
        }
    });

    function handleShare() {
        if (navigator.share) {
            navigator.share({
                title: article.title,
                text: article.excerpt,
                url: window.location.href,
            });
        } else {
            navigator.clipboard.writeText(window.location.href);
            alert("Link berhasil disalin!");
        }
    }
</script>

<div class="blog-detail-page bg-white min-h-screen pb-20">
    <!-- Header -->
    <header
        class="fixed top-0 left-0 right-0 z-50 bg-white/80 backdrop-blur-md border-b border-gray-100"
    >
        <div
            class="max-w-2xl mx-auto px-4 py-3 flex items-center justify-between"
        >
            <button
                on:click={onBack}
                class="p-2 hover:bg-gray-100 rounded-full transition-colors"
            >
                <ChevronLeft size={24} class="text-gray-700" />
            </button>
            <div class="flex gap-2">
                <button
                    on:click={handleShare}
                    class="p-2 hover:bg-gray-100 rounded-full transition-colors"
                >
                    <Share2 size={20} class="text-gray-500" />
                </button>
            </div>
        </div>
    </header>

    <main class="pt-16 max-w-2xl mx-auto px-4">
        <!-- Cover Image -->
        {#if article.cover_image}
            <div
                class="aspect-video w-full rounded-3xl overflow-hidden shadow-lg mb-6"
            >
                <img
                    src={getOptimizedImageUrl(article.cover_image, 800)}
                    alt={article.title}
                    class="w-full h-full object-cover"
                />
            </div>
        {/if}

        <!-- Meta Tags -->
        <div class="flex items-center gap-2 mb-4">
            <span
                class="px-3 py-1 bg-primary/10 text-primary text-xs font-bold rounded-full uppercase tracking-wider"
            >
                {article.category}
            </span>
            <span class="text-xs text-gray-400 flex items-center gap-1">
                <Calendar size={12} />
                {new Date(article.created_at).toLocaleDateString("id-ID", {
                    day: "numeric",
                    month: "long",
                    year: "numeric",
                })}
            </span>
        </div>

        <!-- Title -->
        <h1 class="text-3xl font-black text-gray-900 leading-tight mb-4">
            {article.title}
        </h1>

        <!-- Author -->
        {#if article.user_profiles?.display_name || article.author?.display_name}
            <div
                class="flex items-center gap-3 mb-8 border-b border-gray-100 pb-6"
            >
                <div
                    class="w-10 h-10 bg-gray-100 rounded-full flex items-center justify-center"
                >
                    <User size={20} class="text-gray-400" />
                </div>
                <div>
                    <p class="text-sm font-bold text-gray-900">
                        {article.user_profiles?.display_name ||
                            article.author?.display_name}
                    </p>
                    <p class="text-xs text-gray-500">Penulis</p>
                </div>
            </div>
        {/if}

        <!-- Content -->
        <article
            class="prose prose-gray max-w-none text-gray-700 leading-relaxed space-y-4"
        >
            <!-- Safe HTML render -->
            {@html contentHtml}
        </article>
    </main>
</div>
