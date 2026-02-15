<script lang="ts">
    import { onMount } from "svelte";
    import { Download, X } from "lucide-svelte";
    import { slide, fade } from "svelte/transition";

    let deferredPrompt: any = null;
    let showPrompt = false;

    onMount(() => {
        // Check if user has already dismissed or installed
        const hasBeenPrompted = localStorage.getItem(
            "orbfood_install_prompt_dismissed",
        );
        if (hasBeenPrompted) return;

        window.addEventListener("beforeinstallprompt", (e) => {
            // Prevent Chrome 67 and earlier from automatically showing the prompt
            e.preventDefault();
            // Stash the event so it can be triggered later.
            deferredPrompt = e;
            // Show the prompt after a short delay to be non-intrusive
            setTimeout(() => {
                showPrompt = true;
            }, 3000);
        });

        window.addEventListener("appinstalled", (evt) => {
            console.log("OrbFood was installed");
            showPrompt = false;
            localStorage.setItem("orbfood_install_prompt_dismissed", "true");
        });
    });

    async function handleInstall() {
        if (!deferredPrompt) return;

        // Show the prompt
        deferredPrompt.prompt();

        // Wait for the user to respond to the prompt
        const { outcome } = await deferredPrompt.userChoice;
        console.log(`User response to the install prompt: ${outcome}`);

        // We've used the prompt, and can't use it again, throw it away
        deferredPrompt = null;
        showPrompt = false;

        if (outcome === "accepted") {
            localStorage.setItem("orbfood_install_prompt_dismissed", "true");
        }
    }

    function dismissPrompt() {
        showPrompt = false;
        // Don't show again for this session/user
        localStorage.setItem("orbfood_install_prompt_dismissed", "true");
    }
</script>

{#if showPrompt}
    <div
        class="fixed bottom-24 left-4 right-4 z-[100] sm:max-w-xs sm:left-auto sm:right-6"
        in:slide={{ axis: "y" }}
        out:fade
    >
        <div
            class="bg-white border-2 border-primary/20 rounded-2xl shadow-2xl p-4 flex items-center gap-4 relative overflow-hidden group"
        >
            <!-- Decorative background -->
            <div
                class="absolute -right-4 -bottom-4 w-20 h-20 bg-primary/5 rounded-full blur-2xl group-hover:bg-primary/10 transition-all duration-700"
            ></div>

            <div
                class="w-12 h-12 bg-primary/10 rounded-xl flex-shrink-0 flex items-center justify-center"
            >
                <img
                    src="/logo-orb.png"
                    alt="Logo"
                    class="w-8 h-8 object-contain"
                />
            </div>

            <div class="flex-1 min-w-0">
                <h3 class="text-xs font-black text-gray-900 leading-tight">
                    Install OrbFood?
                </h3>
                <p class="text-[10px] text-gray-500 mt-0.5 line-clamp-1">
                    Akses lebih cepat & hemat kuota
                </p>
            </div>

            <div class="flex items-center gap-2">
                <button
                    on:click={handleInstall}
                    class="bg-primary text-white text-[10px] font-black px-3 py-2 rounded-lg hover:scale-105 active:scale-95 transition-all shadow-lg shadow-primary/20"
                >
                    INSTALL
                </button>
                <button
                    on:click={dismissPrompt}
                    class="p-1 text-gray-400 hover:text-gray-600 rounded-full hover:bg-gray-100 transition-all"
                >
                    <X size={16} />
                </button>
            </div>
        </div>
    </div>
{/if}
