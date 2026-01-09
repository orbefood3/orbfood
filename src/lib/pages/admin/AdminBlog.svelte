<script lang="ts">
  import { onMount } from "svelte";
  import { supabase } from "../../services/supabase";
  import LoadingSpinner from "../../components/ui/LoadingSpinner.svelte";
  import PageWrapper from "../../components/ui/PageWrapper.svelte";

  let posts: any[] = [];
  let loading = true;
  let showEditor = false;
  let currentPost: any = { title: "", content: "", status: "draft" };

  onMount(fetchPosts);

  async function fetchPosts() {
    loading = true;
    const { data } = await supabase
      .from("blog_posts")
      .select("*")
      .order("created_at", { ascending: false });
    posts = data || [];
    loading = false;
  }

  async function savePost() {
    if (!currentPost.title || !currentPost.content) {
      alert("Judul dan isi tidak boleh kosong");
      return;
    }

    const { error } = await supabase.from("blog_posts").upsert({
      ...currentPost,
      slug: currentPost.title
        .toLowerCase()
        .replace(/ /g, "-")
        .replace(/[^\w-]+/g, ""),
    });

    if (error) {
      alert("Error saving post: " + error.message);
    } else {
      alert("Artikel disimpan!");
      showEditor = false;
      fetchPosts();
    }
  }

  function editPost(post: any) {
    currentPost = { ...post };
    showEditor = true;
  }

  function createNew() {
    currentPost = { title: "", content: "", status: "draft" };
    showEditor = true;
  }
</script>

<div>
  <div class="flex justify-between items-center mb-6">
    <div class="space-y-1">
      <h2 class="text-2xl font-bold tracking-tight text-gray-900">
        Blog & Artikel
      </h2>
      <p class="text-gray-500 text-sm">
        Kelola konten berita dan tips untuk pengguna.
      </p>
    </div>
    <button
      on:click={createNew}
      class="inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-white transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-gray-950 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 bg-gray-900 text-gray-50 hover:bg-gray-900/90 h-9 px-4 py-2 shadow"
    >
      + Tulis Artikel
    </button>
  </div>

  {#if showEditor}
    <div
      class="bg-white p-6 rounded-xl shadow-sm border border-gray-200 mb-6 space-y-4"
    >
      <div class="grid gap-2">
        <label for="post_title" class="text-sm font-medium leading-none"
          >Judul Artikel</label
        >
        <input
          id="post_title"
          bind:value={currentPost.title}
          placeholder="Masukkan judul menarik..."
          class="flex h-10 w-full rounded-md border border-gray-200 bg-white px-3 py-2 text-sm ring-offset-white file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-gray-500 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-gray-950 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
        />
      </div>

      <div class="grid gap-2">
        <label for="post_content" class="text-sm font-medium leading-none"
          >Konten</label
        >
        <textarea
          id="post_content"
          bind:value={currentPost.content}
          placeholder="Tulis konten artikel di sini (mendukung Markdown)..."
          rows="12"
          class="flex min-h-[80px] w-full rounded-md border border-gray-200 bg-white px-3 py-2 text-sm ring-offset-white placeholder:text-gray-500 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-gray-950 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50 font-mono"
        ></textarea>
      </div>

      <div
        class="flex justify-between items-center pt-4 border-t border-gray-100"
      >
        <div class="flex items-center gap-4">
          <select
            bind:value={currentPost.status}
            class="flex h-9 w-[180px] items-center justify-between rounded-md border border-gray-200 bg-transparent px-3 py-2 text-sm shadow-sm ring-offset-white placeholder:text-gray-500 focus:outline-none focus:ring-1 focus:ring-gray-950 disabled:cursor-not-allowed disabled:opacity-50"
          >
            <option value="draft">Draft</option>
            <option value="published">Publish</option>
          </select>
        </div>
        <div class="flex gap-2">
          <button
            on:click={() => (showEditor = false)}
            class="inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-white transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-gray-950 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 border border-gray-200 bg-white hover:bg-gray-100 hover:text-gray-900 h-9 px-4 py-2"
          >
            Batal
          </button>
          <button
            on:click={savePost}
            class="inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-white transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-gray-950 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 bg-gray-900 text-gray-50 hover:bg-gray-900/90 h-9 px-4 py-2"
          >
            Simpan
          </button>
        </div>
      </div>
    </div>
  {/if}

  {#if loading}
    <div class="flex justify-center p-12">
      <div
        class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"
      ></div>
    </div>
  {:else}
    <div
      class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden overflow-x-auto"
    >
      <table class="w-full text-left border-collapse min-w-[600px]">
        <thead class="bg-gray-50/50 border-b border-gray-100">
          <tr>
            <th
              class="p-4 text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >Judul</th
            >
            <th
              class="p-4 text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >Status</th
            >
            <th
              class="p-4 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right"
              >Aksi</th
            >
          </tr>
        </thead>
        <tbody>
          {#each posts as post}
            <tr
              class="hover:bg-gray-50/50 transition-colors border-b last:border-0 border-gray-50"
            >
              <td class="p-4 w-full">
                <div class="font-medium text-gray-900">{post.title}</div>
                <div class="text-xs text-gray-500 mt-1 truncate max-w-md">
                  {post.slug}
                </div>
              </td>
              <td class="p-4">
                <span
                  class="inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 border-transparent {post.status ===
                  'published'
                    ? 'bg-green-100 text-green-800'
                    : 'bg-gray-100 text-gray-800'} uppercase"
                >
                  {post.status}
                </span>
              </td>
              <td class="p-4 text-right">
                <button
                  on:click={() => editPost(post)}
                  class="inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-white transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-gray-950 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 hover:bg-gray-100 h-8 w-8"
                >
                  ✏️
                </button>
              </td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  {/if}
</div>
