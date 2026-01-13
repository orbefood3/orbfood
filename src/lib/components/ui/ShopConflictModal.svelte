<script lang="ts">
    import { X, ShoppingBag, AlertTriangle, Trash2 } from "lucide-svelte";
    import { createEventDispatcher } from "svelte";

    export let show = false;
    export let newStoreName = "";

    const dispatch = createEventDispatcher();

    function handleCancel() {
        dispatch("cancel");
    }

    function handleConfirm() {
        dispatch("confirm");
    }
</script>

{#if show}
    <div class="fixed inset-0 z-[100] flex items-center justify-center p-4">
        <!-- Backdrop -->
        <!-- svelte-ignore a11y-click-events-have-key-events -->
        <!-- svelte-ignore a11y-no-static-element-interactions -->
        <div
            class="absolute inset-0 bg-gray-900/60 backdrop-blur-sm animate-in fade-in duration-300"
            on:click={handleCancel}
        ></div>

        <!-- Modal Content -->
        <div
            class="relative bg-white w-full max-w-sm rounded-[2.5rem] shadow-2xl overflow-hidden animate-in zoom-in-95 slide-in-from-bottom-10 duration-300"
        >
            <!-- Header with Icon -->
            <div class="pt-8 pb-4 flex flex-col items-center">
                <div class="relative mb-4">
                    <div
                        class="w-20 h-20 bg-orange-50 rounded-full flex items-center justify-center text-orange-500 animate-pulse"
                    >
                        <ShoppingBag size={36} strokeWidth={2.5} />
                    </div>
                    <div
                        class="absolute -right-1 -bottom-1 w-8 h-8 bg-white rounded-full flex items-center justify-center shadow-lg border-2 border-orange-50"
                    >
                        <AlertTriangle size={16} class="text-orange-600" />
                    </div>
                </div>
                <h3 class="text-xl font-black text-gray-900 px-6 text-center">
                    Ganti Keranjang Toko?
                </h3>
            </div>

            <!-- Body -->
            <div class="px-8 pb-8 text-center">
                <p class="text-gray-500 text-sm leading-relaxed mb-6">
                    Wah, sepertinya kamu mau pesan dari <span
                        class="font-black text-gray-900">"{newStoreName}"</span
                    >. Keranjang belanjaanmu sebelumnya akan
                    <span
                        class="text-orange-600 font-bold underline decoration-orange-200 decoration-2"
                        >dihapus</span
                    > ya. Lanjut?
                </p>

                <div class="flex flex-col gap-3">
                    <button
                        on:click={handleConfirm}
                        class="w-full flex items-center justify-center gap-2 py-4 bg-gray-900 text-white rounded-2xl font-black text-sm shadow-xl shadow-gray-200 active:scale-[0.98] transition-all"
                    >
                        <Trash2 size={18} />
                        Hapus & Ganti Toko
                    </button>

                    <button
                        on:click={handleCancel}
                        class="w-full py-4 bg-gray-50 text-gray-400 rounded-2xl font-bold text-sm hover:bg-gray-100 active:scale-[0.98] transition-all"
                    >
                        Batal
                    </button>
                </div>
            </div>

            <!-- Close Button -->
            <button
                on:click={handleCancel}
                class="absolute top-6 right-6 p-2 bg-gray-50 rounded-full text-gray-400 hover:text-gray-900 transition-colors"
            >
                <X size={20} />
            </button>
        </div>
    </div>
{/if}
