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
    let itemsPerPage = 8;
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
        type: "single", // 'single' | 'package'
    };
    let optionGroups: any[] = []; // [{ name: string, is_required: boolean, min_selection: number, max_selection: number, items: [{ name, additional_price, is_available }] }]
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
            type: "single",
        };
        originalImageUrl = "";
        optionGroups = [];
        showModal = true;
    }

    async function fetchMenuOptions(menuId: string) {
        const { data: groups, error: groupsError } = await supabase
            .from("menu_option_groups")
            .select("*, menu_option_items(*)")
            .eq("menu_id", menuId)
            .order("created_at", { ascending: true });

        if (!groupsError && groups) {
            optionGroups = groups.map((g) => ({
                id: g.id,
                name: g.name,
                is_required: g.is_required,
                min_selection: g.min_selection,
                max_selection: g.max_selection,
                items: g.menu_option_items.map((i: any) => ({
                    id: i.id,
                    name: i.name,
                    additional_price: i.additional_price,
                    is_available: i.is_available,
                })),
            }));
        }
    }

    function addOptionGroup() {
        optionGroups = [
            ...optionGroups,
            {
                name: "",
                is_required: true,
                min_selection: 1,
                max_selection: 1,
                items: [{ name: "", additional_price: 0, is_available: true }],
            },
        ];
    }

    function removeOptionGroup(index: number) {
        optionGroups = optionGroups.filter((_, i) => i !== index);
    }

    function addOptionItem(groupIndex: number) {
        optionGroups[groupIndex].items = [
            ...optionGroups[groupIndex].items,
            {
                name: "",
                additional_price: 0,
                is_available: true,
            },
        ];
        optionGroups = [...optionGroups];
    }

    function removeOptionItem(groupIndex: number, itemIndex: number) {
        optionGroups[groupIndex].items = optionGroups[groupIndex].items.filter(
            (_: any, i: number) => i !== itemIndex,
        );
        optionGroups = [...optionGroups];
    }

    function openEditModal(menu: any) {
        isEditing = true;
        isUploading = false;
        selectedFile = null;
        previewUrl = "";
        formData = { ...menu };
        originalImageUrl = menu.primary_image || "";
        optionGroups = [];
        if (menu.type === "package") {
            fetchMenuOptions(menu.id);
        }
        showModal = true;
    }

    function handleFileSelect(event: any) {
        const file = event.target.files[0];
        if (file) {
            if (file.size > 5 * 1024 * 1024) {
                alert("Ukuran gambar maksimal 5MB");
                return;
            }
            selectedFile = file;
            previewUrl = URL.createObjectURL(file);
        }
    }

    async function handleSubmit() {
        if (
            !formData.name ||
            formData.price === null ||
            formData.price === undefined
        ) {
            alert("Nama dan Harga wajib diisi");
            return;
        }

        let newImageUrl = formData.primary_image;

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
            type: formData.type,
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

        if (!error && formData.type === "package" && savedMenuId) {
            await supabase
                .from("menu_option_groups")
                .delete()
                .eq("menu_id", savedMenuId);

            for (const group of optionGroups) {
                const { data: groupData, error: groupError } = await supabase
                    .from("menu_option_groups")
                    .insert({
                        menu_id: savedMenuId,
                        name: group.name,
                        is_required: group.is_required,
                        min_selection: group.min_selection,
                        max_selection: group.max_selection,
                    })
                    .select()
                    .single();

                if (!groupError && groupData && group.items.length > 0) {
                    const itemInserts = group.items
                        .filter((i: any) => i.name.trim() !== "")
                        .map((i: any) => ({
                            group_id: groupData.id,
                            name: i.name,
                            additional_price: i.additional_price || 0,
                            is_available: i.is_available,
                        }));

                    if (itemInserts.length > 0) {
                        await supabase
                            .from("menu_option_items")
                            .insert(itemInserts);
                    }
                }
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
        menus = menus.map((m) =>
            m.id === menu.id ? { ...m, is_available: newStatus } : m,
        );

        const { error } = await supabase
            .from("menu_items")
            .update({ is_available: newStatus })
            .eq("id", menu.id);

        if (error) {
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

    $: if (formData.category === "paket") {
        formData.type = "package";
    }
</script>

<PageWrapper>
    <div class="space-y-6">
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
                                        >{formatPrice(menu.price)}</td
                                    >
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
                                                ><Pencil size={18} /></button
                                            >
                                            <button
                                                on:click={() =>
                                                    deleteMenu(menu)}
                                                class="p-1.5 text-gray-500 hover:text-red-600 hover:bg-red-50 rounded-md transition-colors"
                                                title="Hapus Menu"
                                                ><Trash2 size={18} /></button
                                            >
                                        </div>
                                    </td>
                                </tr>
                            {/each}
                        </tbody>
                    </table>
                </div>
            </div>
            {#if hasMore}
                <div bind:this={loadMoreRef} class="flex justify-center p-8">
                    {#if loading && menus.length > 0}<LoadingSpinner
                            size="sm"
                        />{/if}
                </div>
            {/if}
        {/if}
    </div>
</PageWrapper>

{#if showModal}
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
                    ><X size={20} /></button
                >
            </div>

            <div class="p-6 space-y-4 max-h-[70vh] overflow-y-auto">
                <div>
                    <label
                        for="image-upload"
                        class="block text-sm font-medium text-gray-700 mb-2"
                        >Foto Menu</label
                    >
                    <div class="flex items-center gap-4">
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
                                <div
                                    class="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center text-white"
                                >
                                    <Pencil size={16} />
                                </div>
                            {:else}
                                <ImageIcon size={24} class="text-gray-400" />
                            {/if}
                            <input
                                id="image-upload"
                                type="file"
                                accept="image/*"
                                on:change={handleFileSelect}
                                class="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                            />
                        </div>
                        <div class="flex-1">
                            <label
                                for="image-upload"
                                class="cursor-pointer text-sm text-blue-600 hover:underline"
                                >{previewUrl || formData.primary_image
                                    ? "Ganti Foto"
                                    : "Pilih Foto"}</label
                            >
                            <p class="text-xs text-gray-500 mt-1">
                                Maks 5MB (JPG/PNG)
                            </p>
                        </div>
                    </div>
                </div>

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
                        class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary outline-none text-sm"
                    />
                </div>

                <div>
                    <label
                        for="menu-category"
                        class="block text-sm font-medium text-gray-700 mb-1"
                        >Kategori</label
                    >
                    <select
                        id="menu-category"
                        bind:value={formData.category}
                        class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary outline-none text-sm bg-white"
                    >
                        {#each categories as category}<option
                                value={category}
                                class="capitalize">{category}</option
                            >{/each}
                    </select>
                </div>

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
                        class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary outline-none text-sm"
                    />
                    <p class="text-[10px] text-gray-400 mt-1">
                        * Set <b>0</b> jika ini adalah menu <b>Prasmanan</b>
                        (harga hanya dari pilihan), atau isi harga dasar jika ini
                        menu dengan <b>Topping</b>.
                    </p>
                </div>

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
                        class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary outline-none text-sm"
                    ></textarea>
                </div>

                <div class="flex items-center gap-2">
                    <input
                        type="checkbox"
                        id="available"
                        bind:checked={formData.is_available}
                        class="rounded text-primary focus:ring-primary"
                    />
                    <label for="available" class="text-sm text-gray-700"
                        >Tersedia untuk dipesan</label
                    >
                </div>

                <div class="pt-4 border-t border-gray-100">
                    <div class="flex items-center justify-between mb-4">
                        <label class="text-sm font-bold text-gray-900"
                            >Kustomisasi Menu</label
                        >
                        <select
                            bind:value={formData.type}
                            class="text-xs border border-gray-200 rounded px-2 py-1 bg-gray-50 outline-none focus:ring-1 focus:ring-primary"
                        >
                            <option value="single">Single Item</option>
                            <option value="package"
                                >Customizable (Prasmanan)</option
                            >
                        </select>
                    </div>

                    {#if formData.type === "package"}
                        <div class="space-y-6">
                            {#each optionGroups as group, gIndex}
                                <div
                                    class="p-4 bg-gray-50 rounded-xl border border-gray-200 space-y-4 relative group"
                                >
                                    <button
                                        on:click={() =>
                                            removeOptionGroup(gIndex)}
                                        class="absolute -top-2 -right-2 w-6 h-6 bg-red-500 text-white rounded-full flex items-center justify-center shadow-lg hover:bg-red-600 transition-colors z-10"
                                        ><X size={14} /></button
                                    >
                                    <div class="grid grid-cols-1 gap-3">
                                        <div>
                                            <label
                                                class="block text-[10px] font-black text-gray-400 uppercase mb-1"
                                                >Nama Grup (misal: Topping)</label
                                            >
                                            <input
                                                type="text"
                                                bind:value={group.name}
                                                placeholder="Nama grup..."
                                                class="w-full px-3 py-2 bg-white border border-gray-200 rounded-lg text-sm font-bold outline-none"
                                            />
                                        </div>
                                        <div
                                            class="flex items-center gap-4 py-1"
                                        >
                                            <label
                                                class="flex items-center gap-2 cursor-pointer"
                                                ><input
                                                    type="checkbox"
                                                    bind:checked={
                                                        group.is_required
                                                    }
                                                    class="rounded text-primary"
                                                /><span
                                                    class="text-xs font-bold text-gray-700"
                                                    >Wajib</span
                                                ></label
                                            >
                                            <div
                                                class="flex items-center gap-2"
                                            >
                                                <span
                                                    class="text-[10px] font-black text-gray-400"
                                                    >Min:</span
                                                ><input
                                                    type="number"
                                                    bind:value={
                                                        group.min_selection
                                                    }
                                                    min="0"
                                                    class="w-12 px-1 py-0.5 text-xs border border-gray-200 rounded"
                                                />
                                            </div>
                                            <div
                                                class="flex items-center gap-2"
                                            >
                                                <span
                                                    class="text-[10px] font-black text-gray-400"
                                                    >Max:</span
                                                ><input
                                                    type="number"
                                                    bind:value={
                                                        group.max_selection
                                                    }
                                                    min="1"
                                                    class="w-12 px-1 py-0.5 text-xs border border-gray-200 rounded"
                                                />
                                            </div>
                                        </div>
                                    </div>
                                    <div
                                        class="space-y-2 pt-2 border-t border-gray-200/50"
                                    >
                                        {#each group.items as item, iIndex}
                                            <div
                                                class="flex items-center gap-2"
                                            >
                                                <input
                                                    type="text"
                                                    bind:value={item.name}
                                                    placeholder="Item..."
                                                    class="flex-1 px-2 py-1.5 bg-white border border-gray-100 rounded text-xs outline-none"
                                                />
                                                <div
                                                    class="flex items-center gap-1 bg-white border border-gray-100 rounded px-1.5"
                                                >
                                                    <span
                                                        class="text-[10px] text-gray-400 font-bold"
                                                        >Rp</span
                                                    ><input
                                                        type="number"
                                                        bind:value={
                                                            item.additional_price
                                                        }
                                                        class="w-16 py-1.5 text-xs font-bold outline-none"
                                                    />
                                                </div>
                                                <button
                                                    on:click={() =>
                                                        removeOptionItem(
                                                            gIndex,
                                                            iIndex,
                                                        )}
                                                    class="p-1 text-gray-300 hover:text-red-500"
                                                    ><Trash2
                                                        size={14}
                                                    /></button
                                                >
                                            </div>
                                        {/each}
                                        <button
                                            on:click={() =>
                                                addOptionItem(gIndex)}
                                            class="w-full py-2 mt-2 rounded-lg border border-dashed border-gray-300 text-gray-400 hover:text-primary transition-all text-[10px] font-black uppercase flex items-center justify-center gap-2"
                                            ><Plus size={12} /> Tambah Item</button
                                        >
                                    </div>
                                </div>
                            {/each}
                            <button
                                on:click={addOptionGroup}
                                class="w-full py-3 rounded-xl border-2 border-dashed border-primary/20 text-primary hover:bg-primary/5 transition-all font-bold text-xs flex items-center justify-center gap-2"
                                ><Plus size={16} /> Tambah Grup Baru</button
                            >
                        </div>
                    {:else}
                        <p
                            class="text-xs text-gray-400 text-center py-4 italic"
                        >
                            Pilih tipe "Customizable" untuk menambahkan pilihan
                            kustomisasi.
                        </p>
                    {/if}
                </div>
            </div>

            <div
                class="p-4 border-t border-gray-100 bg-gray-50 flex justify-end gap-2"
            >
                <button
                    on:click={() => (showModal = false)}
                    disabled={isUploading}
                    class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors disabled:opacity-50"
                    >Batal</button
                >
                <button
                    on:click={handleSubmit}
                    disabled={isUploading}
                    class="px-4 py-2 text-sm font-medium text-white bg-primary rounded-lg hover:bg-primary/90 transition-colors flex items-center gap-2 disabled:opacity-70 disabled:cursor-not-allowed"
                    >{#if isUploading}<div
                            class="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"
                        ></div>{:else}<Check size={16} /> Simpan{/if}</button
                >
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
