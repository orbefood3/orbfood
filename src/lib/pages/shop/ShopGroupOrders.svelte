<script lang="ts">
    import { onMount } from "svelte";
    import { supabase } from "../../services/supabase";
    import {
        Users,
        Clock,
        CheckCircle2,
        AlertCircle,
        Eye,
        Plus,
        Calendar,
        Repeat,
        RefreshCw,
        Edit,
        Trash2,
        MoreVertical
    } from "lucide-svelte";
    import GroupOrderSummaryModal from "../../components/modals/GroupOrderSummaryModal.svelte";
    import CreateGroupModal from "../../components/modals/CreateGroupModal.svelte";
    import type {
        OrderRoom,
        GroupOrderParticipant,
    } from "../../types/groupOrder";

    export let shopId: string;

    let groups: OrderRoom[] = [];
    let loading = true;
    let selectedGroup: OrderRoom | null = null;
    let groupParticipants: GroupOrderParticipant[] = [];
    let showSummaryModal = false;
    let showCreateModal = false;
    let showEditModal = false;
    let editingGroup: OrderRoom | null = null;
    let isCreating = false;

    onMount(() => {
        fetchGroups();
    });

    async function fetchGroups(showToast = false) {
        loading = true;
        const { data, error } = await supabase
            .from("order_rooms")
            .select("*")
            .eq("store_id", shopId)
            .order("created_at", { ascending: false });

        if (error) {
            console.error("Error fetching groups:", error);
            if (showToast) {
                const { toasts } = await import("../../stores/toastStore");
                toasts.error("Gagal memuat grup");
            }
        } else {
            groups = data || [];
            if (showToast) {
                const { toasts } = await import("../../stores/toastStore");
                toasts.success("Data grup berhasil diperbarui");
            }
        }
        loading = false;
    }

    async function handleOpenGroup(group: OrderRoom) {
        selectedGroup = group;
        const { data } = await supabase
            .from("order_history")
            .select(
                "id, participant_name, total_price, items, status, transfer_proof_url, payment_status, is_archived, user_id",
            )
            .eq("order_room_id", group.id)
            .eq("is_archived", false);

        groupParticipants = data || [];
        showSummaryModal = true;
    }

    async function handleCreateGroup(event: CustomEvent) {
        isCreating = true;
        const {
            name,
            closingTime,
            scheduleType,
            scheduleDays,
            openingTimeDaily,
            closingTimeDaily,
            openingTime // Make sure we pass the one-time openingTime if logic requires it
        } = event.detail;

        const { data, error } = await supabase
            .from("order_rooms")
            .insert({
                store_id: shopId,
                creator_id: (await supabase.auth.getUser()).data.user?.id,
                name: name,
                closing_time: closingTime,
                is_shop_managed: true,
                status: "open",
                schedule_type: scheduleType,
                schedule_days: scheduleDays,
                opening_time_daily: openingTimeDaily,
                closing_time_daily: closingTimeDaily,
            })
            .select()
            .single();

        if (!error) {
            groups = [data, ...groups];
            showCreateModal = false;
        }
        isCreating = false;
    }

    async function handleEditGroup(event: CustomEvent) {
        if (!editingGroup) return;
        isCreating = true;
        
        const {
            name,
            closingTime,
            scheduleType,
            scheduleDays,
            openingTimeDaily,
            closingTimeDaily,
            openingTime
        } = event.detail;

        const { data, error } = await supabase
            .from("order_rooms")
            .update({
                name: name,
                closing_time: closingTime,
                schedule_type: scheduleType,
                schedule_days: scheduleDays,
                opening_time_daily: openingTimeDaily,
                closing_time_daily: closingTimeDaily,
            })
            .eq("id", editingGroup.id)
            .select()
            .single();

        if (!error) {
            groups = groups.map(g => g.id === data.id ? data : g);
            showEditModal = false;
            editingGroup = null;
            
            const { toasts } = await import("../../stores/toastStore");
            toasts.success("Grup berhasil diperbarui!");
        } else {
            console.error("Error updating group:", error);
            const { toasts } = await import("../../stores/toastStore");
            toasts.error("Gagal memperbarui grup");
        }
        isCreating = false;
    }

    async function handleDeleteGroup(group: OrderRoom, event: Event) {
        event.stopPropagation();
        
        if (!confirm(`Apakah kamu yakin ingin membubarkan grup "${group.name}"? Semua data di dalamnya akan ikut terhapus.`)) {
            return;
        }

        loading = true;
        // The foreign key constraints on order_history should be set to cascade,
        // but it's safe to just delete the room if RLS allows it.
        const { error } = await supabase
            .from("order_rooms")
            .delete()
            .eq("id", group.id);

        if (error) {
            console.error("Error deleting group:", error);
            const { toasts } = await import("../../stores/toastStore");
            toasts.error("Gagal menghapus grup");
        } else {
            // Remove from local state
            groups = groups.filter(g => g.id !== group.id);
            const { toasts } = await import("../../stores/toastStore");
            toasts.success(`Grup "${group.name}" berhasil dihapus`);
        }
        loading = false;
    }
</script>

