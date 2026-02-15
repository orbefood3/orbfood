<script lang="ts">
    import { onMount, onDestroy } from "svelte";
    import { Clock, ShoppingBag } from "lucide-svelte";
    import type { OrderRoom } from "../../types/groupOrder";
    import { cartCount } from "../../stores/cartStore";

    export let room: OrderRoom;
    export let myTotal: number = 0;
    export let onOpenCart: () => void;

    let timeLeft: string = "";
    let isExpired = false;
    let interval: any;

    // Shift up if cart bar is visible
    $: bottomOffset = $cartCount > 0 ? "bottom-[85px]" : "bottom-0";

    function updateTime() {
        const now = new Date().getTime();
        const end = new Date(room.closing_time).getTime();
        const diff = end - now;

        if (diff <= 0) {
            timeLeft = "00:00";
            isExpired = true;
            clearInterval(interval);
        } else {
            const minutes = Math.floor(diff / 60000);
            const seconds = Math.floor((diff % 60000) / 1000);
            timeLeft = `${minutes}:${seconds < 10 ? "0" : ""}${seconds}`;
        }
    }

    onMount(() => {
        updateTime();
        interval = setInterval(updateTime, 1000);
    });

    onDestroy(() => {
        if (interval) clearInterval(interval);
    });
</script>

<div
    class="fixed bottom-0 left-0 right-0 bg-white border-t p-3 shadow-[0_-4px_6px_-1px_rgba(0,0,0,0.1)] z-50 animate-in slide-in-from-bottom duration-300"
>
    <div class="flex items-center justify-between max-w-md mx-auto">
        <div class="flex flex-col">
            <span class="text-xs text-gray-500 font-medium"
                >Group Order: {room.name}</span
            >
            <div class="flex items-center gap-2 mt-0.5">
                <span
                    class="bg-red-100 text-red-600 px-1.5 py-0.5 rounded text-xs font-bold flex items-center gap-1"
                >
                    <Clock size={10} />
                    {timeLeft}
                </span>
                {#if myTotal > 0}
                    <span class="text-sm font-bold text-gray-800">
                        Rp {myTotal.toLocaleString("id-ID")}
                    </span>
                {/if}
            </div>
        </div>

        <button
            class="bg-gray-900 text-white px-4 py-2 rounded-lg font-bold text-sm hover:bg-black transition-colors flex items-center gap-2 shadow-lg"
            on:click={onOpenCart}
        >
            <ShoppingBag size={16} />
            Lihat Pesanan
        </button>
    </div>
</div>
