<script lang="ts">
    import { createEventDispatcher } from "svelte";
    import {
        X,
        Users,
        Clock,
        ArrowRight,
        Plus,
        BadgeCheck,
    } from "lucide-svelte";
    import GroupOrderCard from "../cards/GroupOrderCard.svelte";
    import type { OrderRoom } from "../../types/groupOrder";

    export let show = false;
    let groupCode = "";
    let isVerifying = false;

    const dispatch = createEventDispatcher();

    function handleJoin() {
        if (!groupCode.trim()) return;
        dispatch("join_code", { code: groupCode.trim() });
    }
</script>

{#if show}
    <div
        class="fixed inset-0 z-[60] flex items-end sm:items-center justify-center bg-black/50 backdrop-blur-sm p-0 sm:p-4"
    >
        <div
            class="bg-white w-full max-w-lg rounded-t-3xl sm:rounded-2xl shadow-2xl h-[80vh] sm:h-auto flex flex-col animate-in slide-in-from-bottom duration-300"
        >
            <div
                class="p-5 border-b flex justify-between items-center bg-gray-50 flex-shrink-0 rounded-t-3xl sm:rounded-t-2xl"
            >
                <div>
                    <h2
                        class="text-xl font-black text-gray-800 flex items-center gap-2"
                    >
                        <Users size={24} class="text-primary" />
                        Gabung Grup
                    </h2>
                    <p class="text-xs text-gray-500 mt-0.5">
                        Masukkan kode unik untuk jajan bareng teman
                    </p>
                </div>
                <button
                    on:click={() => dispatch("close")}
                    class="text-gray-400 hover:text-gray-600 p-2 rounded-full hover:bg-gray-200 transition-all"
                >
                    <X size={24} />
                </button>
            </div>

            <div class="flex-1 overflow-y-auto p-6 space-y-8">
                <div class="space-y-4">
                    <div
                        class="bg-primary/5 p-5 rounded-2xl border-2 border-primary/10"
                    >
                        <label
                            for="unique-code"
                            class="block text-[10px] font-black text-primary uppercase tracking-widest mb-3"
                            >Masukkan Kode Grup</label
                        >
                        <input
                            id="unique-code"
                            type="text"
                            bind:value={groupCode}
                            placeholder="CONTOH: ABCD"
                            class="w-full px-4 py-4 bg-white border-2 border-primary/20 rounded-xl text-3xl font-black text-gray-900 placeholder:text-gray-100 focus:border-primary focus:ring-8 focus:ring-primary/5 outline-none uppercase transition-all tracking-[0.2em] text-center"
                            on:keydown={(e) =>
                                e.key === "Enter" && handleJoin()}
                        />
                        <p
                            class="text-[10px] text-gray-400 font-bold mt-3 italic text-center leading-relaxed"
                        >
                            *Minta kode unik ke pembuat grup untuk bergabung
                        </p>
                    </div>

                    <button
                        on:click={handleJoin}
                        disabled={!groupCode.trim() || isVerifying}
                        class="w-full bg-primary text-white py-4 rounded-xl font-black text-sm uppercase tracking-widest shadow-xl shadow-primary/20 active:scale-[0.98] transition-all disabled:opacity-50 flex items-center justify-center gap-3"
                    >
                        {#if isVerifying}
                            <div
                                class="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"
                            ></div>
                            MENGECEK...
                        {:else}
                            <ArrowRight size={20} />
                            GABUNG GRUP SEKARANG
                        {/if}
                    </button>
                </div>

                <div class="relative py-2">
                    <div class="absolute inset-0 flex items-center">
                        <div class="w-full border-t border-gray-100"></div>
                    </div>
                    <div
                        class="relative flex justify-center text-[10px] font-black uppercase tracking-widest"
                    >
                        <span class="bg-white px-4 text-gray-300">ATAU</span>
                    </div>
                </div>

                <div
                    class="bg-gray-50 p-4 rounded-2xl border border-dashed border-gray-200"
                >
                    <p
                        class="text-[10px] font-black text-gray-400 uppercase tracking-widest text-center mb-3"
                    >
                        Mau mulai pesanan baru?
                    </p>
                    <button
                        on:click={() => dispatch("createNew")}
                        class="w-full bg-white border-2 border-gray-100 text-gray-700 py-4 rounded-xl font-black text-xs uppercase tracking-widest hover:border-primary/20 hover:text-primary transition-all flex items-center justify-center gap-2 shadow-sm"
                    >
                        <Plus size={18} />
                        BUAT GRUP BARU
                    </button>
                </div>
            </div>
        </div>
    </div>
{/if}

<style>
    /* Custom animation for mobile bottom sheet */
    @media (max-width: 639px) {
        .animate-in {
            animation: slide-up 0.3s ease-out;
        }
    }

    @keyframes slide-up {
        from {
            transform: translateY(100%);
        }
        to {
            transform: translateY(0);
        }
    }
</style>
