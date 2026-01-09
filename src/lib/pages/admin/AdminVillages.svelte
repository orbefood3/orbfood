<script lang="ts">
    import { onMount } from "svelte";
    import { supabase } from "../../services/supabase";
    import {
        Plus,
        Search,
        Pencil,
        Trash2,
        X,
        Save,
        Loader2,
        MapPin,
        AlertCircle,
    } from "lucide-svelte";

    let villages: any[] = [];
    let loading = true;
    let searchTerm = "";

    // Modal State
    let showModal = false;
    let modalLoading = false;
    let editingVillage: any = null;
    let villageName = "";

    $: filteredVillages = villages.filter((v) =>
        v.name.toLowerCase().includes(searchTerm.toLowerCase()),
    );

    onMount(() => {
        fetchVillages();
    });

    async function fetchVillages() {
        loading = true;
        const { data, error } = await supabase
            .from("villages")
            .select("*")
            .order("name");

        if (error) {
            console.error("Error fetching villages:", error);
        } else {
            villages = data || [];
        }
        loading = false;
    }

    function openModal(village: any = null) {
        editingVillage = village;
        villageName = village ? village.name : "";
        showModal = true;
    }

    async function handleSave() {
        if (!villageName.trim()) return;

        modalLoading = true;
        if (editingVillage) {
            // Update
            const { error } = await supabase
                .from("villages")
                .update({ name: villageName.trim() })
                .eq("id", editingVillage.id);

            if (error) alert("Gagal update: " + error.message);
            else {
                showModal = false;
                fetchVillages();
            }
        } else {
            // Insert
            const { error } = await supabase
                .from("villages")
                .insert({ name: villageName.trim() });

            if (error) alert("Gagal tambah: " + error.message);
            else {
                showModal = false;
                fetchVillages();
            }
        }
        modalLoading = false;
    }

    async function handleDelete(id: string, name: string) {
        if (
            !confirm(
                `Hapus desa "${name}"? Ini mungkin berdampak pada toko yang terdaftar di desa ini.`,
            )
        )
            return;

        const { error } = await supabase.from("villages").delete().eq("id", id);

        if (error) alert("Gagal hapus: " + error.message);
        else fetchVillages();
    }
</script>

