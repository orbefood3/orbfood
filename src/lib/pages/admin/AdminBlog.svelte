<script lang="ts">
  import { onMount } from "svelte";
  import { supabase } from "../../services/supabase";
  import { uploadImage } from "../../services/cloudinary";
  import LoadingSpinner from "../../components/ui/LoadingSpinner.svelte";
  import PageWrapper from "../../components/ui/PageWrapper.svelte";
  import { Loader2, Image as ImageIcon, X, Save, Plus } from "lucide-svelte";

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
      slug: currentPost.title
        .toLowerCase()
        .replace(/ /g, "-")
        .replace(/[^\w-]+/g, ""),
      published_at:
        currentPost.status === "published"
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
      class="bg-white p-6 rounded-xl shadow-sm border border-gray-200 mb-6 space-y-6"
    >
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div class="space-y-4">
          <div class="grid gap-2">
            <label for="post_title" class="text-sm font-medium"
              >Judul Artikel</label
            >
            <input
              id="post_title"
              bind:value={currentPost.title}
              placeholder="Masukkan judul menarik..."
              class="flex h-10 w-full rounded-md border border-gray-200 bg-white px-3 py-2 text-sm focus:ring-2 focus:ring-primary outline-none"
            />
          </div>

          <div class="grid gap-2">
            <label for="post_category" class="text-sm font-medium"
              >Kategori</label
            >
            <select
              id="post_category"
              bind:value={currentPost.category}
              class="flex h-10 w-full rounded-md border border-gray-200 bg-white px-3 py-2 text-sm focus:ring-2 focus:ring-primary outline-none"
            >
              {#each categories as cat}
                <option value={cat.value}>{cat.label}</option>
              {/each}
            </select>
          </div>

          <div class="grid gap-2">
            <label for="post_excerpt" class="text-sm font-medium"
              >Ringkasan (Excerpt)</label
            >
            <textarea
              id="post_excerpt"
              bind:value={currentPost.excerpt}
              placeholder="Ringkasan singkat untuk daftar artikel..."
              rows="3"
              class="flex w-full rounded-md border border-gray-200 bg-white px-3 py-2 text-sm focus:ring-2 focus:ring-primary outline-none"
            ></textarea>
          </div>
        </div>

        <div class="space-y-4">
          <div class="grid gap-2">
            <label for="post_image_upload" class="text-sm font-medium"
              >Gambar Sampul</label
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
        <label for="post_content" class="text-sm font-medium"
          >Konten Lengkap</label
        >
        <textarea
          id="post_content"
          bind:value={currentPost.content}
          placeholder="Tulis isi artikel lengkap di sini..."
          rows="12"
          class="flex w-full rounded-md border border-gray-200 bg-white px-3 py-2 text-sm focus:ring-2 focus:ring-primary outline-none font-sans"
        ></textarea>
      </div>

      <div
        class="flex justify-between items-center pt-6 border-t border-gray-100"
      >
        <div class="flex items-center gap-4">
          <div class="grid gap-1.5 w-48">
            <label
              for="post_status"
              class="text-xs font-bold text-gray-400 uppercase tracking-wider"
              >Status</label
            >
            <select
              id="post_status"
              bind:value={currentPost.status}
              class="flex h-10 w-full rounded-md border border-gray-200 bg-white px-3 py-2 text-sm focus:ring-2 focus:ring-primary outline-none"
            >
              {#each statusOptions as opt}
                <option value={opt.value}>{opt.label}</option>
              {/each}
            </select>
          </div>
        </div>
        <div class="flex gap-2">
          <button
            on:click={() => (showEditor = false)}
            class="px-4 py-2 border border-gray-200 rounded-lg text-sm font-medium hover:bg-gray-50 transition-colors"
          >
            Batal
          </button>
          <button
            on:click={savePost}
            disabled={uploadingImage}
            class="px-4 py-2 bg-primary text-white rounded-lg text-sm font-medium hover:bg-primary-dark transition-colors flex items-center gap-2 shadow-sm disabled:opacity-50"
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
      <div
        class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"
      ></div>
    </div>
  {:else}
    <div class="flex flex-col md:flex-row gap-4 mb-6">
      <div class="relative flex-1">
        <span class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400">
          🔍
        </span>
        <input
          type="text"
          bind:value={searchQuery}
          placeholder="Cari judul artikel..."
          class="flex h-10 w-full rounded-md border border-gray-200 bg-white pl-10 pr-3 py-2 text-sm focus:ring-2 focus:ring-primary outline-none shadow-sm"
        />
      </div>
      <select
        bind:value={selectedCategoryFilter}
        class="flex h-10 w-full md:w-48 rounded-md border border-gray-200 bg-white px-3 py-2 text-sm focus:ring-2 focus:ring-primary outline-none shadow-sm"
      >
        <option value="all">Semua Kategori</option>
        {#each categories as cat}
          <option value={cat.value}>{cat.label}</option>
        {/each}
      </select>
    </div>

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
          {#each posts.filter((p) => (selectedCategoryFilter === "all" || p.category === selectedCategoryFilter) && (searchQuery === "" || p.title
                  .toLowerCase()
                  .includes(searchQuery.toLowerCase()))) as post}
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
                  class="inline-flex items-center rounded-full border px-2.5 py-0.5 text-[10px] font-bold transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 border-transparent {statusOptions.find(
                    (o) => o.value === post.status,
                  )?.color || 'bg-gray-100 text-gray-800'} uppercase"
                >
                  {post.status || "DRAFT"}
                </span>
              </td>
              <td class="p-4 text-right">
                <button
                  on:click={() => editPost(post)}
                  class="inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors hover:bg-gray-100 h-8 w-8"
                  title="Edit"
                >
                  ✏️
                </button>
                <button
                  on:click={() => deletePost(post)}
                  class="inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors hover:bg-red-50 text-red-500 h-8 w-8"
                  title="Hapus"
                >
                  🗑️
                </button>
              </td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  {/if}
</div>
