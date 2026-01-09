<script lang="ts">
    import { onMount } from "svelte";
    import { supabase } from "../../services/supabase";
    import LoadingSpinner from "../../components/ui/LoadingSpinner.svelte";
    import PageWrapper from "../../components/ui/PageWrapper.svelte";
    import EmptyState from "../../components/ui/EmptyState.svelte";
    import {
        Users,
        Search,
        UserCog,
        Check,
        X,
        ChevronLeft,
        ChevronRight,
        Trash2,
        Shield,
    } from "lucide-svelte";

    let users: any[] = [];
    let loading = true;
    let searchQuery = "";
    let currentPage = 1;
    let itemsPerPage = 10;
    let totalItems = 0;
    let searchTimeout: any;

    let editingUser: any = null;
    let selectedRole = "";

    const roles = [
        { value: "user", label: "User", color: "bg-gray-100 text-gray-800" },
        {
            value: "shop",
            label: "Shop Owner",
            color: "bg-blue-100 text-blue-800",
        },
        {
            value: "admin",
            label: "Admin",
            color: "bg-purple-100 text-purple-800",
        },
    ];

    onMount(fetchUsers);

    async function fetchUsers() {
        loading = true;

        const from = (currentPage - 1) * itemsPerPage;
        const to = from + itemsPerPage - 1;

        let query = supabase
            .from("user_profiles")
            .select("*", { count: "exact" })
            .order("created_at", { ascending: false })
            .range(from, to);

        if (searchQuery) {
            query = supabase
                .from("user_profiles")
                .select("*", { count: "exact" })
                .ilike("display_name", `%${searchQuery}%`)
                .order("created_at", { ascending: false })
                .range(from, to);
        }

        const { data, count, error } = await query;

        if (error) {
            console.error("Error fetching users:", error);
        } else {
            users = data || [];
            totalItems = count || 0;
        }
        loading = false;
    }

    function handleSearchInput() {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(() => {
            currentPage = 1;
            fetchUsers();
        }, 500);
    }

    function changePage(step: number) {
        currentPage += step;
        fetchUsers();
    }

    function handleEdit(user: any) {
        editingUser = user;
        selectedRole = user.role;
    }

    async function saveRole() {
        if (!editingUser) return;

        const confirmed = confirm(
            `Ubah role ${editingUser.display_name} menjadi ${selectedRole}? \n\nPERINGATAN: Mengubah menjadi Admin akan memberikan akses penuh.`,
        );
        if (!confirmed) return;

        const { error } = await supabase
            .from("user_profiles")
            .update({ role: selectedRole })
            .eq("id", editingUser.id);

        if (error) {
            alert("Gagal mengupdate role: " + error.message);
        } else {
            // Optimistic update
            users = users.map((u) =>
                u.id === editingUser.id ? { ...u, role: selectedRole } : u,
            );
            editingUser = null;
        }
    }

    async function deleteUser(user: any) {
        if (
            !confirm(
                `Hapus data profil pengguna "${user.display_name}"? \n\nPERINGATAN: Aksi ini mungkin tidak menghapus akun login (Auth), hanya data profil database.`,
            )
        ) {
            return;
        }

        const { error } = await supabase
            .from("user_profiles")
            .delete()
            .eq("id", user.id);

        if (error) {
            alert("Gagal menghapus profil: " + error.message);
        } else {
            fetchUsers();
        }
    }

    $: totalPages = Math.ceil(totalItems / itemsPerPage);
</script>

