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
    } from "lucide-svelte";
    import GroupOrderSummaryModal from "../../components/modals/GroupOrderSummaryModal.svelte";
    import CreateRoomModal from "../../components/modals/CreateRoomModal.svelte";
    import type {
        OrderRoom,
        GroupOrderParticipant,
    } from "../../types/groupOrder";

    export let shopId: string;

    let rooms: OrderRoom[] = [];
    let loading = true;
    let selectedRoom: OrderRoom | null = null;
    let roomParticipants: GroupOrderParticipant[] = [];
    let showSummaryModal = false;
    let showCreateModal = false;
    let isCreating = false;

    onMount(() => {
        fetchRooms();
    });

    async function fetchRooms() {
        loading = true;
        const { data, error } = await supabase
            .from("order_rooms")
            .select("*")
            .eq("store_id", shopId)
            .order("created_at", { ascending: false });

        if (error) console.error("Error fetching rooms:", error);
        else rooms = data || [];
        loading = false;
    }

    async function handleOpenRoom(room: OrderRoom) {
        selectedRoom = room;
        const { data } = await supabase
            .from("order_history")
            .select(
                "id, participant_name, total_price, items, status, transfer_proof_url, payment_status",
            )
            .eq("order_room_id", room.id);

        roomParticipants = data || [];
        showSummaryModal = true;
    }

    async function handleCreateRoom(event: CustomEvent) {
        isCreating = true;
        const { name, closingTime } = event.detail;

        const { data, error } = await supabase
            .from("order_rooms")
            .insert({
                store_id: shopId,
                creator_id: (await supabase.auth.getUser()).data.user?.id,
                name: name,
                closing_time: closingTime,
                is_shop_managed: true,
                status: "open",
            })
            .select()
            .single();

        if (!error) {
            rooms = [data, ...rooms];
            showCreateModal = false;
        }
        isCreating = false;
    }
</script>

<div class="space-y-6">
    <div class="flex justify-between items-center">
        <div>
            <h2 class="text-xl font-black text-gray-900">
                Pengelolaan Group Order
            </h2>
            <p class="text-sm text-gray-500">
                Lihat dan atur pesanan bersama di tokomu
            </p>
        </div>
        <button
            class="bg-primary text-white px-4 py-2 rounded-xl font-bold flex items-center gap-2 hover:scale-105 transition-all shadow-lg shadow-primary/20"
            on:click={() => (showCreateModal = true)}
        >
            <Plus size={20} />
            Jadwalkan Room
        </button>
    </div>

    {#if loading}
        <div class="flex justify-center py-20">
            <div
                class="animate-spin w-8 h-8 border-4 border-primary border-t-transparent rounded-full"
            ></div>
        </div>
    {:else if rooms.length === 0}
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
                Kamu bisa membuat room otomatis atau menunggu pelanggan
                membuatnya.
            </p>
        </div>
    {:else}
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            {#each rooms as room}
                <button
                    class="bg-white border border-gray-100 p-5 rounded-2xl shadow-sm hover:shadow-md hover:border-primary/30 transition-all text-left group"
                    on:click={() => handleOpenRoom(room)}
                >
                    <div class="flex justify-between items-start mb-3">
                        <div>
                            <div class="flex items-center gap-2 mb-1">
                                {#if room.status === "open"}
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
                                {room.name}
                            </h3>
                            <p
                                class="text-[10px] font-bold text-gray-400 font-mono mt-0.5 uppercase"
                            >
                                CODE: {room.short_code}
                            </p>
                        </div>
                        <div class="bg-gray-50 p-2 rounded-xl">
                            <Calendar size={18} class="text-gray-400" />
                        </div>
                    </div>

                    <div
                        class="flex items-center justify-between mt-4 pt-4 border-t border-gray-50"
                    >
                        <div
                            class="text-[10px] text-gray-500 font-bold uppercase tracking-wider flex items-center gap-1"
                        >
                            <Clock size={12} />
                            {new Date(room.closing_time).toLocaleDateString(
                                "id-ID",
                                {
                                    day: "numeric",
                                    month: "short",
                                    hour: "2-digit",
                                    minute: "2-digit",
                                },
                            )}
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

{#if showSummaryModal && selectedRoom}
    <GroupOrderSummaryModal
        room={selectedRoom}
        participants={roomParticipants}
        isCreator={true}
        shopName={rooms.find((r) => r.id === selectedRoom?.id)?.name ||
            "Toko Anda"}
        on:close={() => (showSummaryModal = false)}
    />
{/if}

{#if showCreateModal}
    <CreateRoomModal
        storeName="Kantin"
        isLoading={isCreating}
        isShopOwner={true}
        on:close={() => (showCreateModal = false)}
        on:submit={handleCreateRoom}
    />
{/if}
