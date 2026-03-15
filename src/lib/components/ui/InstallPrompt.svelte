<script lang="ts">
    import { onMount } from "svelte";
    import { Download, X } from "lucide-svelte";
    import { fly, fade } from "svelte/transition";

    let deferredPrompt: any = null;
    let showPrompt = false;
    let installing = false;

    onMount(() => {
        if (localStorage.getItem("orbfood_install_prompt_dismissed")) return;

        window.addEventListener("beforeinstallprompt", (e) => {
            e.preventDefault();
            deferredPrompt = e;
            setTimeout(() => (showPrompt = true), 3000);
        });

        window.addEventListener("appinstalled", () => {
            showPrompt = false;
            localStorage.setItem("orbfood_install_prompt_dismissed", "true");
        });
    });

    async function handleInstall() {
        if (!deferredPrompt) return;
        installing = true;
        deferredPrompt.prompt();
        const { outcome } = await deferredPrompt.userChoice;
        deferredPrompt = null;
        installing = false;
        showPrompt = false;
        if (outcome === "accepted") {
            localStorage.setItem("orbfood_install_prompt_dismissed", "true");
        }
    }

    function dismiss() {
        showPrompt = false;
        localStorage.setItem("orbfood_install_prompt_dismissed", "true");
    }
</script>

{#if showPrompt}
    <div
        class="fixed bottom-24 right-4 z-[100] w-72"
        in:fly={{ y: 24, duration: 300 }}
        out:fade={{ duration: 150 }}
    >
        <div class="relative bg-white rounded-2xl shadow-2xl shadow-black/15 border border-gray-100 overflow-hidden">
            <!-- Subtle gradient bar at top -->
            <div class="h-1 w-full bg-gradient-to-r from-primary to-orange-400"></div>

            <!-- Close button -->
            <button
                on:click={dismiss}
                class="absolute top-3 right-3 w-7 h-7 flex items-center justify-center rounded-full bg-gray-100 hover:bg-gray-200 text-gray-500 transition-all active:scale-90"
                aria-label="Tutup"
            >
                <X size={14} />
            </button>

            <div class="p-4 pt-3">
                <!-- App icon + title row -->
                <div class="flex items-center gap-3 mb-3 pr-8">
                    <div class="w-11 h-11 bg-primary/10 rounded-xl flex items-center justify-center flex-shrink-0">
                        <img src="/logo-orb.png" alt="OrbFood" class="w-8 h-8 object-contain" />
                    </div>
                    <div>
                        <p class="text-sm font-black text-gray-900 leading-tight">Pasang OrbFood</p>
                        <p class="text-[11px] text-gray-500">Lebih cepat & hemat kuota</p>
                    </div>
                </div>

                <!-- Action buttons -->
                <div class="flex gap-2">
                    <button
                        on:click={dismiss}
                        class="flex-1 py-2 text-xs font-bold text-gray-500 border border-gray-200 rounded-xl hover:bg-gray-50 transition-all"
                    >
                        Nanti
                    </button>
                    <button
                        on:click={handleInstall}
                        disabled={installing}
                        class="flex-[2] py-2 text-xs font-black text-white bg-primary rounded-xl hover:scale-[1.02] active:scale-95 transition-all shadow-md shadow-primary/25 flex items-center justify-center gap-1.5 disabled:opacity-70"
                    >
                        {#if installing}
                            <div class="w-3.5 h-3.5 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                            Memasang...
                        {:else}
                            <Download size={13} />
                            Install
                        {/if}
                    </button>
                </div>
            </div>
        </div>
    </div>
{/if}