<div class="space-y-6">
    <div class="flex justify-between items-center bg-gray-50/50 p-2 rounded-2xl">
        <div class="px-2">
            <h2 class="text-xl font-black text-gray-900">
                Pengelolaan Group Order
            </h2>
            <p class="text-sm text-gray-500 font-medium">
                Lihat dan atur pesanan bersama di tokomu
            </p>
        </div>
        <div class="flex items-center gap-2">
            <button
                class="bg-white text-gray-600 border border-gray-200 px-3 py-2 rounded-xl font-bold flex items-center gap-2 hover:bg-gray-50 transition-all shadow-sm"
                on:click={() => fetchGroups(true)}
                title="Refresh Data"
                disabled={loading}
            >
                <RefreshCw size={18} class={loading ? "animate-spin" : ""} />
            </button>
            <button
                class="bg-primary text-white px-4 py-2 rounded-xl font-bold flex items-center gap-2 hover:scale-[1.02] transition-all shadow-lg shadow-primary/20"
                on:click={() => (showCreateModal = true)}
            >
                <Plus size={20} />
                Jadwalkan Grup
            </button>
        </div>
    </div>

    {#if loading}
        <div class="flex justify-center py-20">
            <div
                class="animate-spin w-8 h-8 border-4 border-primary border-t-transparent rounded-full"
            ></div>
        </div>
    {:else if groups.length === 0}
        <div
            class="bg-white border-2 border-dashed border-gray-100 rounded-3xl p-12 text-center"
        >
            <div
                class="w-16 h-16 bg-gray-50 rounded-full flex items-center justify-center mx-auto mb-4"
            >
                <Users size={32} class="text-gray-300" />
            </div>
            <h3 class="font-bold text-gray-800">Belum ada Group Order</h3>
            <p class="text-sm text-gray-400 mt-1">
                Kamu bisa membuat grup otomatis atau menunggu pelanggan
                membuatnya.
            </p>
        </div>
    {:else}
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            {#each groups as group}
                <button
                    class="bg-white border border-gray-100 p-5 rounded-2xl shadow-sm hover:shadow-md hover:border-primary/30 transition-all text-left group"
                    on:click={() => handleOpenGroup(group)}
                >
                    <div class="flex justify-between items-start mb-3">
                        <div>
                            <div class="flex items-center gap-2 mb-1">
                                {#if group.schedule_type === "recurring"}
                                    <span class="bg-blue-100 text-blue-600 p-1 rounded-md" title="Jadwal Berulang">
                                        <Repeat size={10} />
                                    </span>
                                {/if}
                                {#if group.status === "open"}
                                    <span
                                        class="w-2 h-2 rounded-full bg-green-500 animate-pulse"
                                    ></span>
                                    <span
                                        class="text-[10px] font-black text-green-600 uppercase tracking-widest"
                                        >AKTIF</span
                                    >
                                {:else}
                                    <span
                                        class="text-[10px] font-black text-gray-400 uppercase tracking-widest"
                                        >SELESAI</span
                                    >
                                {/if}
                            </div>
                            <h3
                                class="font-bold text-gray-900 group-hover:text-primary transition-colors"
                            >
                                {group.name}
                            </h3>
                            <p
                                class="text-[10px] font-bold text-gray-400 font-mono mt-0.5 uppercase"
                            >
                                CODE: {group.short_code}
                            </p>
                        </div>
                        <div class="flex items-center gap-1">
                            {#if group.status === "open"}
                                <button
                                    class="p-2 text-gray-400 hover:text-primary hover:bg-primary/10 rounded-xl transition-all"
                                    title="Edit Grup"
                                    on:click|stopPropagation={() => {
                                        editingGroup = group;
                                        showEditModal = true;
                                    }}
                                >
                                    <Edit size={16} />
                                </button>
                                <button
                                    class="p-2 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-xl transition-all"
                                    title="Bubarkan Grup"
                                    on:click={(e) => handleDeleteGroup(group, e)}
                                >
                                    <Trash2 size={16} />
                                </button>
                            {/if}
                        </div>
                    </div>

                    <div
                        class="flex items-center justify-between mt-4 pt-4 border-t border-gray-50"
                    >
                        <div
                            class="text-[10px] text-gray-500 font-bold uppercase tracking-wider flex items-center gap-1"
                        >
                            <Clock size={12} />
                            {#if group.schedule_type === "recurring"}
                                Harian: {group.closing_time_daily?.substring(0, 5) || "-"}
                            {:else}
                                {new Date(group.closing_time).toLocaleDateString(
                                    "id-ID",
                                    {
                                        day: "numeric",
                                        month: "short",
                                        hour: "2-digit",
                                        minute: "2-digit",
                                    },
                                )}
                            {/if}
                        </div>
                        <div
                            class="flex items-center gap-1 text-primary font-black text-xs"
                        >
                            Lihat Detail
                            <Eye size={14} />
                        </div>
                    </div>
                </button>
            {/each}
        </div>
    {/if}
</div>

{#if showSummaryModal && selectedGroup}
    <GroupOrderSummaryModal
        room={selectedGroup}
        participants={groupParticipants}
        isCreator={true}
        shopName={groups.find((r) => r.id === selectedGroup?.id)?.name ||
            "Toko Anda"}
        on:close={() => (showSummaryModal = false)}
    />
{/if}

{#if showCreateModal}
    <CreateGroupModal
        storeName="Kantin"
        isLoading={isCreating}
        isShopOwner={true}
        on:close={() => (showCreateModal = false)}
        on:submit={handleCreateGroup}
    />
{/if}

{#if showEditModal && editingGroup}
    <CreateGroupModal
        storeName="Kantin"
        isLoading={isCreating}
        isShopOwner={true}
        initialData={editingGroup}
        on:close={() => {
            showEditModal = false;
            editingGroup = null;
        }}
        on:submit={handleEditGroup}
    />
{/if}
