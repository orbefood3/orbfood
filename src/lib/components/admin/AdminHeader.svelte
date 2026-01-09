<script lang="ts">
    import { Menu, Bell } from "lucide-svelte";
    import { fade } from "svelte/transition";
    import { createEventDispatcher } from "svelte";

    export let activeView: string;
    export let menuItems: any[];

    const dispatch = createEventDispatcher();
    let showNotifications = false;
</script>

<header
    class="h-16 bg-white border-b border-gray-200 flex items-center px-4 lg:px-6 flex-shrink-0"
>
    <button
        on:click={() => dispatch("toggleSidebar")}
        class="lg:hidden mr-4 p-2 hover:bg-gray-100 rounded-lg transition-colors"
    >
        <Menu size={24} />
    </button>

    <h1 class="text-xl font-bold text-gray-900">
        {menuItems.find((item) => item.id === activeView)?.label || "Dashboard"}
    </h1>

    <div class="ml-auto flex items-center gap-3">
        <!-- Notifications -->
        <div class="relative notification-container">
            <button
                on:click|stopPropagation={() =>
                    (showNotifications = !showNotifications)}
                class="p-2 hover:bg-gray-100 rounded-lg relative transition-colors"
            >
                <Bell size={20} class="text-gray-600" />
                <span
                    class="absolute top-1.5 right-1.5 w-2 h-2 bg-red-500 rounded-full"
                ></span>
            </button>

            {#if showNotifications}
                <div
                    class="absolute right-0 top-full mt-2 w-80 bg-white rounded-lg shadow-lg border border-gray-200 py-2 z-50"
                    transition:fade={{ duration: 150 }}
                >
                    <div class="px-4 py-2 border-b border-gray-100">
                        <h3 class="font-semibold text-sm">Notifikasi</h3>
                    </div>
                    <div class="max-h-96 overflow-y-auto">
                        <div class="px-4 py-3 hover:bg-gray-50 cursor-pointer">
                            <p class="text-sm font-medium text-gray-900">
                                Toko baru terdaftar
                            </p>
                            <p class="text-xs text-gray-500 mt-1">
                                Warung Bu Siti menunggu verifikasi
                            </p>
                            <p class="text-xs text-gray-400 mt-1">2 jam lalu</p>
                        </div>
                        <div class="px-4 py-3 hover:bg-gray-50 cursor-pointer">
                            <p class="text-sm font-medium text-gray-900">
                                Menu diupdate
                            </p>
                            <p class="text-xs text-gray-500 mt-1">
                                Kedai Kopi Lokal menambah 5 menu baru
                            </p>
                            <p class="text-xs text-gray-400 mt-1">5 jam lalu</p>
                        </div>
                    </div>
                </div>
            {/if}
        </div>
    </div>
</header>
