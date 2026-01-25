<script lang="ts">
    import { X, ShoppingBag, Check, Info, Loader2 } from "lucide-svelte";
    import { createEventDispatcher, onMount } from "svelte";
    import { getOptimizedImageUrl } from "../../services/cloudinary";
    import { supabase } from "../../services/supabase";

    export let show = false;
    export let item: any;
    export let onAdd: (item: any) => void;

    const dispatch = createEventDispatcher();
    let optionGroups: any[] = [];
    let selectedOptions: Record<string, string[]> = {}; // groupId -> array of itemIds
    let loadingOptions = false;

    // Reset state when modal closes
    $: if (!show) {
        optionGroups = [];
        selectedOptions = {};
    }

    // Fetch options when item changes or modal opens
    $: if (show && item?.type === "package" && optionGroups.length === 0) {
        fetchOptions();
    }

    async function fetchOptions() {
        if (!item?.id) return;
        loadingOptions = true;
        try {
            const { data, error } = await supabase
                .from("menu_option_groups")
                .select(
                    `
                    id, 
                    name, 
                    is_required, 
                    min_selection, 
                    max_selection,
                    menu_option_items (
                        id,
                        name,
                        additional_price,
                        is_available
                    )
                `,
                )
                .eq("menu_id", item.id)
                .order("created_at", { ascending: true });

            if (error) throw error;
            optionGroups = data || [];

            // Initialize selectedOptions
            const initial: Record<string, string[]> = {};
            optionGroups.forEach((g) => {
                initial[g.id] = [];
            });
            selectedOptions = initial;
        } catch (err) {
            console.error("Error fetching menu options:", err);
        } finally {
            loadingOptions = false;
        }
    }

    function toggleOption(
        groupId: string,
        optionId: string,
        maxSelection: number,
    ) {
        const current = selectedOptions[groupId] || [];

        if (current.includes(optionId)) {
            // Unselect
            selectedOptions[groupId] = current.filter((id) => id !== optionId);
        } else {
            // Select
            if (maxSelection === 1) {
                // Radio behavior
                selectedOptions[groupId] = [optionId];
            } else if (current.length < maxSelection) {
                // Checkbox behavior with cap
                selectedOptions[groupId] = [...current, optionId];
            }
        }
        selectedOptions = { ...selectedOptions };
    }

    function handleClose() {
        dispatch("close");
    }

    // Calculate total price based on selections
    $: extraPriceTotal = optionGroups.reduce((total, group) => {
        const selectedForGroup = selectedOptions[group.id] || [];
        const groupPrice = group.menu_option_items
            .filter((i: any) => selectedForGroup.includes(i.id))
            .reduce(
                (sum: number, i: any) => sum + (i.additional_price || 0),
                0,
            );
        return total + groupPrice;
    }, 0);

    $: finalPrice = (item.price || 0) + extraPriceTotal;

    // Validation: ensure all required groups meet MIN requirement
    $: isValid = optionGroups.every((group) => {
        if (!group.is_required) return true;
        const count = (selectedOptions[group.id] || []).length;
        return count >= (group.min_selection || 1);
    });

    function handleAddToCart() {
        if (!isValid) return;

        // Build a snapshot of customizations for the cart
        const customizations = optionGroups
            .map((group) => {
                const items = group.menu_option_items.filter((i: any) =>
                    (selectedOptions[group.id] || []).includes(i.id),
                );
                if (items.length === 0) return null;
                return {
                    group_name: group.name,
                    selected_items: items.map((i: any) => ({
                        name: i.name,
                        price: i.additional_price,
                    })),
                };
            })
            .filter(Boolean);

        const itemWithSelection = {
            ...item,
            final_price: finalPrice,
            customizations,
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

                    <!-- Customization Options -->
                    {#if item.type === "package"}
                        <div class="space-y-6">
                            {#if loadingOptions}
                                <div class="flex justify-center p-8">
                                    <Loader2
                                        class="animate-spin text-primary"
                                    />
                                </div>
                            {:else}
                                {#each optionGroups as group}
                                    <div class="space-y-3">
                                        <div
                                            class="flex items-center justify-between px-1"
                                        >
                                            <h3
                                                class="text-sm font-black text-gray-900 uppercase tracking-tighter flex items-center gap-2"
                                            >
                                                {group.name}
                                                {#if group.is_required}
                                                    <span
                                                        class="text-[9px] bg-red-500 text-white px-1.5 py-0.5 rounded leading-none"
                                                        >WAJIB</span
                                                    >
                                                {/if}
                                            </h3>
                                            <p
                                                class="text-[10px] font-bold text-gray-400"
                                            >
                                                {#if group.max_selection === 1}
                                                    PILIH 1
                                                {:else}
                                                    MING/MAX: {group.min_selection}/{group.max_selection}
                                                {/if}
                                            </p>
                                        </div>

                                        <div class="grid grid-cols-1 gap-2">
                                            {#each group.menu_option_items as choice}
                                                {@const isSelected = (
                                                    selectedOptions[group.id] ||
                                                    []
                                                ).includes(choice.id)}
                                                <!-- svelte-ignore a11y-click-events-have-key-events -->
                                                <!-- svelte-ignore a11y-no-static-element-interactions -->
                                                <div
                                                    class="flex items-center justify-between p-3 rounded-2xl border-2 transition-all cursor-pointer {isSelected
                                                        ? 'border-primary bg-primary/5'
                                                        : 'border-gray-50 bg-white hover:border-gray-200'}"
                                                    on:click={() =>
                                                        toggleOption(
                                                            group.id,
                                                            choice.id,
                                                            group.max_selection,
                                                        )}
                                                >
                                                    <div class="flex-1">
                                                        <p
                                                            class="text-sm font-bold {isSelected
                                                                ? 'text-primary'
                                                                : 'text-gray-700'}"
                                                        >
                                                            {choice.name}
                                                        </p>
                                                        {#if choice.additional_price > 0}
                                                            <p
                                                                class="text-[10px] font-black text-gray-400"
                                                            >
                                                                + Rp {choice.additional_price.toLocaleString()}
                                                            </p>
                                                        {/if}
                                                    </div>
                                                    <div
                                                        class="w-6 h-6 rounded-full border-2 flex items-center justify-center {isSelected
                                                            ? 'bg-primary border-primary text-white'
                                                            : 'border-gray-200'}"
                                                    >
                                                        {#if isSelected}<Check
                                                                size={14}
                                                                strokeWidth={4}
                                                            />{/if}
                                                    </div>
                                                </div>
                                            {/each}
                                        </div>
                                    </div>
                                {/each}
                                {#if optionGroups.length === 0}
                                    <div
                                        class="text-center py-8 bg-orange-50 rounded-2xl border border-dashed border-orange-200"
                                    >
                                        <p
                                            class="text-xs font-bold text-orange-600"
                                        >
                                            Menu kustomisasi ini belum memiliki
                                            pilihan.
                                        </p>
                                    </div>
                                {/if}
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
                    disabled={!isValid || loadingOptions}
                    class="w-full h-14 rounded-2xl font-black text-sm flex items-center justify-center gap-3 shadow-xl active:scale-[0.98] transition-all disabled:opacity-50 disabled:bg-gray-200 disabled:text-gray-400 {isValid
                        ? 'bg-gray-900 text-white'
                        : 'bg-gray-100 text-gray-400'}"
                >
                    <ShoppingBag size={20} />
                    {#if !isValid}
                        Mohon Lengkapi Pilihan
                    {:else}
                        Tambah ke Keranjang • Rp {finalPrice.toLocaleString()}
                    {/if}
                </button>
            </div>
        </div>
    </div>
{/if}

<style>
    .animate-in {
        animation: animateIn 0.3s ease-out;
    }
    @keyframes animateIn {
        from {
            opacity: 0;
        }
        to {
            opacity: 1;
        }
    }
</style>
