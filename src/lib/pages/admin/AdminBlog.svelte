<script lang="ts">
  import { onMount } from "svelte";
  import { supabase } from "../../services/supabase";
  import { uploadImage } from "../../services/cloudinary";
  import PageWrapper from "../../components/ui/PageWrapper.svelte";
  import LoadingSpinner from "../../components/ui/LoadingSpinner.svelte";
  import {
    Loader2,
    Image as ImageIcon,
    X,
    Save,
    Search,
    Pencil,
    Trash2,
  } from "lucide-svelte";

  let posts: any[] = [];
  let loading = true;
  let showEditor = false;
  let uploadingImage = false;
  let searchQuery = "";
  let selectedCategoryFilter = "all";

  const categories = [
    { value: "kuliner", label: "Kuliner" },
    { value: "tips", label: "Tips & Trik" },
    { value: "promo", label: "Promo" },
    { value: "serba-serbi", label: "Serba-serbi" },
    { value: "berita", label: "Berita" },
  ];

  let currentPost: any = {
    title: "",
    content: "",
    excerpt: "",
    category: "tips",
    status: "draft",
    cover_image: null,
  };

  const statusOptions = [
    { value: "draft", label: "Draft", color: "bg-gray-100 text-gray-800" },
    {
      value: "published",
      label: "Published",
      color: "bg-green-100 text-green-800",
    },
    {
      value: "announcement",
      label: "Announcement",
      color: "bg-blue-100 text-blue-800",
    },
  ];

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

    const user = (await supabase.auth.getUser()).data.user;
    if (!user) {
      alert("Anda harus login");
      return;
    }

    const postData = {
      ...currentPost,
      author_id: user.id,
      is_published:
        currentPost.status === "published" ||
        currentPost.status === "announcement",
      slug: currentPost.title
        .toLowerCase()
        .replace(/ /g, "-")
        .replace(/[^\w-]+/g, ""),
      published_at:
        currentPost.status === "published" ||
        currentPost.status === "announcement"
          ? new Date().toISOString()
          : currentPost.published_at || null,
      updated_at: new Date().toISOString(),
    };

    const { error } = await supabase.from("blog_posts").upsert(postData);

    if (error) {
      alert("Error saving post: " + error.message);
    } else {
      alert("Artikel berhasil disimpan!");
      showEditor = false;
      fetchPosts();
    }
  }

  async function handleImageUpload(e: Event) {
    const file = (e.target as HTMLInputElement).files?.[0];
    if (!file) return;

    try {
      uploadingImage = true;
      const url = await uploadImage(file);
      currentPost.cover_image = url;
    } catch (error: any) {
      alert("Gagal mengunggah gambar: " + error.message);
    } finally {
      uploadingImage = false;
    }
  }

  function editPost(post: any) {
    currentPost = { ...post };
    showEditor = true;
  }

  function createNew() {
    currentPost = {
      title: "",
      content: "",
      excerpt: "",
      category: "tips",
      status: "draft",
      cover_image: null,
    };
    showEditor = true;
  }

  async function deletePost(post: any) {
    if (
      !confirm(
        `Hapus artikel "${post.title}"? Gambar sampul juga akan dihapus.`,
      )
    )
      return;

    const { error } = await supabase
      .from("blog_posts")
      .delete()
      .eq("id", post.id);

    if (error) {
      alert("Gagal menghapus: " + error.message);
    } else {
      alert("Artikel berhasil dihapus!");
      fetchPosts();
    }
  }

  $: filteredPosts = posts.filter(
    (p) =>
      (selectedCategoryFilter === "all" || p.category === selectedCategoryFilter) &&
      (searchQuery === "" ||
        p.title.toLowerCase().includes(searchQuery.toLowerCase())),
  );
</script>