<div class="space-y-6">
    <!-- Header & Actions -->
    <div
        class="flex flex-col md:flex-row md:items-center justify-between gap-4"
    >
        <div>
            <h2 class="text-2xl font-bold text-gray-900">Manajemen Desa</h2>
            <p class="text-gray-500 text-sm">
                Kelola daftar desa yang tersedia untuk lokasi toko.
            </p>
        </div>

        <div class="flex items-center gap-3">
            <div class="relative flex-1 md:w-64">
                <Search
                    class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400"
                />
                <input
                    type="text"
                    bind:value={searchTerm}
                    placeholder="Cari desa..."
                    class="w-full pl-10 pr-4 py-2 bg-white border border-gray-200 rounded-xl text-sm outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all"
                />
            </div>
            <button
                on:click={() => openModal()}
                class="flex items-center gap-2 px-4 py-2 bg-gray-900 text-white rounded-xl font-semibold hover:bg-gray-800 transition-all shadow-sm"
            >
                <Plus class="w-4 h-4" />
                Tambah Desa
            </button>
        </div>
    </div>

    <!-- Villages Table -->
    <div
        class="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden"
    >
        {#if loading}
            <div
                class="flex flex-col items-center justify-center py-20 text-gray-400"
            >
                <Loader2 class="w-8 h-8 animate-spin mb-2" />
                <p class="text-sm">Memuat daftar desa...</p>
            </div>
        {:else if filteredVillages.length === 0}
            <div
                class="flex flex-col items-center justify-center py-20 text-gray-400"
            >
                <div class="bg-gray-50 p-4 rounded-full mb-4">
                    <MapPin class="w-8 h-8 text-gray-300" />
                </div>
                <p class="text-gray-500 font-medium">
                    Tidak ada desa ditemukan
                </p>
                <p class="text-sm">Silakan tambahkan desa baru</p>
            </div>
        {:else}
            <div class="overflow-x-auto">
                <table class="w-full text-left">
                    <thead class="bg-gray-50/50 border-b border-gray-100">
                        <tr>
                            <th
                                class="px-6 py-4 text-xs font-bold text-gray-400 uppercase tracking-wider"
                                >Nama Desa</th
                            >
                            <th
                                class="px-6 py-4 text-xs font-bold text-gray-400 uppercase tracking-wider"
                                >Tanggal Dibuat</th
                            >
                            <th
                                class="px-6 py-4 text-xs font-bold text-gray-400 uppercase tracking-wider text-right"
                                >Aksi</th
                            >
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100">
                        {#each filteredVillages as village}
                            <tr
                                class="hover:bg-gray-50/50 transition-colors group"
                            >
                                <td class="px-6 py-4 font-bold text-gray-900"
                                    >{village.name}</td
                                >
                                <td class="px-6 py-4 text-sm text-gray-500">
                                    {new Date(
                                        village.created_at,
                                    ).toLocaleDateString("id-ID", {
                                        day: "numeric",
                                        month: "long",
                                        year: "numeric",
                                    })}
                                </td>
                                <td class="px-6 py-4 text-right">
                                    <div
                                        class="flex items-center justify-end gap-2 opacity-0 group-hover:opacity-100 transition-all"
                                    >
                                        <button
                                            on:click={() => openModal(village)}
                                            class="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                                            title="Edit"
                                        >
                                            <Pencil class="w-4 h-4" />
                                        </button>
                                        <button
                                            on:click={() =>
                                                handleDelete(
                                                    village.id,
                                                    village.name,
                                                )}
                                            class="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                                            title="Hapus"
                                        >
                                            <Trash2 class="w-4 h-4" />
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        {/each}
                    </tbody>
                </table>
            </div>
        {/if}
    </div>
</div>

<!-- Modal Village -->
{#if showModal}
    <div class="fixed inset-0 z-50 flex items-center justify-center p-4">
        <div
            class="absolute inset-0 bg-gray-900/60 backdrop-blur-sm"
            on:click={() => !modalLoading && (showModal = false)}
        ></div>

        <div
            class="relative bg-white rounded-3xl w-full max-w-md shadow-2xl overflow-hidden animate-in zoom-in-95 duration-200"
        >
            <div
                class="p-6 border-b border-gray-100 flex items-center justify-between"
            >
                <h3 class="text-xl font-bold text-gray-900">
                    {editingVillage ? "Edit Nama Desa" : "Tambah Desa Baru"}
                </h3>
                <button
                    on:click={() => (showModal = false)}
                    class="p-2 hover:bg-gray-100 rounded-xl transition-all"
                >
                    <X class="w-5 h-5" />
                </button>
            </div>

            <div class="p-6 space-y-4">
                <div class="space-y-2">
                    <label class="text-sm font-bold text-gray-700"
                        >Nama Desa</label
                    >
                    <input
                        type="text"
                        bind:value={villageName}
                        placeholder="Contoh: Sukamaju"
                        class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all"
                        autofocus
                    />
                </div>

                {#if editingVillage}
                    <div
                        class="flex items-start gap-3 p-3 bg-blue-50 text-blue-700 rounded-xl text-xs"
                    >
                        <AlertCircle class="w-4 h-4 flex-shrink-0" />
                        <p>
                            Perubahan nama desa akan langsung berdampak pada
                            filter lokasi toko yang terdaftar di desa ini.
                        </p>
                    </div>
                {/if}
            </div>

            <div class="p-6 bg-gray-50 border-t border-gray-100 flex gap-3">
                <button
                    on:click={() => (showModal = false)}
                    disabled={modalLoading}
                    class="flex-1 px-4 py-2.5 bg-white border border-gray-200 text-gray-700 rounded-xl font-bold hover:bg-gray-100 transition-all disabled:opacity-50"
                >
                    Batal
                </button>
                <button
                    on:click={handleSave}
                    disabled={modalLoading || !villageName.trim()}
                    class="flex-1 px-4 py-2.5 bg-primary text-white rounded-xl font-bold hover:bg-primary/90 transition-all shadow-sm disabled:opacity-50 flex items-center justify-center gap-2"
                >
                    {#if modalLoading}
                        <Loader2 class="w-4 h-4 animate-spin" />
                        Proses...
                    {:else}
                        <Save class="w-4 h-4" />
                        Simpan
                    {/if}
                </button>
            </div>
        </div>
    </div>
{/if}
