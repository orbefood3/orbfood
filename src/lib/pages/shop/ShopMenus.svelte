<script lang="ts">
    import { onMount } from "svelte";
    import { supabase } from "../../services/supabase";
    import {
        uploadImage,
        getOptimizedImageUrl,
    } from "../../services/cloudinary";
    import PageWrapper from "../../components/ui/PageWrapper.svelte";
    import LoadingSpinner from "../../components/ui/LoadingSpinner.svelte";
    import EmptyState from "../../components/ui/EmptyState.svelte";
    import {
        Plus,
        Search,
        Pencil,
        Trash2,
        Power,
        Image as ImageIcon,
        X,
        Check,
        ChevronLeft,
        ChevronRight,
        UploadCloud,
    } from "lucide-svelte";

    export let shopId: string;

    let menus: any[] = [];
    let loading = true;
    let searchQuery = "";
    let currentPage = 1;
    let itemsPerPage = 8; // Slightly reduced for better grid fit if moved to grid later, but fine for table
    let totalItems = 0;
    let searchTimeout: any;
    let hasMore = true;
    let observer: IntersectionObserver;
    let loadMoreRef: HTMLElement;

    // Modal State
    let showModal = false;
    let isEditing = false;
    let isUploading = false;
    let formData = {
        id: "",
        name: "",
        description: "",
        price: 0,
        category: "makanan",
        primary_image: "",
        is_available: true,
        is_package: false,
    };
    let packageItemsSelection: any[] = []; // [{ child_menu_id: string, quantity: number, additional_price: number }]
    let allShopMenus: any[] = [];
    let selectedFile: File | null = null;
    let previewUrl: string = "";
    // Keep track of original image url for deletion logic
    let originalImageUrl = "";

    const categories = ["makanan", "minuman", "camilan", "paket", "lainnya"];

    async function fetchMenus(append = false) {
        if (!append) {
            loading = true;
            currentPage = 1;
        }

        const from = (currentPage - 1) * itemsPerPage;
        const to = from + itemsPerPage - 1;

        let query = supabase
            .from("menu_items")
            .select("*", { count: "exact" })
            .eq("shop_id", shopId)
            .order("created_at", { ascending: false })
            .range(from, to);

        if (searchQuery) {
            query = query.ilike("name", `%${searchQuery}%`);
        }

        const { data, count, error } = await query;

        if (error) {
            console.error("Error fetching menus:", error);
        } else {
            const newMenus = data || [];
            menus = append ? [...menus, ...newMenus] : newMenus;
            totalItems = count || 0;
            hasMore = menus.length < totalItems;
        }
        loading = false;

        if (!append) {
            // Also fetch all menus for package selection only on initial load or search
            const { data: allData } = await supabase
                .from("menu_items")
                .select("id, name")
                .eq("shop_id", shopId)
                .order("name");
            allShopMenus = allData || [];
        }
    }

    function initObserver() {
        observer = new IntersectionObserver(
            (entries) => {
                if (entries[0].isIntersecting && hasMore && !loading) {
                    currentPage++;
                    fetchMenus(true);
                }
            },
            { threshold: 0.1 },
        );

        if (loadMoreRef) observer.observe(loadMoreRef);
    }

    onMount(() => {
        if (shopId) fetchMenus();
        initObserver();
        return () => observer?.disconnect();
    });

    function handleSearchInput() {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(() => {
            fetchMenus();
        }, 500);
    }

    function openAddModal() {
        isEditing = false;
        isUploading = false;
        selectedFile = null;
        previewUrl = "";
        formData = {
            id: "",
            name: "",
            description: "",
            price: 0,
            category: "makanan",
            primary_image: "",
            is_available: true,
            is_package: false,
        };
        originalImageUrl = "";
        packageItemsSelection = [];
        showModal = true;
    }

    async function fetchPackageItems(parentId: string) {
        const { data, error } = await supabase
            .from("menu_package_items")
            .select("child_menu_id, quantity, additional_price")
            .eq("parent_menu_id", parentId);

        if (!error && data) {
            packageItemsSelection = data || [];
        }
    }

    function handlePackageItemToggle(menuId: string, checked: boolean) {
        if (checked) {
            packageItemsSelection = [
                ...packageItemsSelection,
                {
                    child_menu_id: menuId,
                    quantity: 1,
                    additional_price: 0,
                },
            ];
        } else {
            packageItemsSelection = packageItemsSelection.filter(
                (p) => p.child_menu_id !== menuId,
            );
        }
    }

    function openEditModal(menu: any) {
        isEditing = true;
        isUploading = false;
        selectedFile = null;
        previewUrl = "";
        formData = { ...menu };
        originalImageUrl = menu.primary_image || "";
        packageItemsSelection = [];
        if (menu.is_package) {
            fetchPackageItems(menu.id);
        }
        showModal = true;
    }

    function handleFileSelect(event: any) {
        const file = event.target.files[0];
        if (file) {
            if (file.size > 5 * 1024 * 1024) {
                // 5MB limit
                alert("Ukuran gambar maksimal 5MB");
                return;
            }
            selectedFile = file;
            previewUrl = URL.createObjectURL(file);
        }
    }

    async function handleSubmit() {
        if (!formData.name || !formData.price) {
            alert("Nama dan Harga wajib diisi");
            return;
        }

        let newImageUrl = formData.primary_image;

        // Upload Image if selected
        if (selectedFile) {
            try {
                isUploading = true;
                const uploadedUrl = await uploadImage(selectedFile);
                newImageUrl = uploadedUrl;
                formData.primary_image = uploadedUrl;
            } catch (error: any) {
                alert("Gagal mengupload gambar: " + error.message);
                isUploading = false;
                return;
            } finally {
                isUploading = false;
            }
        }

        const payload: any = {
            shop_id: shopId,
            name: formData.name,
            description: formData.description,
            price: formData.price,
            category: formData.category,
            primary_image: formData.primary_image,
            is_available: formData.is_available,
            is_package: formData.is_package,
        };

        let error;
        let savedMenuId = formData.id;

        if (isEditing) {
            const { error: updateError } = await supabase
                .from("menu_items")
                .update(payload)
                .eq("id", formData.id);
            error = updateError;
        } else {
            const { data: insertData, error: insertError } = await supabase
                .from("menu_items")
                .insert(payload)
                .select()
                .single();
            error = insertError;
            if (insertData) savedMenuId = insertData.id;
        }

        if (!error && formData.is_package && savedMenuId) {
            // Update package items
            // First delete existing
            await supabase
                .from("menu_package_items")
                .delete()
                .eq("parent_menu_id", savedMenuId);

            // Insert new selections
            if (packageItemsSelection.length > 0) {
                const packageInserts = packageItemsSelection.map((item) => ({
                    parent_menu_id: savedMenuId,
                    child_menu_id: item.child_menu_id,
                    quantity: item.quantity || 1,
                    additional_price: item.additional_price || 0,
                }));
                await supabase
                    .from("menu_package_items")
                    .insert(packageInserts);
            }
        }

        if (error) {
            alert("Gagal menyimpan menu: " + error.message);
        } else {
            showModal = false;
            fetchMenus();
        }
    }

    async function deleteMenu(menu: any) {
        if (!confirm(`Hapus menu "${menu.name}"?`)) return;

        const { error } = await supabase
            .from("menu_items")
            .delete()
            .eq("id", menu.id);

        if (error) {
            alert("Gagal menghapus menu: " + error.message);
        } else {
            fetchMenus();
        }
    }

    async function toggleAvailability(menu: any) {
        const newStatus = !menu.is_available;
        // Optimistic update
        menus = menus.map((m) =>
            m.id === menu.id ? { ...m, is_available: newStatus } : m,
        );

        const { error } = await supabase
            .from("menu_items")
            .update({ is_available: newStatus })
            .eq("id", menu.id);

        if (error) {
            // Revert if error
            menus = menus.map((m) =>
                m.id === menu.id ? { ...m, is_available: !newStatus } : m,
            );
            alert("Gagal mengupdate status: " + error.message);
        }
    }

    function formatPrice(price: number) {
        return new Intl.NumberFormat("id-ID", {
            style: "currency",
            currency: "IDR",
            minimumFractionDigits: 0,
        }).format(price);
    }

    $: totalPages = Math.ceil(totalItems / itemsPerPage);

    // Automatically set is_package true when category is 'paket'
    $: if (formData.category === "paket") {
        formData.is_package = true;
    }
