<script lang="ts">
    import { toasts } from "../../stores/toastStore";
    import { flip } from "svelte/animate";
    import { fade, fly } from "svelte/transition";
    import {
        CheckCircle2,
        AlertCircle,
        Info,
        AlertTriangle,
        X,
    } from "lucide-svelte";

    const icons = {
        success: CheckCircle2,
        error: AlertCircle,
        warning: AlertTriangle,
        info: Info,
    };

    const colors = {
        success: "bg-green-50 text-green-800 border-green-200",
        error: "bg-red-50 text-red-800 border-red-200",
        warning: "bg-amber-50 text-amber-800 border-amber-200",
        info: "bg-blue-50 text-blue-800 border-blue-200",
    };

    const iconColors = {
        success: "text-green-500",
        error: "text-red-500",
        warning: "text-amber-500",
        info: "text-blue-500",
    };
</script>

<div
    class="fixed top-4 left-1/2 -translate-x-1/2 z-[9999] flex flex-col gap-2 w-full max-w-[90%] sm:max-w-md pointer-events-none p-4"
>
    {#each $toasts as toast (toast.id)}
        <div
            animate:flip={{ duration: 300 }}
            in:fly={{ y: -20, duration: 300 }}
            out:fade={{ duration: 200 }}
            class="pointer-events-auto flex items-center gap-3 p-4 rounded-2xl border shadow-lg backdrop-blur-md {colors[
                toast.type
            ]}"
        >
            <svelte:component
                this={icons[toast.type]}
                size={20}
                class={iconColors[toast.type]}
            />
            <p class="text-sm font-bold flex-1">{toast.message}</p>
            <button
                on:click={() => toasts.remove(toast.id)}
                class="p-1 hover:bg-black/5 rounded-full transition-colors"
            >
                <X size={16} class="opacity-50" />
            </button>
        </div>
    {/each}
</div>
