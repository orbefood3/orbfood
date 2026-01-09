<script lang="ts">
    import { slide, fade } from "svelte/transition";
    import {
        Store,
        BarChart3,
        Clock,
        FileText,
        Settings,
        LogOut,
        ChevronDown,
    } from "lucide-svelte";
    import { createEventDispatcher } from "svelte";

    export let user: any;
    export let activeView: string;
    export let sidebarOpen: boolean;
    export let menuItems: any[];

    const dispatch = createEventDispatcher();
    let showUserMenu = false;

    function handleLogout() {
        dispatch("logout");
    }

    function handleViewChange(id: string) {
        if (id === "pending") {
            dispatch("refreshPending");
        }
        dispatch("changeView", id);
        dispatch("closeSidebar");
    }
</script>

<aside
    class="fixed lg:static inset-y-0 left-0 z-50 w-64 bg-white border-r border-gray-200 transform transition-transform duration-300 lg:translate-x-0 {sidebarOpen
        ? 'translate-x-0'
        : '-translate-x-full'}"
    transition:slide={{ axis: "x", duration: 300 }}
>
    <!-- Logo -->
    <div class="h-16 flex items-center px-6 border-b border-gray-200">
        <div class="flex items-center gap-3">
            <div
                class="w-8 h-8 bg-gradient-to-br from-blue-600 to-blue-700 rounded-lg flex items-center justify-center"
            >
                <Store class="text-white" size={18} />
            </div>
            <span class="text-xl font-bold text-gray-900">Orbefood</span>
        </div>
    </div>

    <!-- Navigation -->
    <nav
        class="flex-1 px-3 py-4 space-y-1 overflow-y-auto"
        style="height: calc(100vh - 4rem - 120px);"
    >
        {#each menuItems as item}
            {@const Icon = item.icon}
            {@const isActive = activeView === item.id}
            <button
                on:click={() => handleViewChange(item.id)}
                class="w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-all {isActive
                    ? 'bg-blue-50 text-blue-700'
                    : 'text-gray-700 hover:bg-gray-50'}"
            >
                <svelte:component this={Icon} size={20} />
                <span class="flex-1 text-left">{item.label}</span>
                {#if item.badge !== null && item.badge > 0}
                    <span
                        class="px-2 py-0.5 bg-red-500 text-white text-xs font-bold rounded-full"
                    >
                        {item.badge}
                    </span>
                {/if}
            </button>
        {/each}
    </nav>

    <!-- User Section -->
    <div class="p-4 border-t border-gray-200">
        <div class="relative user-menu-container">
            <button
                on:click|stopPropagation={() => (showUserMenu = !showUserMenu)}
                class="w-full flex items-center gap-3 p-2 rounded-lg hover:bg-gray-50 transition-colors"
            >
                <div
                    class="w-10 h-10 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center text-white font-bold"
                >
                    {user?.email?.[0]?.toUpperCase() || "A"}
                </div>
                <div class="flex-1 min-w-0 text-left">
                    <div class="font-semibold text-sm text-gray-900 truncate">
                        {user?.user_metadata?.name || "Admin User"}
                    </div>
                    <div class="text-xs text-gray-500 truncate">
                        {user?.email || "admin@orbefood.com"}
                    </div>
                </div>
                <ChevronDown
                    size={16}
                    class="text-gray-400 {showUserMenu
                        ? 'transform rotate-180'
                        : ''} transition-transform"
                />
            </button>

            {#if showUserMenu}
                <div
                    class="absolute bottom-full left-0 right-0 mb-2 bg-white rounded-lg shadow-lg border border-gray-200 py-2"
                    transition:fade={{ duration: 150 }}
                >
                    <button
                        on:click={handleLogout}
                        class="w-full flex items-center gap-2 px-4 py-2 text-red-600 hover:bg-red-50 text-sm font-medium transition-colors"
                    >
                        <LogOut size={18} />
                        <span>Logout</span>
                    </button>
                </div>
            {/if}
        </div>
    </div>
</aside>
