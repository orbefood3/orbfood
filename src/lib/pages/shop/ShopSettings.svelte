<script lang="ts">
    import { onMount } from "svelte";
    import { supabase } from "../../services/supabase";
    import {
        uploadImage,
        getOptimizedImageUrl,
    } from "../../services/cloudinary";
    import {
        Save,
        Upload,
        MapPin,
        MessageSquare,
        Clock,
        Store,
        Image as ImageIcon,
        Loader2,
        CheckCircle2,
        Instagram,
        Globe,
        Truck,
        Link as LinkIcon,
    } from "lucide-svelte";

    export let shopId: string;

    let loading = true;
    let saving = false;
    let successMessage = "";
    let shopData: any = null;
    let villages: any[] = [];
    let uploadingLogo = false;
    let uploadingBanner = false;

    // Form State
    let name = "";
    let description = "";
    let category = "";
    let address = "";
    let village_id = "";
    let whatsapp = "";
    let google_maps_url = "";
    let instagram_url = "";
    let tiktok_url = "";
    let is_delivery_available = false;
    let is_open = true;
    let logo_url = "";
    let banner_url = "";

    // Simplified Hours Form State
    let start_day = "monday";
    let end_day = "friday";
    let open_time = "08:00";
    let close_time = "20:00";

    const days = [
        { key: "monday", label: "Senin" },
        { key: "tuesday", label: "Selasa" },
        { key: "wednesday", label: "Rabu" },
        { key: "thursday", label: "Kamis" },
        { key: "friday", label: "Jumat" },
        { key: "saturday", label: "Sabtu" },
        { key: "sunday", label: "Minggu" },
    ];

    onMount(async () => {
        await Promise.all([fetchShop(), fetchVillages()]);
    });

    async function fetchVillages() {
        const { data } = await supabase
            .from("villages")
            .select("*")
            .order("name");
        villages = data || [];
    }

    async function fetchShop() {
        loading = true;
        const { data, error } = await supabase
            .from("shops")
            .select("*")
            .eq("id", shopId)
            .single();

        if (error) {
            console.error("Error fetching shop:", error);
        } else {
            shopData = data;
            name = data.name;
            description = data.description || "";
            category = data.category;
            address = data.address || "";
            village_id = data.village_id || "";
            whatsapp = data.whatsapp || "";
            google_maps_url = data.google_maps_url || "";
            instagram_url = data.instagram_url || "";
            tiktok_url = data.tiktok_url || "";
            is_delivery_available = data.is_delivery_available || false;
            is_open = data.is_open;
            logo_url = data.logo_url || "";
            banner_url = data.banner_url || "";

            if (
                data.business_hours &&
                typeof data.business_hours === "object" &&
                !Array.isArray(data.business_hours)
            ) {
                // If it's already simplified format
                if (data.business_hours.start_day) {
                    start_day = data.business_hours.start_day;
                    end_day = data.business_hours.end_day;
                    open_time = data.business_hours.open_time;
                    close_time = data.business_hours.close_time;
                }
            }
        }
        loading = false;
    }

    async function handleImageUpload(e: Event, type: "logo" | "banner") {
        const file = (e.target as HTMLInputElement).files?.[0];
        if (!file) return;

        if (type === "logo") uploadingLogo = true;
        else uploadingBanner = true;

        try {
            const url = await uploadImage(file);
            if (type === "logo") logo_url = url;
            else banner_url = url;
        } catch (err) {
            alert("Gagal upload gambar: " + (err as Error).message);
        } finally {
            if (type === "logo") uploadingLogo = false;
            else uploadingBanner = false;
        }
    }

    async function handleSave() {
        saving = true;
        successMessage = "";

        // Package business hours into simple object
        const businessHoursData = {
            start_day,
            end_day,
            open_time,
            close_time,
        };

        const { error } = await supabase
            .from("shops")
            .update({
                name,
                description,
                category,
                address,
                village_id: village_id || null,
                whatsapp,
                google_maps_url,
                instagram_url,
                tiktok_url,
                is_delivery_available,
                phone: whatsapp,
                is_open,
                logo_url,
                banner_url,
                business_hours: businessHoursData,
                updated_at: new Date().toISOString(),
            })
            .eq("id", shopId);

        if (error) {
            alert("Gagal menyimpan: " + error.message);
        } else {
            successMessage = "Pengaturan toko berhasil disimpan!";
            setTimeout(() => (successMessage = ""), 3000);
        }
        saving = false;
    }
