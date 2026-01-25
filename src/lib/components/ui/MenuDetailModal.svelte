<script lang="ts">
    import { X, ShoppingBag, Check, Info, Loader2 } from "lucide-svelte";
    import { createEventDispatcher, onMount } from "svelte";
    import { getOptimizedImageUrl } from "../../services/cloudinary";
    import { supabase } from "../../services/supabase";

    export let show = false;
    export let item: any;
    export let onAdd: (item: any) => void;

    const dispatch = createEventDispatcher();
    let packageItems: any[] = [];
    let selectedItemIds: string[] = [];
    let loadingPackage = false;

    onMount(async () => {
        if (show && item?.is_package) {
            await fetchPackageItems();
        }
    });

    async function fetchPackageItems() {
        if (!item?.id) return;
        loadingPackage = true;
        try {
            const { data, error } = await supabase
                .from("menu_package_items")
                .select(
                    `
          child_menu_id,
          quantity,
          menu_items!menu_package_items_child_menu_id_fkey (
            name,
            primary_image,
            description
          )
        `,
                )
                .eq("parent_menu_id", item.id);

            if (error) throw error;
            packageItems = data || [];
            // Default: all selected
            if (packageItems.length > 0) {
                selectedItemIds = packageItems.map((p) => p.child_menu_id);
            }
        } catch (err) {
            console.error("Error fetching package items:", err);
        } finally {
            loadingPackage = false;
        }
    }

    // Reactive fetch when item changes or modal opens
    $: if (show && item?.is_package && packageItems.length === 0) {
        fetchPackageItems();
    } else if (!show) {
        packageItems = [];
        selectedItemIds = [];
    }

    function handleClose() {
        dispatch("close");
    }

    $: extraPriceTotal = packageItems
        .filter((p) => selectedItemIds.includes(p.child_menu_id))
        .reduce(
            (sum, p) => sum + (p.additional_price || 0) * (p.quantity || 1),
            0,
        );

    $: finalPrice = (item.price || 0) + extraPriceTotal;

    function handleAddToCart() {
        const itemWithSelection = {
            ...item,
            price: finalPrice, // Use calculated price
            package_items: packageItems
                .filter((p) => selectedItemIds.includes(p.child_menu_id))
                .map((p) => ({
                    id: p.child_menu_id,
                    name: p.menu_items?.name,
                    qty: p.quantity,
                    extra_price: p.additional_price,
                })),
        };
        onAdd(itemWithSelection);
        handleClose();
    }
</script>

