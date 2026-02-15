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
    export let rooms: OrderRoom[] = [];
    export let onJoin: (room: OrderRoom) => void;
    export let onCreateNew: () => void;

    const dispatch = createEventDispatcher();
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
                        Daftar Group Order
                    </h2>
                    <p class="text-xs text-gray-500 mt-0.5">
                        Pilih room untuk mulai pesan bersama teman
                    </p>
                </div>
                <button
                    on:click={() => dispatch("close")}
                    class="text-gray-400 hover:text-gray-600 p-2 rounded-full hover:bg-gray-200 transition-all"
                >
                    <X size={24} />
                </button>
            </div>

            <div class="flex-1 overflow-y-auto p-5 pb-10">
                {#if rooms.length > 0}
                    <div class="space-y-4">
                        {#each rooms as room}
                            <div
                                class="border-2 rounded-2xl p-4 hover:border-primary transition-colors bg-white shadow-sm group relative overflow-hidden {room.is_shop_managed
                                    ? 'border-primary/30 bg-primary/[0.02]'
                                    : 'border-gray-100'}"
                            >
                                {#if room.is_shop_managed}
                                    <div
                                        class="absolute top-0 right-0 bg-primary text-white text-[9px] font-black px-2 py-1 rounded-bl-xl flex items-center gap-1 shadow-sm"
                                    >
                                        <BadgeCheck size={10} />
                                        OFFICIAL TOKO
                                    </div>
                                {/if}
                                <div
                                    class="flex justify-between items-start mb-3"
                                >
                                    <div>
                                        <h3
                                            class="font-bold text-gray-900 line-clamp-1"
                                        >
                                            {room.name}
                                        </h3>
                                        <div
                                            class="flex items-center gap-2 mt-1"
                                        >
                                            <span
                                                class="text-[10px] font-black bg-blue-50 text-blue-600 px-1.5 py-0.5 rounded uppercase tracking-wider"
                                            >
                                                {room.short_code}
                                            </span>
                                            <span
                                                class="text-xs text-gray-400 flex items-center gap-1"
                                            >
                                                <Users size={12} />
                                                {room.participant_count || 0} orang
                                            </span>
                                        </div>
                                    </div>
                                    <div class="text-right">
                                        <span
                                            class="text-[10px] font-bold text-red-500 flex items-center gap-1 justify-end"
                                        >
                                            <Clock size={10} />
                                            Berakhir
                                        </span>
                                        <p
                                            class="text-xs font-black text-gray-800 mt-0.5"
                                        >
                                            {new Date(
                                                room.closing_time,
                                            ).toLocaleTimeString([], {
                                                hour: "2-digit",
                                                minute: "2-digit",
                                            })}
                                        </p>
                                    </div>
                                </div>

                                <button
                                    class="w-full py-2.5 bg-blue-50 text-primary font-bold rounded-xl flex items-center justify-center gap-2 hover:bg-primary hover:text-white transition-all group-hover:bg-primary group-hover:text-white"
                                    on:click={() => onJoin(room)}
                                >
                                    Gabung Sekarang
                                    <ArrowRight size={16} />
                                </button>
                            </div>
                        {/each}
                    </div>
                {:else}
                    <div class="py-12 text-center">
                        <div
                            class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4"
                        >
                            <Users size={32} class="text-gray-300" />
                        </div>
                        <h3 class="font-bold text-gray-800">
                            Belum ada room aktif
                        </h3>
                        <p
                            class="text-xs text-gray-400 mt-1 max-w-[200px] mx-auto"
                        >
                            Jadilah yang pertama untuk mulai pesanan bersama di
                            toko ini!
                        </p>
                    </div>
                {/if}
            </div>

            <div class="p-5 border-t bg-white flex-shrink-0 pb-8 sm:pb-5">
                <button
                    class="w-full py-4 bg-primary text-white font-black rounded-2xl shadow-lg shadow-primary/20 flex items-center justify-center gap-2 hover:scale-[1.02] active:scale-95 transition-all"
                    on:click={onCreateNew}
                >
                    <Plus size={20} />
                    Buat Room Baru
                </button>
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
