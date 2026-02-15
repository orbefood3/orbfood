<script lang="ts">
    import { onMount, onDestroy } from "svelte";
    import { Clock, User, Share2, ArrowRight } from "lucide-svelte";
    import type { OrderRoom } from "../../types/groupOrder";

    export let room: OrderRoom;
    export let onJoin: (room: OrderRoom) => void;

    let timeLeft: string = "";
    let isExpired = false;
    let interval: any;

    function updateTime() {
        const now = new Date().getTime();
        const end = new Date(room.closing_time).getTime();
        const diff = end - now;

        if (diff <= 0) {
            timeLeft = "Waktu Habis";
            isExpired = true;
            clearInterval(interval);
        } else {
            const minutes = Math.floor(diff / 60000);
            const seconds = Math.floor((diff % 60000) / 1000);
            timeLeft = `${minutes}m ${seconds}s`;
        }
    }

    onMount(() => {
        updateTime();
        interval = setInterval(updateTime, 1000);
    });

    onDestroy(() => {
        if (interval) clearInterval(interval);
    });

    function handleShare() {
        const url = `${window.location.origin}/#/group/${room.short_code}`;
        navigator.clipboard.writeText(url).then(() => {
            alert("Link berhasil disalin! Kirim ke teman kamu.");
        });
    }
</script>

<div
    class="bg-white border rounded-lg p-4 shadow-sm mb-3 relative overflow-hidden"
>
    {#if isExpired}
        <div
            class="absolute inset-0 bg-gray-100/80 z-10 flex items-center justify-center backdrop-blur-[1px]"
        >
            <span class="font-bold text-gray-500">Sesi Berakhir</span>
        </div>
    {/if}

    <div class="flex justify-between items-start mb-2">
        <div>
            <h3 class="font-bold text-gray-800">{room.name}</h3>
            <div class="flex items-center text-xs text-gray-500 mt-1">
                <span
                    class="bg-blue-100 text-blue-700 px-1.5 py-0.5 rounded font-mono mr-2"
                >
                    {room.short_code}
                </span>
                <User size={12} class="mr-1" />
                <span>{room.participant_count || 0} orang bergabung</span>
            </div>
        </div>

        <div class="text-right">
            <div class="flex items-center text-red-600 font-bold text-sm">
                <Clock size={14} class="mr-1" />
                {timeLeft}
            </div>
            <p class="text-[10px] text-gray-400">Batas Waktu</p>
        </div>
    </div>

    <div class="flex gap-2 mt-3">
        <button
            class="flex-1 bg-gray-100 text-gray-700 py-2 rounded-lg text-sm font-medium flex items-center justify-center gap-2 hover:bg-gray-200 transition-colors"
            on:click={handleShare}
        >
            <Share2 size={16} />
            Share Link
        </button>
        <button
            class="flex-1 bg-primary text-white py-2 rounded-lg text-sm font-bold flex items-center justify-center gap-2 hover:bg-primary/90 transition-colors shadow-sm"
            on:click={() => onJoin(room)}
            disabled={isExpired}
        >
            Gabung
            <ArrowRight size={16} />
        </button>
    </div>
</div>