<PageWrapper>
    <!-- Reusing PageWrapper for consistency if desired, or simple div -->
    <div class="space-y-6">
        <!-- Header & Search -->
        <div class="flex justify-between items-center mb-6">
            <div>
                <h2
                    class="text-2xl font-bold text-gray-900 flex items-center gap-2"
                >
                    <Users class="text-primary" /> Manajemen Pengguna
                </h2>
                <p class="text-gray-500 text-sm">
                    Kelola role dan akses pengguna.
                </p>
            </div>

            <div class="flex items-center gap-4">
                <div
                    class="relative w-64 bg-white rounded-lg border border-gray-200 flex items-center px-3 py-2"
                >
                    <Search size={18} class="text-gray-400 mr-2" />
                    <input
                        type="text"
                        bind:value={searchQuery}
                        on:input={handleSearchInput}
                        placeholder="Cari pengguna..."
                        class="w-full bg-transparent outline-none text-sm"
                    />
                </div>
                <div class="text-sm text-gray-500 whitespace-nowrap">
                    Total: {totalItems}
                </div>
            </div>
        </div>

        {#if loading}
            <div class="flex justify-center p-12">
                <LoadingSpinner />
            </div>
        {:else if users.length === 0}
            <EmptyState
                message={searchQuery
                    ? "User tidak ditemukan"
                    : "Belum ada user"}
                icon="👥"
            />
        {:else}
            <div
                class="bg-white rounded-xl border border-gray-200 overflow-hidden shadow-sm"
            >
                <div class="overflow-x-auto">
                    <table class="w-full text-left border-collapse">
                        <thead class="bg-gray-50 border-b border-gray-200">
                            <tr>
                                <th
                                    class="px-6 py-4 text-xs font-semibold text-gray-600 uppercase tracking-wider w-16"
                                    >Avatar</th
                                >
                                <th
                                    class="px-6 py-4 text-xs font-semibold text-gray-600 uppercase tracking-wider"
                                    >Nama Display</th
                                >
                                <th
                                    class="px-6 py-4 text-xs font-semibold text-gray-600 uppercase tracking-wider"
                                    >Role</th
                                >
                                <th
                                    class="px-6 py-4 text-xs font-semibold text-gray-600 uppercase tracking-wider"
                                    >Bergabung</th
                                >
                                <th
                                    class="px-6 py-4 text-right text-xs font-semibold text-gray-600 uppercase tracking-wider"
                                    >Aksi</th
                                >
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-200">
                            {#each users as user}
                                <tr class="hover:bg-gray-50 transition-colors">
                                    <td class="px-6 py-4">
                                        <div
                                            class="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center overflow-hidden"
                                        >
                                            {#if user.avatar_url}
                                                <img
                                                    src={user.avatar_url}
                                                    alt={user.display_name}
                                                    class="w-full h-full object-cover"
                                                />
                                            {:else}
                                                <span
                                                    class="text-gray-500 font-bold text-sm"
                                                    >{(user.display_name ||
                                                        "U")[0].toUpperCase()}</span
                                                >
                                            {/if}
                                        </div>
                                    </td>
                                    <td class="px-6 py-4">
                                        <div class="font-medium text-gray-900">
                                            {user.display_name || "Tanpa Nama"}
                                        </div>
                                        <div
                                            class="text-xs text-gray-500 font-mono mt-0.5"
                                        >
                                            {user.id.slice(0, 8)}...
                                        </div>
                                    </td>
                                    <td class="px-6 py-4">
                                        {#if editingUser?.id === user.id}
                                            <select
                                                bind:value={selectedRole}
                                                class="text-sm border rounded px-2 py-1 bg-white focus:ring-2 focus:ring-blue-500 outline-none"
                                            >
                                                {#each roles as role}
                                                    <option value={role.value}
                                                        >{role.label}</option
                                                    >
                                                {/each}
                                            </select>
                                        {:else}
                                            {@const roleObj =
                                                roles.find(
                                                    (r) =>
                                                        r.value === user.role,
                                                ) || roles[0]}
                                            <span
                                                class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium {roleObj.color}"
                                            >
                                                {roleObj.label}
                                            </span>
                                        {/if}
                                    </td>
                                    <td class="px-6 py-4 text-sm text-gray-500">
                                        {new Date(
                                            user.created_at,
                                        ).toLocaleDateString("id-ID", {
                                            day: "numeric",
                                            month: "short",
                                            year: "numeric",
                                        })}
                                    </td>
                                    <td class="px-6 py-4 text-right">
                                        {#if editingUser?.id === user.id}
                                            <div class="flex justify-end gap-2">
                                                <button
                                                    on:click={saveRole}
                                                    class="p-1.5 bg-green-100 text-green-700 rounded hover:bg-green-200 transition-colors"
                                                    title="Simpan"
                                                >
                                                    <Check size={16} />
                                                </button>
                                                <button
                                                    on:click={() =>
                                                        (editingUser = null)}
                                                    class="p-1.5 bg-gray-100 text-gray-700 rounded hover:bg-gray-200 transition-colors"
                                                    title="Batal"
                                                >
                                                    <X size={16} />
                                                </button>
                                            </div>
                                        {:else}
                                            <div class="flex justify-end gap-2">
                                                <button
                                                    on:click={() =>
                                                        handleEdit(user)}
                                                    class="p-1.5 text-gray-500 hover:text-blue-600 hover:bg-blue-50 rounded-md transition-colors"
                                                    title="Edit Role"
                                                >
                                                    <UserCog size={18} />
                                                </button>

                                                <button
                                                    on:click={() =>
                                                        deleteUser(user)}
                                                    class="p-1.5 text-gray-500 hover:text-red-600 hover:bg-red-50 rounded-md transition-colors"
                                                    title="Hapus Pengguna"
                                                >
                                                    <Trash2 size={18} />
                                                </button>
                                            </div>
                                        {/if}
                                    </td>
                                </tr>
                            {/each}
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Pagination -->
            {#if totalPages > 1}
                <div class="flex items-center justify-between mt-6 px-2">
                    <p class="text-sm text-gray-500">
                        {(currentPage - 1) * itemsPerPage + 1}-{Math.min(
                            currentPage * itemsPerPage,
                            totalItems,
                        )} dari {totalItems}
                    </p>

                    <div class="flex items-center gap-2">
                        <button
                            on:click={() => changePage(-1)}
                            disabled={currentPage === 1}
                            class="flex items-center gap-1 px-3 py-1.5 text-sm border border-gray-200 rounded-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed bg-white"
                        >
                            <ChevronLeft size={16} /> Prev
                        </button>
                        <span class="text-sm font-medium text-gray-700 px-2">
                            {currentPage} / {totalPages}
                        </span>
                        <button
                            on:click={() => changePage(1)}
                            disabled={currentPage === totalPages}
                            class="flex items-center gap-1 px-3 py-1.5 text-sm border border-gray-200 rounded-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed bg-white"
                        >
                            Next <ChevronRight size={16} />
                        </button>
                    </div>
                </div>
            {/if}
        {/if}
    </div>
</PageWrapper>