</script>

<div class="space-y-8 pb-20 px-4 md:px-0">
    <!-- Header Section -->
    <div
        class="flex flex-col md:flex-row md:items-center justify-between gap-4"
    >
        <div>
            <h2 class="text-2xl font-bold text-gray-900">Pengaturan Toko</h2>
            <p class="text-gray-500">
                Kelola informasi profil, sosial media, dan operasional.
            </p>
        </div>
        <button
            on:click={handleSave}
            disabled={saving}
            class="flex items-center justify-center gap-2 px-6 py-2.5 bg-gray-900 text-white rounded-xl font-semibold hover:bg-gray-800 transition-all disabled:opacity-50"
        >
            {#if saving}
                <Loader2 class="w-5 h-5 animate-spin" />
                Menyimpan...
            {:else}
                <Save class="w-5 h-5" />
                Simpan Perubahan
            {/if}
        </button>
    </div>

    {#if successMessage}
        <div
            class="bg-green-50 border border-green-100 text-green-700 px-4 py-3 rounded-xl flex items-center gap-3 animate-in fade-in slide-in-from-top-2"
        >
            <CheckCircle2 class="w-5 h-5" />
            <span class="font-medium">{successMessage}</span>
        </div>
    {/if}

    {#if loading}
        <div class="flex justify-center py-20">
            <Loader2 class="w-10 h-10 animate-spin text-gray-300" />
        </div>
    {:else}
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <!-- Left Column: Profile & Branding -->
            <div class="lg:col-span-2 space-y-6">
                <!-- Branding Card -->
                <div
                    class="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden"
                >
                    <div class="p-6 border-b border-gray-50 bg-gray-50/50">
                        <h3
                            class="font-bold text-gray-900 flex items-center gap-2"
                        >
                            <Store class="w-5 h-5 text-gray-400" />
                            Profil & Branding
                        </h3>
                    </div>
                    <div class="p-6 space-y-6">
                        <!-- Banner & Logo UI (Same as before but refined) -->
                        <div
                            class="relative h-48 bg-gray-100 rounded-xl overflow-hidden group"
                        >
                            {#if banner_url}
                                <img
                                    src={getOptimizedImageUrl(banner_url, 800)}
                                    alt="Banner"
                                    class="w-full h-full object-cover"
                                />
                            {:else}
                                <div
                                    class="w-full h-full flex flex-col items-center justify-center text-gray-400"
                                >
                                    <ImageIcon class="w-10 h-10 mb-2" />
                                    <span class="text-sm">Belum ada banner</span
                                    >
                                </div>
                            {/if}

                            {#if uploadingBanner}
                                <div
                                    class="absolute inset-0 bg-black/40 backdrop-blur-sm flex items-center justify-center text-white"
                                >
                                    <Loader2 class="w-8 h-8 animate-spin" />
                                </div>
                            {/if}

                            <label
                                class="absolute bottom-4 right-4 cursor-pointer bg-white/90 backdrop-blur shadow-lg px-4 py-2 rounded-lg text-sm font-bold text-gray-900 hover:bg-white transition-all"
                            >
                                <input
                                    type="file"
                                    accept="image/*"
                                    class="hidden"
                                    on:change={(e) =>
                                        handleImageUpload(e, "banner")}
                                />
                                {uploadingBanner
                                    ? "Mengunggah..."
                                    : "Pilih Banner"}
                            </label>

                            <!-- Logo Overlay -->
                            <div
                                class="absolute -bottom-1 left-6 w-24 h-24 rounded-2xl bg-white p-1.5 shadow-xl border border-white"
                            >
                                <div
                                    class="w-full h-full rounded-xl bg-gray-50 overflow-hidden relative group/logo"
                                >
                                    {#if logo_url}
                                        <img
                                            src={getOptimizedImageUrl(
                                                logo_url,
                                                200,
                                            )}
                                            alt="Logo"
                                            class="w-full h-full object-cover"
                                        />
                                    {:else}
                                        <div
                                            class="w-full h-full flex items-center justify-center text-gray-300"
                                        >
                                            <Store class="w-8 h-8" />
                                        </div>
                                    {/if}

                                    {#if uploadingLogo}
                                        <div
                                            class="absolute inset-0 bg-black/40 flex items-center justify-center text-white"
                                        >
                                            <Loader2
                                                class="w-5 h-5 animate-spin"
                                            />
                                        </div>
                                    {/if}

                                    <label
                                        class="absolute inset-0 bg-black/40 opacity-0 group-hover/logo:opacity-100 flex items-center justify-center cursor-pointer transition-all"
                                    >
                                        <input
                                            type="file"
                                            accept="image/*"
                                            class="hidden"
                                            on:change={(e) =>
                                                handleImageUpload(e, "logo")}
                                        />
                                        <Upload class="w-6 h-6 text-white" />
                                    </label>
                                </div>
                            </div>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mt-8">
                            <div class="space-y-2">
                                <label
                                    for="shop_name"
                                    class="text-sm font-bold text-gray-700"
                                    >Nama Toko</label
                                >
                                <input
                                    id="shop_name"
                                    type="text"
                                    bind:value={name}
                                    class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:ring-2 focus:ring-gray-900 focus:border-transparent outline-none transition-all"
                                    placeholder="Nama toko Anda"
                                />
                            </div>
                            <div class="space-y-2">
                                <label
                                    for="shop_category"
                                    class="text-sm font-bold text-gray-700"
                                    >Kategori</label
                                >
                                <select
                                    id="shop_category"
                                    bind:value={category}
                                    class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:ring-2 focus:ring-gray-900 focus:border-transparent outline-none transition-all"
                                >
                                    <option value="makanan">Makanan</option>
                                    <option value="minuman">Minuman</option>
                                    <option value="camilan">Camilan</option>
                                    <option value="lainnya">Lainnya</option>
                                </select>
                            </div>
                            <div class="space-y-2 md:col-span-2">
                                <label
                                    for="shop_description"
                                    class="text-sm font-bold text-gray-700"
                                    >Deskripsi Toko</label
                                >
                                <textarea
                                    id="shop_description"
                                    bind:value={description}
                                    rows="3"
                                    class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:ring-2 focus:ring-gray-900 focus:border-transparent outline-none transition-all"
                                    placeholder="Ceritakan tentang toko Anda..."
                                ></textarea>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Kontak & Sosial Card -->
                <div
                    class="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden"
                >
                    <div class="p-6 border-b border-gray-50 bg-gray-50/50">
                        <h3
                            class="font-bold text-gray-900 flex items-center gap-2"
                        >
                            <Globe class="w-5 h-5 text-gray-400" />
                            Kontak & Sosial Media
                        </h3>
                    </div>
                    <div class="p-6 space-y-6">
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div class="space-y-2">
                                <label
                                    for="shop_whatsapp"
                                    class="text-sm font-bold text-gray-700"
                                    >Nomor WhatsApp</label
                                >
                                <div class="relative">
                                    <MessageSquare
                                        class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400"
                                    />
                                    <input
                                        id="shop_whatsapp"
                                        type="tel"
                                        bind:value={whatsapp}
                                        class="w-full pl-12 pr-4 py-3 rounded-xl border border-gray-200 focus:ring-2 focus:ring-gray-900 focus:border-transparent outline-none transition-all"
                                        placeholder="Contoh: 0812..."
                                    />
                                </div>
                            </div>
                            <div class="space-y-2">
                                <label
                                    for="shop_instagram"
                                    class="text-sm font-bold text-gray-700"
                                    >Instagram Username (Tanpa @)</label
                                >
                                <div class="relative">
                                    <Instagram
                                        class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400"
                                    />
                                    <input
                                        id="shop_instagram"
                                        type="text"
                                        bind:value={instagram_url}
                                        class="w-full pl-12 pr-4 py-3 rounded-xl border border-gray-200 focus:ring-2 focus:ring-gray-900 focus:border-transparent outline-none transition-all"
                                        placeholder="Contoh: orbfood.id"
                                    />
                                </div>
                            </div>
                            <div class="space-y-2">
                                <label
                                    for="shop_tiktok"
                                    class="text-sm font-bold text-gray-700"
                                    >TikTok Username (Tanpa @)</label
                                >
                                <div class="relative">
                                    <span
                                        class="absolute left-4 top-1/2 -translate-y-1/2 font-bold text-gray-400"
                                        >T</span
                                    >
                                    <input
                                        id="shop_tiktok"
                                        type="text"
                                        bind:value={tiktok_url}
                                        class="w-full pl-12 pr-4 py-3 rounded-xl border border-gray-200 focus:ring-2 focus:ring-gray-900 focus:border-transparent outline-none transition-all"
                                        placeholder="Contoh: orbfood"
                                    />
                                </div>
                            </div>
                            <div class="space-y-2">
                                <label
                                    for="shop_gmaps"
                                    class="text-sm font-bold text-gray-700"
                                    >Link Google Maps</label
                                >
                                <div class="relative">
                                    <LinkIcon
                                        class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400"
                                    />
                                    <input
                                        id="shop_gmaps"
                                        type="url"
                                        bind:value={google_maps_url}
                                        class="w-full pl-12 pr-4 py-3 rounded-xl border border-gray-200 focus:ring-2 focus:ring-gray-900 focus:border-transparent outline-none transition-all"
                                        placeholder="https://maps.google..."
                                    />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Right Column: Location & Hours -->
            <div class="space-y-6">
                <!-- Location & Delivery -->
                <div
                    class="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden"
                >
                    <div class="p-6 border-b border-gray-50 bg-gray-50/50">
                        <h3
                            class="font-bold text-gray-900 flex items-center gap-2"
                        >
                            <MapPin class="w-5 h-5 text-gray-400" />
                            Lokasi & Layanan
                        </h3>
                    </div>
                    <div class="p-6 space-y-6">
                        <div class="space-y-2">
                            <label
                                for="shop_village"
                                class="text-sm font-bold text-gray-700"
                                >Pilih Desa</label
                            >
                            <select
                                id="shop_village"
                                bind:value={village_id}
                                class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:ring-2 focus:ring-gray-900 focus:border-transparent outline-none transition-all text-sm"
                            >
                                <option value="">Pilih Desa...</option>
                                {#each villages as village}
                                    <option value={village.id}
                                        >{village.name}</option
                                    >
                                {/each}
                            </select>
                            <p class="text-xs text-gray-400">
                                Digunakan pelanggan untuk memfilter toko
                                terdekat.
                            </p>
                        </div>

                        <div class="space-y-2">
                            <label
                                for="shop_address"
                                class="text-sm font-bold text-gray-700"
                                >Alamat Lengkap</label
                            >
                            <textarea
                                id="shop_address"
                                bind:value={address}
                                rows="2"
                                class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:ring-2 focus:ring-gray-900 focus:border-transparent outline-none transition-all text-sm"
                                placeholder="Jl. Mawar No. 123..."
                            ></textarea>
                        </div>

                        <div
                            class="pt-4 border-t border-gray-50 flex items-center justify-between"
                        >
                            <div class="flex items-center gap-3">
                                <div
                                    class="p-2 bg-blue-50 text-blue-600 rounded-lg"
                                >
                                    <Truck class="w-5 h-5" />
                                </div>
                                <div>
                                    <p class="text-sm font-bold text-gray-900">
                                        Layanan Delivery
                                    </p>
                                    <p class="text-xs text-gray-500">
                                        Tersedia pengiriman ke rumah
                                    </p>
                                </div>
                            </div>
                            <button
                                on:click={() =>
                                    (is_delivery_available =
                                        !is_delivery_available)}
                                class="relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none {is_delivery_available
                                    ? 'bg-primary'
                                    : 'bg-gray-200'}"
                            >
                                <span
                                    class="inline-block h-4 w-4 transform rounded-full bg-white transition-transform {is_delivery_available
                                        ? 'translate-x-6'
                                        : 'translate-x-1'}"
                                />
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Simplified Hours -->
                <div
                    class="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden"
                >
                    <div
                        class="p-6 border-b border-gray-50 bg-gray-50/50 flex items-center justify-between"
                    >
                        <h3
                            class="font-bold text-gray-900 flex items-center gap-2"
                        >
                            <Clock class="w-5 h-5 text-gray-400" />
                            Jam Operasional
                        </h3>
                        <button
                            on:click={() => (is_open = !is_open)}
                            class="relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none {is_open
                                ? 'bg-green-500'
                                : 'bg-gray-200'}"
                        >
                            <span
                                class="inline-block h-4 w-4 transform rounded-full bg-white transition-transform {is_open
                                    ? 'translate-x-6'
                                    : 'translate-x-1'}"
                            />
                        </button>
                    </div>
                    <div class="p-6 space-y-6">
                        <div
                            class="flex items-center gap-2 p-3 rounded-lg {is_open
                                ? 'bg-green-50 text-green-700'
                                : 'bg-red-50 text-red-700'}"
                        >
                            <div
                                class="w-2 h-2 rounded-full {is_open
                                    ? 'bg-green-500 animate-pulse'
                                    : 'bg-red-500'}"
                            ></div>
                            <span
                                class="text-xs font-bold uppercase tracking-wider"
                                >{is_open
                                    ? "Toko Sedang Buka"
                                    : "Toko Sedang Tutup"}</span
                            >
                        </div>

                        <div class="space-y-4">
                            <div class="grid grid-cols-2 gap-4">
                                <div class="space-y-2">
                                    <label
                                        for="hours_start_day"
                                        class="text-xs font-bold text-gray-500 uppercase"
                                        >Dari Hari</label
                                    >
                                    <select
                                        id="hours_start_day"
                                        bind:value={start_day}
                                        class="w-full px-3 py-2 rounded-lg border border-gray-200 text-sm outline-none transition-all"
                                    >
                                        {#each days as day}
                                            <option value={day.key}
                                                >{day.label}</option
                                            >
                                        {/each}
                                    </select>
                                </div>
                                <div class="space-y-2">
                                    <label
                                        for="hours_end_day"
                                        class="text-xs font-bold text-gray-500 uppercase"
                                        >Sampai Hari</label
                                    >
                                    <select
                                        id="hours_end_day"
                                        bind:value={end_day}
                                        class="w-full px-3 py-2 rounded-lg border border-gray-200 text-sm outline-none transition-all"
                                    >
                                        {#each days as day}
                                            <option value={day.key}
                                                >{day.label}</option
                                            >
                                        {/each}
                                    </select>
                                </div>
                            </div>

                            <div class="grid grid-cols-2 gap-4">
                                <div class="space-y-2">
                                    <label
                                        for="hours_open_time"
                                        class="text-xs font-bold text-gray-500 uppercase"
                                        >Buka Pukul</label
                                    >
                                    <input
                                        id="hours_open_time"
                                        type="time"
                                        bind:value={open_time}
                                        class="w-full px-3 py-2 rounded-lg border border-gray-200 text-sm outline-none transition-all"
                                    />
                                </div>
                                <div class="space-y-2">
                                    <label
                                        for="hours_close_time"
                                        class="text-xs font-bold text-gray-500 uppercase"
                                        >Tutup Pukul</label
                                    >
                                    <input
                                        id="hours_close_time"
                                        type="time"
                                        bind:value={close_time}
                                        class="w-full px-3 py-2 rounded-lg border border-gray-200 text-sm outline-none transition-all"
                                    />
                                </div>
                            </div>
                        </div>

                        <div class="p-3 bg-gray-50 rounded-xl">
                            <p
                                class="text-[10px] text-gray-400 text-center italic"
                            >
                                * Di luar rentang hari/jam ini, toko akan
                                otomatis ditampilkan tutup di sisi pelanggan.
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    {/if}
</div>
