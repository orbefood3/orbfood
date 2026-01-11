<script lang="ts">
    import { createEventDispatcher } from "svelte";

    export let profile: any = null; // Optional profile data
    export let title: string = "Dashboard";
    export let activeTab: string;
    export let menuItems: Array<{
        id: string;
        label: string;
        icon: any; // Lucide icon component
        badge?: number | null;
    }>;
    export let sidebarOpen: boolean = false;

    const dispatch = createEventDispatcher();

    function handleLogout() {
        dispatch("logout");
    }

    function handleTabChange(id: string) {
        activeTab = id;
        dispatch("tabChange", id);
        dispatch("closeSidebar"); // Close sidebar on mobile on selection
    }
</script>

<div class="dashboard-layout">
    <!-- Sidebar -->
    <aside class="sidebar bg-primary {sidebarOpen ? 'open' : ''}">
        <div class="sidebar-header">
            <div class="avatar">
                <!-- Slot for Avatar/Logo content -->
                <slot name="header-icon">
                    <div class="default-avatar">
                        <span class="text-2xl">{title[0]}</span>
                    </div>
                </slot>
            </div>
            <div class="info">
                <h3>
                    <slot name="header-title">{title}</slot>
                </h3>
                <span class="status-badge">
                    <slot name="header-subtitle">
                        Role: {profile?.role || "Admin"}
                    </slot>
                </span>
            </div>
            <div class="header-actions-container ml-auto">
                <slot name="header-actions" />
            </div>
        </div>

        <nav class="nav-links">
            {#each menuItems as item}
                <button
                    class:active={activeTab === item.id}
                    on:click={() => handleTabChange(item.id)}
                >
                    <span class="icon">
                        <svelte:component this={item.icon} size={20} />
                    </span>
                    <span class="label">{item.label}</span>
                    {#if item.badge}
                        <span class="badge">{item.badge}</span>
                    {/if}
                </button>
            {/each}

            <button class="logout" on:click={handleLogout}>
                <span class="icon">🚪</span>
                <span class="label">Keluar</span>
            </button>
        </nav>
    </aside>

    <!-- Mobile Overlay -->
    {#if sidebarOpen}
        <div
            class="mobile-overlay"
            on:click={() => dispatch("closeSidebar")}
            on:keydown={() => dispatch("closeSidebar")}
            role="button"
            tabindex="0"
            aria-label="Close sidebar"
        ></div>
    {/if}

    <!-- Main Content -->
    <main class="content">
        <header class="mobile-header lg:hidden">
            <button class="menu-btn" on:click={() => dispatch("toggleSidebar")}>
                ☰
            </button>
            <h1>{title}</h1>
        </header>

        <slot />
    </main>
</div>

<style>
    .dashboard-layout {
        display: flex;
        height: 100vh;
        background: var(--bg-soft);
        overflow: hidden;
    }

    /* Sidebar Styles from ShopDashboard */
    .sidebar {
        width: 260px;
        display: flex;
        flex-direction: column;
        color: white;
        padding: 24px 0;
        background-color: var(--primary); /* Deep Blue */
        flex-shrink: 0;
        transition: transform 0.3s ease;
        z-index: 50;
    }

    .sidebar-header {
        padding: 0 16px 24px;
        display: flex;
        align-items: center;
        gap: 12px;
        border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    }

    .avatar {
        width: 48px;
        height: 48px;
        background: rgba(255, 255, 255, 0.2);
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        overflow: hidden;
        flex-shrink: 0;
    }

    .default-avatar {
        width: 100%;
        height: 100%;
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
    }

    .info {
        flex: 1;
        min-width: 0; /* Truncate text */
    }

    .info h3 {
        margin: 0;
        font-size: 14px;
        font-weight: 600;
        color: white;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .status-badge {
        font-size: 10px;
        background: var(--accent);
        padding: 2px 8px;
        border-radius: 10px;
        color: white;
        margin-top: 4px;
        display: inline-block;
        white-space: nowrap;
    }

    .header-actions-container {
        display: flex;
        align-items: center;
    }

    .nav-links {
        margin-top: 24px;
        display: flex;
        flex-direction: column;
        gap: 4px;
        flex: 1;
        overflow-y: auto;
    }

    .nav-links button {
        background: none;
        color: rgba(255, 255, 255, 0.7);
        text-align: left;
        padding: 14px 24px;
        font-size: 14px;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 12px;
        border: none;
        cursor: pointer;
        transition: all 0.2s;
        outline: none;
    }

    .nav-links button:hover {
        background: rgba(255, 255, 255, 0.05);
        color: white;
    }

    .nav-links button.active {
        background: rgba(255, 255, 255, 0.1);
        color: white;
        box-shadow: inset 4px 0 0 var(--accent); /* Orange accent line */
    }

    .nav-links button.logout {
        margin-top: auto;
        color: #ffbaba;
    }

    .nav-links button.logout:hover {
        background: rgba(255, 0, 0, 0.1);
    }

    .badge {
        margin-left: auto;
        background: var(--danger, #ef4444);
        color: white;
        font-size: 11px;
        font-weight: bold;
        padding: 2px 8px;
        border-radius: 999px;
    }

    /* Content Area */
    .content {
        flex: 1;
        overflow-y: auto;
        position: relative;
        padding: 32px; /* Match ShopDashboard padding */
    }

    /* Mobile Responsive */
    .mobile-header {
        display: none; /* Hidden on desktop */
        padding: 16px;
        background: white;
        border-bottom: 1px solid #e2e8f0;
        align-items: center;
        gap: 16px;
    }

    .mobile-header h1 {
        margin: 0;
        font-size: 18px;
        font-weight: 600;
    }

    .menu-btn {
        background: none;
        border: none;
        font-size: 24px;
        padding: 4px;
        cursor: pointer;
    }

    @media (max-width: 1024px) {
        .sidebar {
            position: fixed;
            top: 0;
            bottom: 0;
            left: 0;
            transform: translateX(-100%);
        }

        .sidebar.open {
            transform: translateX(0);
        }

        .mobile-header {
            display: flex;
        }
    }

    .mobile-overlay {
        position: fixed;
        inset: 0;
        background: rgba(0, 0, 0, 0.5);
        z-index: 40;
        backdrop-filter: blur(2px);
    }
</style>