{#if show}
    <div
        class="fixed inset-0 z-[100] flex items-end sm:items-center justify-center p-0 sm:p-4"
    >
        <!-- Backdrop -->
        <!-- svelte-ignore a11y-click-events-have-key-events -->
        <!-- svelte-ignore a11y-no-static-element-interactions -->
        <div
            class="absolute inset-0 bg-black/60 backdrop-blur-sm animate-in fade-in duration-300"
            on:click={handleClose}
        ></div>

        <!-- Modal Content -->
        <div
            class="relative bg-white w-full max-w-lg rounded-t-[2.5rem] sm:rounded-[2.5rem] shadow-2xl overflow-hidden animate-in slide-in-from-bottom-full sm:zoom-in-95 duration-300 flex flex-col max-h-[90vh]"
        >
            <!-- Close Button -->
            <button
                on:click={handleClose}
                class="absolute top-4 right-4 z-50 p-2 bg-white/80 backdrop-blur-md rounded-full text-gray-900 shadow-sm hover:bg-white transition-all"
            >
                <X size={20} />
            </button>

            <div class="overflow-y-auto pb-24">
                <!-- Hero Image -->
                <div class="h-64 sm:h-72 w-full relative">
                    <img
                        src={getOptimizedImageUrl(
                            item.primary_image || item.image || "",
                            800,
                        )}
                        alt={item.name}
                        class="w-full h-full object-cover"
                    />
                    <div
                        class="absolute inset-x-0 bottom-0 h-24 bg-gradient-to-t from-white to-transparent"
                    ></div>
                </div>

                <!-- Content -->
                <div class="px-6 py-4">
                    <div class="flex items-start justify-between mb-4">
                        <div>
                            <span
                                class="inline-block px-2 py-1 rounded-md bg-primary/10 text-primary text-[10px] font-black uppercase mb-2"
                            >
                                {item.category || "Menu"}
                            </span>
                            <h2
                                class="text-2xl font-black text-gray-900 leading-tight"
                            >
                                {item.name}
                            </h2>
                        </div>
                        <div class="text-right">
                            <span class="text-xl font-black text-primary">
                                Rp {item.price.toLocaleString()}
                            </span>
                        </div>
                    </div>

                    <div class="bg-gray-50 rounded-2xl p-4 mb-6">
                        <h4
                            class="text-xs font-black text-gray-400 uppercase mb-2 flex items-center gap-1"
                        >
                            <Info size={12} /> Deskripsi
                        </h4>
                        <p
                            class="text-gray-600 text-sm leading-relaxed whitespace-pre-line"
                        >
                            {item.description ||
                                "Belum ada deskripsi untuk menu ini."}
                        </p>
                    </div>

                    <!-- Package Items Section -->
                    {#if item.is_package}
                        <div class="mt-6">
                            <h3
                                class="text-sm font-black text-gray-900 mb-4 px-1 flex items-center justify-between"
                            >
                                <span>📦 Isi Paket Ini</span>
                                {#if loadingPackage}
                                    <Loader2
                                        size={16}
                                        class="animate-spin text-primary"
                                    />
                                {/if}
                            </h3>

                            {#if packageItems.length > 0}
                                <div class="space-y-3">
                                    {#each packageItems as pItem}
                                        <!-- svelte-ignore a11y-click-events-have-key-events -->
                                        <!-- svelte-ignore a11y-no-static-element-interactions -->
                                        <div
                                            class="flex items-center gap-3 p-3 bg-white border {selectedItemIds.includes(
                                                pItem.child_menu_id,
                                            )
                                                ? 'border-primary shadow-md shadow-primary/5'
                                                : 'border-gray-100'} rounded-2xl transition-all cursor-pointer"
                                            on:click={() => {
                                                if (
                                                    selectedItemIds.includes(
                                                        pItem.child_menu_id,
                                                    )
                                                ) {
                                                    selectedItemIds =
                                                        selectedItemIds.filter(
                                                            (id) =>
                                                                id !==
                                                                pItem.child_menu_id,
                                                        );
                                                } else {
                                                    selectedItemIds = [
                                                        ...selectedItemIds,
                                                        pItem.child_menu_id,
                                                    ];
                                                }
                                            }}
                                        >
                                            <div
                                                class="w-12 h-12 rounded-xl bg-gray-50 overflow-hidden flex-shrink-0 border border-gray-50"
                                            >
                                                <img
                                                    src={getOptimizedImageUrl(
                                                        pItem.menu_items
                                                            ?.primary_image ||
                                                            "",
                                                        150,
                                                    )}
                                                    alt={pItem.menu_items?.name}
                                                    class="w-full h-full object-cover"
                                                />
                                            </div>
                                            <div class="flex-1">
                                                <h5
                                                    class="text-sm font-bold text-gray-900 leading-tight"
                                                >
                                                    {pItem.menu_items?.name}
                                                </h5>
                                                <p
                                                    class="text-[10px] text-gray-400 font-medium"
                                                >
                                                    Jumlah: {pItem.quantity ||
                                                        1}
                                                    {#if pItem.additional_price > 0}
                                                        • <span
                                                            class="text-primary font-black"
                                                            >+ Rp {pItem.additional_price.toLocaleString()}</span
                                                        >
                                                    {/if}
                                                </p>
                                            </div>
                                            <div
                                                class="w-6 h-6 rounded-full border-2 flex items-center justify-center transition-colors {selectedItemIds.includes(
                                                    pItem.child_menu_id,
                                                )
                                                    ? 'bg-primary border-primary text-white'
                                                    : 'border-gray-200'}"
                                            >
                                                {#if selectedItemIds.includes(pItem.child_menu_id)}
                                                    <Check
                                                        size={14}
                                                        strokeWidth={4}
                                                    />
                                                {/if}
                                            </div>
                                        </div>
                                    {/each}
                                </div>
                            {:else if !loadingPackage}
                                <div
                                    class="bg-orange-50 text-orange-600 p-4 rounded-2xl text-xs font-bold border border-orange-100 flex items-center gap-2"
                                >
                                    <Info size={14} /> Toko belum menambahkan daftar
                                    item ke paket ini.
                                </div>
                            {/if}
                        </div>
                    {/if}
                </div>
            </div>

            <!-- Action Footer -->
            <div
                class="absolute bottom-0 left-0 right-0 p-4 bg-white/80 backdrop-blur-xl border-t border-gray-100"
            >
                <button
                    on:click={handleAddToCart}
                    class="w-full h-14 bg-gray-900 text-white rounded-2xl font-black text-sm flex items-center justify-center gap-3 shadow-xl active:scale-[0.98] transition-all"
                >
                    <ShoppingBag size={20} />
                    Tambah ke Keranjang • Rp {finalPrice.toLocaleString()}
                </button>
            </div>
        </div>
    </div>
{/if}