<PageWrapper>
  <div class="space-y-6">
    <div class="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
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
        class="inline-flex h-10 items-center justify-center rounded-xl bg-gray-900 px-4 text-sm font-semibold text-white transition-colors hover:bg-gray-800 focus:outline-none focus:ring-2 focus:ring-gray-900/20"
      >
        + Tulis Artikel
      </button>
    </div>

    {#if showEditor}
      <div
        class="bg-white p-6 rounded-2xl shadow-sm border border-gray-200 space-y-6"
      >
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div class="space-y-4">
            <div class="grid gap-2">
              <label for="post_title" class="text-sm font-semibold text-gray-700"
                >Judul Artikel</label
              >
              <input
                id="post_title"
                bind:value={currentPost.title}
                placeholder="Masukkan judul menarik..."
                class="h-10 w-full rounded-xl border border-gray-200 bg-white px-3 py-2 text-sm outline-none transition-colors focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
              />
            </div>

            <div class="grid gap-2">
              <label for="post_category" class="text-sm font-semibold text-gray-700"
                >Kategori</label
              >
              <select
                id="post_category"
                bind:value={currentPost.category}
                class="h-10 w-full rounded-xl border border-gray-200 bg-white px-3 py-2 text-sm outline-none transition-colors focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
              >
                {#each categories as cat}
                  <option value={cat.value}>{cat.label}</option>
                {/each}
              </select>
            </div>

            <div class="grid gap-2">
              <label for="post_excerpt" class="text-sm font-semibold text-gray-700"
                >Ringkasan (Excerpt)</label
              >
              <textarea
                id="post_excerpt"
                bind:value={currentPost.excerpt}
                placeholder="Ringkasan singkat untuk daftar artikel..."
                rows="3"
                class="w-full rounded-xl border border-gray-200 bg-white px-3 py-2 text-sm outline-none transition-colors focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
              ></textarea>
            </div>
          </div>

          <div class="space-y-4">
            <div class="grid gap-2">
              <label
                for="post_image_upload"
                class="text-sm font-semibold text-gray-700">Gambar Sampul</label
              >
              <div
                class="relative group aspect-video rounded-xl border-2 border-dashed border-gray-200 flex flex-col items-center justify-center overflow-hidden bg-gray-50 hover:bg-gray-100 transition-colors"
              >
                {#if currentPost.cover_image}
                  <img
                    src={currentPost.cover_image}
                    alt="Cover"
                    class="w-full h-full object-cover"
                  />
                  <button
                    on:click={() => (currentPost.cover_image = null)}
                    class="absolute top-2 right-2 p-1.5 bg-black/50 text-white rounded-full hover:bg-black/70 transition-colors"
                  >
                    <X size={16} />
                  </button>
                {:else}
                  <ImageIcon size={32} class="text-gray-400 mb-2" />
                  <label class="absolute inset-0 cursor-pointer">
                    <span class="sr-only">Klik untuk unggah gambar</span>
                    <input
                      id="post_image_upload"
                      type="file"
                      accept="image/*"
                      on:change={handleImageUpload}
                      class="opacity-0 w-full h-full"
                      disabled={uploadingImage}
                    />
                  </label>
                {/if}

                {#if uploadingImage}
                  <div
                    class="absolute inset-0 bg-white/80 flex items-center justify-center"
                  >
                    <div class="flex flex-col items-center gap-2">
                      <Loader2 class="animate-spin text-primary" size={24} />
                      <span class="text-xs font-medium">Mengunggah...</span>
                    </div>
                  </div>
                {/if}
              </div>
            </div>
          </div>
        </div>

        <div class="grid gap-2">
          <label for="post_content" class="text-sm font-semibold text-gray-700"
            >Konten Lengkap</label
          >
          <textarea
            id="post_content"
            bind:value={currentPost.content}
            placeholder="Tulis isi artikel lengkap di sini..."
            rows="12"
            class="w-full rounded-xl border border-gray-200 bg-white px-3 py-2 text-sm outline-none transition-colors focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 font-sans"
          ></textarea>
        </div>

        <div
          class="flex flex-col gap-3 md:flex-row md:items-center md:justify-between pt-6 border-t border-gray-100"
        >
          <div class="grid gap-1.5 w-full md:w-52">
            <label
              for="post_status"
              class="text-xs font-bold text-gray-400 uppercase tracking-wider"
              >Status</label
            >
            <select
              id="post_status"
              bind:value={currentPost.status}
              class="h-10 w-full rounded-xl border border-gray-200 bg-white px-3 py-2 text-sm outline-none transition-colors focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
            >
              {#each statusOptions as opt}
                <option value={opt.value}>{opt.label}</option>
              {/each}
            </select>
          </div>

          <div class="flex gap-2">
            <button
              on:click={() => (showEditor = false)}
              class="px-4 py-2 border border-gray-200 rounded-xl text-sm font-semibold text-gray-700 hover:bg-gray-50 transition-colors"
            >
              Batal
            </button>
            <button
              on:click={savePost}
              disabled={uploadingImage}
              class="px-4 py-2 bg-primary text-white rounded-xl text-sm font-semibold hover:bg-primary-dark transition-colors flex items-center gap-2 shadow-sm disabled:opacity-50"
            >
              <Save size={16} />
              Simpan Artikel
            </button>
          </div>
        </div>
      </div>
    {/if}

    {#if loading}
      <div class="flex justify-center p-12">
        <LoadingSpinner />
      </div>
    {:else}
      <div class="flex flex-col md:flex-row gap-3">
        <div
          class="relative flex-1 bg-white rounded-xl border border-gray-200 flex items-center px-3 py-2"
        >
          <Search size={18} class="text-gray-400 mr-2" />
          <input
            type="text"
            bind:value={searchQuery}
            placeholder="Cari judul artikel..."
            class="w-full bg-transparent outline-none text-sm"
          />
        </div>
        <select
          bind:value={selectedCategoryFilter}
          class="h-10 w-full md:w-56 rounded-xl border border-gray-200 bg-white px-3 py-2 text-sm outline-none transition-colors focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
        >
          <option value="all">Semua Kategori</option>
          {#each categories as cat}
            <option value={cat.value}>{cat.label}</option>
          {/each}
        </select>
      </div>

      <div
        class="bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden overflow-x-auto"
      >
        <table class="w-full text-left border-collapse min-w-[640px]">
          <thead class="bg-gray-50/70 border-b border-gray-200">
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
            {#if filteredPosts.length === 0}
              <tr>
                <td colspan="3" class="p-8 text-center text-sm text-gray-500">
                  Tidak ada artikel yang cocok.
                </td>
              </tr>
            {:else}
              {#each filteredPosts as post}
                <tr
                  class="hover:bg-gray-50/80 transition-colors border-b last:border-0 border-gray-100"
                >
                  <td class="p-4 w-full">
                    <div class="font-semibold text-gray-900">{post.title}</div>
                    <div class="text-xs text-gray-500 mt-1 truncate max-w-md">
                      {post.slug}
                    </div>
                  </td>
                  <td class="p-4">
                    <span
                      class="inline-flex items-center rounded-full px-2.5 py-0.5 text-[10px] font-bold {statusOptions.find(
                        (o) => o.value === post.status,
                      )?.color || 'bg-gray-100 text-gray-800'} uppercase"
                    >
                      {post.status || "DRAFT"}
                    </span>
                  </td>
                  <td class="p-4 text-right">
                    <div class="flex items-center justify-end gap-1">
                      <button
                        on:click={() => editPost(post)}
                        class="p-1.5 text-gray-500 hover:text-blue-600 hover:bg-blue-50 rounded-md transition-colors"
                        title="Edit"
                      >
                        <Pencil size={16} />
                      </button>
                      <button
                        on:click={() => deletePost(post)}
                        class="p-1.5 text-gray-500 hover:text-red-600 hover:bg-red-50 rounded-md transition-colors"
                        title="Hapus"
                      >
                        <Trash2 size={16} />
                      </button>
                    </div>
                  </td>
                </tr>
              {/each}
            {/if}
          </tbody>
        </table>
      </div>
    {/if}
  </div>
</PageWrapper>