</script>

<PageWrapper>
    <div class="space-y-6">
        <!-- Header -->
        <div
            class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4"
        >
            <div
                class="relative w-full sm:w-64 bg-white rounded-lg border border-gray-200 flex items-center px-3 py-2"
            >
                <Search size={18} class="text-gray-400 mr-2" />
                <input
                    type="text"
                    bind:value={searchQuery}
                    on:input={handleSearchInput}
                    placeholder="Cari menu..."
                    class="w-full bg-transparent outline-none text-sm"
                />
            </div>

            <button
                on:click={openAddModal}
                class="bg-primary text-white px-4 py-2 rounded-lg font-medium text-sm flex items-center gap-2 hover:bg-primary/90 transition-colors w-full sm:w-auto justify-center"
            >
                <Plus size={18} /> Tambah Menu
            </button>
        </div>

        <!-- Content -->
        {#if loading}
            <div class="flex justify-center p-12">
                <LoadingSpinner />
            </div>
        {:else if menus.length === 0}
            <EmptyState
                message={searchQuery
                    ? "Menu tidak ditemukan"
                    : "Belum ada menu. Tambahkan menu sekarang!"}
                icon="🍔"
                actionLabel={searchQuery ? undefined : "Tambah Menu"}
                onAction={searchQuery ? undefined : openAddModal}
            />
        {:else}
            <div
                class="bg-white rounded-xl border border-gray-200 overflow-hidden shadow-sm"
            >
                <div class="overflow-x-auto">
                    <table
                        class="w-full text-left border-collapse min-w-[600px]"
                    >
                        <thead class="bg-gray-50 border-b border-gray-200">
                            <tr>
                                <th
                                    class="px-6 py-4 text-xs font-semibold text-gray-600 uppercase w-20"
                                    >Foto</th
                                >
                                <th
                                    class="px-6 py-4 text-xs font-semibold text-gray-600 uppercase"
                                    >Nama & Kategori</th
                                >
                                <th
                                    class="px-6 py-4 text-xs font-semibold text-gray-600 uppercase"
                                    >Harga</th
                                >
                                <th
                                    class="px-6 py-4 text-xs font-semibold text-gray-600 uppercase"
                                    >Status</th
                                >
                                <th
                                    class="px-6 py-4 text-right text-xs font-semibold text-gray-600 uppercase"
                                    >Aksi</th
                                >
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-200">
                            {#each menus as menu}
                                <tr class="hover:bg-gray-50 transition-colors">
                                    <td class="px-6 py-4">
                                        <div
                                            class="w-12 h-12 rounded-lg bg-gray-100 flex items-center justify-center overflow-hidden border border-gray-200"
                                        >
                                            {#if menu.primary_image}
                                                <img
                                                    src={getOptimizedImageUrl(
                                                        menu.primary_image,
                                                        100,
                                                    )}
                                                    alt={menu.name}
                                                    class="w-full h-full object-cover"
                                                />
                                            {:else}
                                                <ImageIcon
                                                    size={20}
                                                    class="text-gray-400"
                                                />
                                            {/if}
                                        </div>
                                    </td>
                                    <td class="px-6 py-4">
                                        <div class="font-medium text-gray-900">
                                            {menu.name}
                                        </div>
                                        <div
                                            class="text-xs text-gray-500 capitalize"
                                        >
                                            {menu.category || "Umum"}
                                        </div>
                                    </td>
                                    <td
                                        class="px-6 py-4 text-sm font-medium text-gray-900"
                                    >
                                        {formatPrice(menu.price)}
                                    </td>
                                    <td class="px-6 py-4">
                                        <button
                                            on:click={() =>
                                                toggleAvailability(menu)}
                                            class="flex items-center gap-1.5 px-2 py-1 rounded text-xs font-medium transition-colors {menu.is_available
                                                ? 'bg-green-100 text-green-700 hover:bg-green-200'
                                                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}"
                                        >
                                            <span
                                                class="w-1.5 h-1.5 rounded-full {menu.is_available
                                                    ? 'bg-green-500'
                                                    : 'bg-gray-400'}"
                                            ></span>
                                            {menu.is_available
                                                ? "Tersedia"
                                                : "Habis"}
                                        </button>
                                    </td>
                                    <td class="px-6 py-4 text-right">
                                        <div class="flex justify-end gap-2">
                                            <button
                                                on:click={() =>
                                                    openEditModal(menu)}
                                                class="p-1.5 text-gray-500 hover:text-blue-600 hover:bg-blue-50 rounded-md transition-colors"
                                                title="Edit Menu"
                                            >
                                                <Pencil size={18} />
                                            </button>

                                            <button
                                                on:click={() =>
                                                    deleteMenu(menu)}
                                                class="p-1.5 text-gray-500 hover:text-red-600 hover:bg-red-50 rounded-md transition-colors"
                                                title="Hapus Menu"
                                            >
                                                <Trash2 size={18} />
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            {/each}
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Infinite Scroll Trigger -->
            {#if hasMore}
                <div bind:this={loadMoreRef} class="flex justify-center p-8">
                    {#if loading && menus.length > 0}
                        <LoadingSpinner size="sm" />
                    {/if}
                </div>
            {/if}
        {/if}
    </div>
</PageWrapper>

<!-- Add/Edit Modal -->
{#if showModal}
    <!-- svelte-ignore a11y-click-events-have-key-events -->
    <!-- svelte-ignore a11y-no-static-element-interactions -->
    <div class="fixed inset-0 z-50 flex items-center justify-center p-4">
        <div
            class="absolute inset-0 bg-black/50 backdrop-blur-sm"
            on:click={() => (showModal = false)}
        ></div>

        <div
            class="relative bg-white rounded-xl shadow-xl w-full max-w-md overflow-hidden animate-fade-in"
        >
            <div
                class="flex justify-between items-center p-4 border-b border-gray-100"
            >
                <h3 class="text-lg font-bold text-gray-900">
                    {isEditing ? "Edit Menu" : "Tambah Menu Baru"}
                </h3>
                <button
                    on:click={() => (showModal = false)}
                    class="text-gray-400 hover:text-gray-600"
                >
                    <X size={20} />
                </button>
            </div>

            <div class="p-6 space-y-4 max-h-[70vh] overflow-y-auto">
                <!-- Image Upload -->
                <div>
                    <label
                        for="image-upload"
                        class="block text-sm font-medium text-gray-700 mb-2"
                        >Foto Menu</label
                    >

                    <div class="flex items-center gap-4">
                        <!-- Preview -->
                        <div
                            class="w-20 h-20 rounded-lg bg-gray-100 border border-gray-200 flex items-center justify-center overflow-hidden shrink-0 relative group"
                        >
                            {#if previewUrl || formData.primary_image}
                                <img
                                    src={previewUrl ||
                                        getOptimizedImageUrl(
                                            formData.primary_image,
                                            150,
                                        )}
                                    alt="Preview"
                                    class="w-full h-full object-cover"
                                />
                                {#if previewUrl || (formData.primary_image && isEditing)}
                                    <div
                                        class="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center"
                                    >
                                        <Pencil size={16} class="text-white" />
                                    </div>
                                {/if}
                            {:else}
                                <ImageIcon size={24} class="text-gray-400" />
                            {/if}

                            <!-- Hidden Input -->
                            <input
                                id="image-upload"
                                type="file"
                                accept="image/*"
                                on:change={handleFileSelect}
                                class="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                            />
                        </div>

                        <div class="flex-1">
                            {#if !selectedFile && !formData.primary_image}
                                <label
                                    for="image-upload"
                                    class="cursor-pointer inline-flex items-center gap-2 px-4 py-2 bg-white border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 transition-colors"
                                >
                                    <UploadCloud size={18} />
                                    Pilih Foto
                                </label>
                                <p class="text-xs text-gray-500 mt-2">
                                    Format: JPG, PNG, WEBP. Maks 5MB.
                                </p>
                            {:else}
                                <div class="flex flex-col gap-2">
                                    <label
                                        for="image-upload"
                                        class="cursor-pointer text-sm text-blue-600 hover:underline"
                                    >
                                        Ganti Foto
                                    </label>
                                    {#if selectedFile}
                                        <span
                                            class="text-xs text-gray-500 truncate max-w-[200px]"
                                            >{selectedFile.name} (Siap Upload)</span
                                        >
                                    {/if}
                                </div>
                            {/if}
                        </div>
                    </div>
                </div>

                <!-- Name -->
                <div>
                    <label
                        for="menu-name"
                        class="block text-sm font-medium text-gray-700 mb-1"
                        >Nama Menu</label
                    >
                    <input
                        id="menu-name"
                        type="text"
                        bind:value={formData.name}
                        placeholder="Contoh: Nasi Goreng Spesial"
                        class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent outline-none text-sm"
                    />
                </div>

                <!-- Category -->
                <div>
                    <label
                        for="menu-category"
                        class="block text-sm font-medium text-gray-700 mb-1"
                        >Kategori</label
                    >
                    <select
                        id="menu-category"
                        bind:value={formData.category}
                        class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent outline-none text-sm bg-white"
                    >
                        {#each categories as category}
                            <option value={category} class="capitalize"
                                >{category}</option
                            >
                        {/each}
                    </select>
                </div>

                <!-- Price -->
                <div>
                    <label
                        for="menu-price"
                        class="block text-sm font-medium text-gray-700 mb-1"
                        >Harga (Rp)</label
                    >
                    <input
                        id="menu-price"
                        type="number"
                        bind:value={formData.price}
                        placeholder="0"
                        min="0"
                        class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent outline-none text-sm"
                    />
                </div>

                <!-- Description -->
                <div>
                    <label
                        for="menu-desc"
                        class="block text-sm font-medium text-gray-700 mb-1"
                        >Deskripsi</label
                    >
                    <textarea
                        id="menu-desc"
                        bind:value={formData.description}
                        placeholder="Jelaskan detail menu..."
                        rows="3"
                        class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent outline-none text-sm"
                    />
                </div>

                <!-- Availability -->
                <div class="flex items-center gap-2">
                    <input
                        type="checkbox"
                        id="available"
                        bind:checked={formData.is_available}
                        class="w-4 h-4 text-primary rounded border-gray-300 focus:ring-primary"
                    />
                    <label for="available" class="text-sm text-gray-700"
                        >Tersedia untuk dipesan</label
                    >
                </div>

                <div class="flex items-center gap-2">
                    <input
                        type="checkbox"
                        id="is_package"
                        bind:checked={formData.is_package}
                        class="w-4 h-4 text-primary rounded border-gray-300 focus:ring-primary"
                    />
                    <label
                        for="is_package"
                        class="text-sm font-bold text-gray-900"
                        >Menu ini adalah Paket (Bundle)</label
                    >
                </div>

                {#if formData.is_package}
                    <div class="pt-4 border-t border-gray-100">
                        <span class="block text-sm font-bold text-gray-700 mb-2"
                            >Pilih Isi Paket</span
                        >
                        <div
                            class="max-h-64 overflow-y-auto space-y-4 border border-gray-200 rounded-lg p-2 bg-gray-50"
                        >
                            {#each allShopMenus.filter((m) => m.id !== formData.id && !m.is_package) as menu}
                                {@const selectedIndex =
                                    packageItemsSelection.findIndex(
                                        (p) => p.child_menu_id === menu.id,
                                    )}
                                {@const isSelected = selectedIndex !== -1}

                                <div
                                    class="p-3 bg-white rounded-xl border {isSelected
                                        ? 'border-primary ring-1 ring-primary/20'
                                        : 'border-gray-100'} transition-all shadow-sm"
                                >
                                    <label
                                        class="flex items-center gap-3 cursor-pointer mb-3"
                                    >
                                        <input
                                            type="checkbox"
                                            checked={isSelected}
                                            on:change={(e) =>
                                                handlePackageItemToggle(
                                                    menu.id,
                                                    e.currentTarget.checked,
                                                )}
                                            class="rounded text-primary focus:ring-primary h-5 w-5"
                                        />
                                        <span
                                            class="text-sm font-black text-gray-900 flex-1"
                                            >{menu.name}</span
                                        >
                                    </label>

                                    {#if isSelected}
                                        <div
                                            class="grid grid-cols-2 gap-3 pl-8 pt-2 border-t border-gray-50"
                                        >
                                            <div>
                                                <label
                                                    class="block text-[10px] font-black text-gray-400 uppercase mb-1"
                                                    >Jumlah</label
                                                >
                                                <input
                                                    type="number"
                                                    bind:value={
                                                        packageItemsSelection[
                                                            selectedIndex
                                                        ].quantity
                                                    }
                                                    min="1"
                                                    class="w-full px-2 py-1.5 bg-gray-50 border border-gray-100 rounded-lg text-xs font-bold focus:ring-1 focus:ring-primary outline-none"
                                                />
                                            </div>
                                            <div>
                                                <label
                                                    class="block text-[10px] font-black text-gray-400 uppercase mb-1"
                                                    >Harga Tam. (Rp)</label
                                                >
                                                <input
                                                    type="number"
                                                    bind:value={
                                                        packageItemsSelection[
                                                            selectedIndex
                                                        ].additional_price
                                                    }
                                                    min="0"
                                                    placeholder="0"
                                                    class="w-full px-2 py-1.5 bg-gray-50 border border-gray-100 rounded-lg text-xs font-bold focus:ring-1 focus:ring-primary outline-none"
                                                />
                                            </div>
                                        </div>
                                    {/if}
                                </div>
                            {/each}
                            {#if allShopMenus.filter((m) => m.id !== formData.id && !m.is_package).length === 0}
                                <p
                                    class="text-xs text-gray-400 text-center py-4"
                                >
                                    Belum ada menu lain untuk dimasukkan ke
                                    paket.
                                </p>
                            {/if}
                        </div>
                        <p class="text-[10px] text-gray-400 mt-2">
                            * Menu paket hanya bisa berisi menu satuan (bukan
                            paket lain).
                        </p>
                    </div>
                {/if}
            </div>

            <div
                class="p-4 border-t border-gray-100 bg-gray-50 flex justify-end gap-2"
            >
                <button
                    on:click={() => (showModal = false)}
                    disabled={isUploading}
                    class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors disabled:opacity-50"
                >
                    Batal
                </button>
                <button
                    on:click={handleSubmit}
                    disabled={isUploading}
                    class="px-4 py-2 text-sm font-medium text-white bg-primary rounded-lg hover:bg-primary/90 transition-colors flex items-center gap-2 disabled:opacity-70 disabled:cursor-not-allowed"
                >
                    {#if isUploading}
                        <div
                            class="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"
                        ></div>
                        Mengupload...
                    {:else}
                        <Check size={16} /> Simpan
                    {/if}
                </button>
            </div>
        </div>
    </div>
{/if}

<style>
    .animate-fade-in {
        animation: fadeIn 0.2s ease-out;
    }

    @keyframes fadeIn {
        from {
            opacity: 0;
            transform: scale(0.95);
        }
        to {
            opacity: 1;
            transform: scale(1);
        }
    }
</style>
