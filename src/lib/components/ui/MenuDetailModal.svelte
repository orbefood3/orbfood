<script lang="ts">
    import {
        X,
        ShoppingBag,
        Check,
        Info,
        Loader2,
        Plus,
        Minus,
    } from "lucide-svelte";
    import { createEventDispatcher, onMount } from "svelte";
    import { getOptimizedImageUrl } from "../../services/cloudinary";
    import { supabase } from "../../services/supabase";
    import { updateItemByIndex } from "../../stores/cartStore";

    export let show = false;
    export let item: any;
    export let onAdd: (item: any) => void;
    export let editIndex: number | null = null; // Passed when editing an existing cart item

    const dispatch = createEventDispatcher();
    let optionGroups: any[] = [];
    let selectedQuantities: Record<string, Record<string, number>> = {}; // groupId -> { itemId -> qty }
    let loadingOptions = false;
    let showSuccessHint = false;
    let quantity = 1;

    // Reset state when modal closes
    $: if (!show) {
        optionGroups = [];
        selectedQuantities = {};
        quantity = 1;
        showSuccessHint = false;
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

            // Initialize state
            const initial: Record<string, Record<string, number>> = {};
            optionGroups.forEach((g) => {
                initial[g.id] = {};
            });

            // If editing, populate from existing customizations
            if (editIndex !== null && item.customizations) {
                item.customizations.forEach((c: any) => {
                    const group = optionGroups.find(
                        (g) => g.name === c.group_name,
                    );
                    if (group) {
                        c.selected_items.forEach((si: any) => {
                            const opt = group.menu_option_items.find(
                                (oi: any) => oi.name === si.name,
                            );
                            if (opt) {
                                initial[group.id][opt.id] = si.qty || 1;
                            }
                        });
                    }
                });
                quantity = item.quantity || 1;
            }

            selectedQuantities = initial;
        } catch (err) {
            console.error("Error fetching menu options:", err);
        } finally {
            loadingOptions = false;
        }
    }

    function updateOptionQty(
        groupId: string,
        optionId: string,
        delta: number,
        maxSelection: number,
    ) {
        const group = selectedQuantities[groupId] || {};
        const currentQty = group[optionId] || 0;
        const groupTotal = Object.values(group).reduce((a, b) => a + b, 0);

        if (delta > 0 && groupTotal >= maxSelection) {
            // Radio behavior for max_selection = 1: swap selection
            if (maxSelection === 1) {
                selectedQuantities[groupId] = { [optionId]: 1 };
            }
            return;
        }

        const newQty = Math.max(0, currentQty + delta);
        if (newQty === 0) {
            delete group[optionId];
        } else {
            group[optionId] = newQty;
        }

        selectedQuantities[groupId] = { ...group };
        selectedQuantities = { ...selectedQuantities };
    }

    function handleClose() {
        dispatch("close");
    }

    // Calculate total price based on selections
    $: extraPriceTotal = optionGroups.reduce((total, group) => {
        const selections = selectedQuantities[group.id] || {};
        const groupPrice = group.menu_option_items.reduce(
            (sum: number, i: any) => {
                const qty = selections[i.id] || 0;
                return sum + (i.additional_price || 0) * qty;
            },
            0,
        );
        return total + groupPrice;
    }, 0);

    $: finalPrice = (item.price || 0) + extraPriceTotal;

    // Validation: ensure all required groups meet MIN requirement
    $: isValid = optionGroups.every((group) => {
        if (!group.is_required) return true;
        const totalSelected = Object.values(
            selectedQuantities[group.id] || {},
        ).reduce((a, b) => a + b, 0);
        return totalSelected >= (group.min_selection || 1);
    });

    function getCartPayload() {
        const customizations = optionGroups
            .map((group) => {
                const selections = selectedQuantities[group.id] || {};
                const items = group.menu_option_items
                    .filter((i: any) => selections[i.id] > 0)
                    .map((i: any) => ({
                        id: i.id,
                        name: i.name,
                        price: i.additional_price,
                        qty: selections[i.id],
                    }));

                if (items.length === 0) return null;
                return {
                    group_id: group.id,
                    group_name: group.name,
                    selected_items: items,
                };
            })
            .filter(Boolean);

        return {
            ...item,
            final_price: finalPrice,
            customizations,
            quantity,
        };
    }

    function handleAddToCart(closeModal = true) {
        if (!isValid) return;

        const payload = getCartPayload();

        if (editIndex !== null) {
            updateItemByIndex(editIndex, payload);
            handleClose();
        } else {
            onAdd(payload);
            if (closeModal) {
                handleClose();
            } else {
                // Flash success hint
                showSuccessHint = true;
                setTimeout(() => (showSuccessHint = false), 2000);
            }
        }
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

            <div class="overflow-y-auto pb-32">
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
                        <div class="space-y-8">
                            {#if loadingOptions}
                                <div class="flex justify-center p-8">
                                    <Loader2
                                        class="animate-spin text-primary"
                                    />
                                </div>
                            {:else}
                                {#each optionGroups as group}
                                    {@const totalInGroup = Object.values(
                                        selectedQuantities[group.id] || {},
                                    ).reduce((a, b) => a + b, 0)}
                                    <div class="space-y-4">
                                        <div
                                            class="flex items-center justify-between px-1"
                                        >
                                            <div class="flex flex-col">
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
                                                    class="text-[10px] font-bold text-gray-400 mt-0.5"
                                                >
                                                    {#if group.max_selection === 1}
                                                        Pilih salah satu
                                                    {:else}
                                                        Pilih {group.min_selection}-{group.max_selection}
                                                        pilihan
                                                    {/if}
                                                </p>
                                            </div>
                                            <div
                                                class="px-3 py-1 bg-gray-100 rounded-full text-[10px] font-black {totalInGroup <
                                                group.min_selection
                                                    ? 'text-red-500'
                                                    : 'text-primary'}"
                                            >
                                                {totalInGroup}/{group.max_selection}
                                            </div>
                                        </div>

                                        <div class="grid grid-cols-1 gap-3">
                                            {#each group.menu_option_items as choice}
                                                {@const qty =
                                                    (selectedQuantities[
                                                        group.id
                                                    ] || {})[choice.id] || 0}
                                                <div
                                                    class="flex items-center justify-between p-4 rounded-3xl border-2 transition-all {qty >
                                                    0
                                                        ? 'border-primary bg-primary/5'
                                                        : 'border-gray-50 bg-white'}"
                                                >
                                                    <div
                                                        class="flex-1 min-w-0 pr-4"
                                                    >
                                                        <p
                                                            class="text-sm font-bold {qty >
                                                            0
                                                                ? 'text-primary'
                                                                : 'text-gray-700'} truncate"
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
                                                        class="flex items-center gap-3"
                                                    >
                                                        {#if qty > 0}
                                                            <button
                                                                on:click={() =>
                                                                    updateOptionQty(
                                                                        group.id,
                                                                        choice.id,
                                                                        -1,
                                                                        group.max_selection,
                                                                    )}
                                                                class="w-8 h-8 rounded-full bg-white border border-primary text-primary flex items-center justify-center hover:bg-primary hover:text-white transition-colors"
                                                            >
                                                                <Minus
                                                                    size={16}
                                                                />
                                                            </button>
                                                            <span
                                                                class="text-sm font-black text-gray-900 w-4 text-center"
                                                                >{qty}</span
                                                            >
                                                        {/if}
                                                        <button
                                                            on:click={() =>
                                                                updateOptionQty(
                                                                    group.id,
                                                                    choice.id,
                                                                    1,
                                                                    group.max_selection,
                                                                )}
                                                            class="w-8 h-8 rounded-full flex items-center justify-center transition-colors {qty >
                                                            0
                                                                ? 'bg-primary text-white border-primary shadow-lg shadow-primary/20'
                                                                : 'bg-gray-100 text-gray-400 border-gray-100'}"
                                                            disabled={qty ===
                                                                0 &&
                                                                Object.values(
                                                                    selectedQuantities[
                                                                        group.id
                                                                    ] || {},
                                                                ).reduce(
                                                                    (a, b) =>
                                                                        a + b,
                                                                    0,
                                                                ) >=
                                                                    group.max_selection &&
                                                                group.max_selection >
                                                                    1}
                                                        >
                                                            <Plus size={16} />
                                                        </button>
                                                    </div>
                                                </div>
                                            {/each}
                                        </div>
                                    </div>
                                {/each}
                            {/if}
                        </div>
                    {/if}

                    <!-- Overall Quantity (Only if not editing) -->
                    {#if editIndex === null}
                        <div
                            class="mt-8 pt-8 border-t border-gray-100 flex items-center justify-between"
                        >
                            <div>
                                <h4 class="text-sm font-black text-gray-900">
                                    Jumlah Pesanan
                                </h4>
                                <p class="text-[10px] text-gray-400 font-bold">
                                    Atur jumlah untuk variasi ini
                                </p>
                            </div>
                            <div class="flex items-center gap-6">
                                <button
                                    on:click={() =>
                                        (quantity = Math.max(1, quantity - 1))}
                                    class="w-10 h-10 rounded-2xl bg-gray-50 text-gray-900 flex items-center justify-center hover:bg-gray-100 transition-colors"
                                >
                                    <Minus size={20} />
                                </button>
                                <span class="text-xl font-black text-gray-900"
                                    >{quantity}</span
                                >
                                <button
                                    on:click={() => quantity++}
                                    class="w-10 h-10 rounded-2xl bg-gray-900 text-white flex items-center justify-center hover:bg-gray-800 transition-colors shadow-lg shadow-gray-200"
                                >
                                    <Plus size={20} />
                                </button>
                            </div>
                        </div>
                    {/if}
                </div>
            </div>

            <!-- Action Footer -->
            <div
                class="absolute bottom-0 left-0 right-0 p-4 bg-white/80 backdrop-blur-xl border-t border-gray-100 flex flex-col gap-2"
            >
                {#if showSuccessHint}
                    <div
                        class="flex items-center justify-center gap-2 text-green-600 animate-bounce py-1"
                    >
                        <Check size={16} strokeWidth={4} />
                        <span class="text-xs font-black uppercase"
                            >Berhasil ditambahkan!</span
                        >
                    </div>
                {/if}

                <div class="flex gap-2">
                    {#if editIndex === null}
                        <button
                            on:click={() => handleAddToCart(false)}
                            disabled={!isValid || loadingOptions}
                            class="flex-1 h-14 rounded-2xl font-black text-xs flex items-center justify-center gap-2 border-2 transition-all {isValid
                                ? 'border-primary text-primary hover:bg-primary/5 active:scale-[0.98]'
                                : 'border-gray-100 text-gray-300'}"
                        >
                            Simpan & Pilih Lagi
                        </button>
                    {/if}

                    <button
                        on:click={() => handleAddToCart(true)}
                        disabled={!isValid || loadingOptions}
                        class="flex-[1.5] h-14 rounded-2xl font-black text-sm flex items-center justify-center gap-3 shadow-xl active:scale-[0.98] transition-all disabled:opacity-50 disabled:bg-gray-200 disabled:text-gray-400 {isValid
                            ? 'bg-gray-900 text-white'
                            : 'bg-gray-100 text-gray-400'}"
                    >
                        <ShoppingBag size={20} />
                        {#if !isValid}
                            Lengkapi Pilihan
                        {:else}
                            {editIndex !== null
                                ? "Simpan Perubahan"
                                : "Tambah & Lihat Keranjang"}
                        {/if}
                    </button>
                </div>
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
