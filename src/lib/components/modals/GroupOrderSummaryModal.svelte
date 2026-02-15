<script lang="ts">
    import { createEventDispatcher } from "svelte";
    import {
        X,
        User,
        Copy,
        MessageCircle,
        FileImage,
        Eye,
        CheckCircle2,
        AlertCircle,
        ShieldCheck,
        Clock,
        Trash2,
    } from "lucide-svelte";
    import { supabase } from "../../services/supabase";
    import { onMount, onDestroy } from "svelte";
    import type {
        OrderRoom,
        GroupOrderParticipant,
    } from "../../types/groupOrder";

    export let room: OrderRoom;
    export let participants: GroupOrderParticipant[] = [];
    export let isCreator: boolean = false;
    export let shopName: string = "";
    export let currentUserId: string = "";
    export let creatorPhone: string = "";

    const dispatch = createEventDispatcher();
    let isCleaningUp = false;
    let realtimeChannel: any;

    onMount(() => {
        if (isCreator) {
            setupRealtime();
        }
    });

    onDestroy(() => {
        if (realtimeChannel) {
            supabase.removeChannel(realtimeChannel);
        }
    });

    function setupRealtime() {
        realtimeChannel = supabase
            .channel(`room-updates-${room.id}`)
            .on(
                "postgres_changes",
                {
                    event: "*",
                    schema: "public",
                    table: "order_history",
                    filter: `order_room_id=eq.${room.id}`,
                },
                (payload) => {
                    console.log("Realtime update:", payload);
                    refreshParticipants();
                },
            )
            .subscribe();
    }

    async function refreshParticipants() {
        const { data, error } = await supabase
            .from("order_history")
            .select(
                "id, participant_name, total_price, items, status, transfer_proof_url, payment_status, user_id",
            )
            .eq("order_room_id", room.id);

        if (!error && data) {
            participants = data;
        }
    }

    // Aggregate items
    let aggregatedItems: Record<
        string,
        { qty: number; price: number; name: string }
    > = {};
    let totalAmount = 0;
    let verifiedAmount = 0;
    let showOnlyVerified = false;

    $: {
        aggregatedItems = {};
        totalAmount = 0;
        verifiedAmount = 0;

        participants.forEach((p) => {
            totalAmount += p.total_price;
            if (p.payment_status === "verified") {
                verifiedAmount += p.total_price;
            }

            // If filtering, skip unverified for aggregation
            if (showOnlyVerified && p.payment_status !== "verified") return;

            const items = Array.isArray(p.items) ? p.items : [];
            items.forEach((item: any) => {
                const key =
                    item.name + (item.variant ? ` (${item.variant})` : "");
                if (!aggregatedItems[key]) {
                    aggregatedItems[key] = {
                        qty: 0,
                        price: item.price,
                        name: key,
                    };
                }
                aggregatedItems[key].qty += item.qty;
            });
        });
    }

    function generateWhatsAppText() {
        const header = `*ORDER GROUP - ${shopName.toUpperCase()}*\n${showOnlyVerified ? "_[Hanya Pesanan Terverifikasi]_" : ""}\n\n`;

        let itemsText = "";
        Object.values(aggregatedItems).forEach((item) => {
            itemsText += `- ${item.name} x${item.qty}\n`;
        });

        const footer = `\n*Total: Rp ${totalAmount.toLocaleString("id-ID")}*${showOnlyVerified ? `\n*(Terverifikasi: Rp ${verifiedAmount.toLocaleString("id-ID")})*` : ""}\n\n`;

        let userDetails = "*Rincian per orang:*\n";
        participants.forEach((p) => {
            if (showOnlyVerified && p.payment_status !== "verified") return;
            const statusIcon = p.payment_status === "verified" ? "✅" : "⏳";
            userDetails += `${statusIcon} ${p.participant_name}: Rp ${p.total_price.toLocaleString("id-ID")}\n`;
        });

        const fullText = header + itemsText + footer + userDetails;
        return fullText;
    }

    function handleSendToCreator() {
        const myOrder = participants.find((p) => p.user_id === currentUserId);
        if (!myOrder) return;

        let itemsText = "";
        myOrder.items.forEach((item: any) => {
            itemsText += `- ${item.name} x${item.qty}\n`;
        });

        const message = `Halo! Saya ${myOrder.participant_name}. 
Minta tolong masukin pesanan saya ke Room *${room.name}*:

${itemsText}
Total: Rp ${myOrder.total_price.toLocaleString("id-ID")}
Bukti Bayar: ${myOrder.transfer_proof_url || "Sudah di-upload"}

Terima kasih!`;

        const encodedMessage = encodeURIComponent(message);
        const cleanPhone = creatorPhone.replace(/^0/, "62").replace(/\D/g, "");

        window.open(
            `https://wa.me/${cleanPhone}?text=${encodedMessage}`,
            "_blank",
        );
    }

    async function handleVerify(participantId: string) {
        if (!isCreator) return;

        try {
            const { error } = await supabase
                .from("order_history")
                .update({ payment_status: "verified" })
                .eq("id", participantId);

            if (error) throw error;

            // Local update of participant list to reflect change immediately
            participants = participants.map((p) =>
                p.id === participantId
                    ? { ...p, payment_status: "verified" }
                    : p,
            );
        } catch (err) {
            console.error("Failed to verify payment:", err);
            alert("Gagal memverifikasi pembayaran.");
        }
    }

    async function handleDeleteOrder(
        participantId: string,
        ownerId: string | null,
    ) {
        const isOwn = ownerId === currentUserId;
        const msg = isOwn
            ? "Hapus pesanan Anda?"
            : "Hapus pesanan peserta ini?";
        if (!confirm(msg)) return;

        try {
            const { error } = await supabase
                .from("order_history")
                .delete()
                .eq("id", participantId);

            if (error) throw error;

            participants = participants.filter((p) => p.id !== participantId);
        } catch (error: any) {
            alert("Gagal menghapus: " + error.message);
        }
    }

    function handleCopyToClipboard() {
        const text = generateWhatsAppText();
        navigator.clipboard.writeText(text).then(() => {
            alert("Rekap pesanan berhasil disalin!");
        });
    }

    async function handleSendWhatsApp() {
        const text = generateWhatsAppText();

        isCleaningUp = true;
        try {
            // 1. Storage Cleanup (Physical Files)
            const { data: files } = await supabase.storage
                .from("transfer_proofs")
                .list(room.id);

            if (files && files.length > 0) {
                const pathsToDelete = files.map((f) => `${room.id}/${f.name}`);
                await supabase.storage
                    .from("transfer_proofs")
                    .remove(pathsToDelete);
            }

            // 2. Database Updates (Status & Nullify URLs)
            await supabase
                .from("order_rooms")
                .update({ status: "sent" })
                .eq("id", room.id);

            await supabase
                .from("order_history")
                .update({ transfer_proof_url: null })
                .eq("order_room_id", room.id);

            // 3. Open WhatsApp
            const url = `https://wa.me/?text=${encodeURIComponent(text)}`;
            window.open(url, "_blank");

            dispatch("close");
        } catch (err) {
            console.error("Automated cleanup failed:", err);
            // Even if cleanup fails, we open WA so the business isn't blocked
            const url = `https://wa.me/?text=${encodeURIComponent(text)}`;
            window.open(url, "_blank");
            dispatch("close");
        } finally {
            isCleaningUp = false;
        }
    }
</script>

<div
    class="fixed inset-0 z-[60] flex items-end sm:items-center justify-center bg-black/50 backdrop-blur-sm p-0 sm:p-4"
>
    <div
        class="bg-white w-full max-w-lg rounded-t-xl sm:rounded-xl shadow-2xl h-[90vh] sm:h-auto sm:max-h-[90vh] flex flex-col animate-in slide-in-from-bottom duration-300"
    >
        <div
            class="p-4 border-b flex justify-between items-center bg-gray-50 flex-shrink-0 rounded-t-xl"
        >
            <div>
                <h2 class="text-lg font-bold text-gray-800">
                    Rekap Group Order
                </h2>
                <p class="text-xs text-gray-500">
                    {room.name} • {participants.length} Peserta • {participants.filter(
                        (p) => p.payment_status === "verified",
                    ).length} Lunas
                </p>
            </div>
            <button
                on:click={() => dispatch("close")}
                class="text-gray-400 hover:text-gray-600 p-1 rounded-full hover:bg-gray-200"
            >
                <X size={24} />
            </button>
        </div>

        <div class="flex-1 overflow-y-auto p-4 space-y-6">
            <!-- Aggregated List -->
            <section>
                <h3
                    class="text-sm font-bold text-gray-700 uppercase tracking-wide mb-3 border-b pb-1"
                >
                    Total Pesanan
                </h3>
                {#if Object.keys(aggregatedItems).length === 0}
                    <p class="text-gray-400 text-sm italic py-4 text-center">
                        Belum ada pesanan masuk.
                    </p>
                {:else}
                    <div class="space-y-2">
                        {#each Object.values(aggregatedItems) as item}
                            <div
                                class="flex justify-between items-center text-sm"
                            >
                                <span class="text-gray-800 font-medium">
                                    {item.qty}x {item.name}
                                </span>
                                <span class="text-gray-500">
                                    Rp {(item.price * item.qty).toLocaleString(
                                        "id-ID",
                                    )}
                                </span>
                            </div>
                        {/each}

                        <div class="mt-4 space-y-1">
                            <div
                                class="flex justify-between items-center text-sm text-green-600 font-bold bg-green-50 px-3 py-2 rounded-lg"
                            >
                                <span>Total Terverifikasi</span>
                                <span
                                    >Rp {verifiedAmount.toLocaleString(
                                        "id-ID",
                                    )}</span
                                >
                            </div>
                            <div
                                class="flex justify-between items-center text-sm text-gray-500 px-3 py-1"
                            >
                                <span>Total Seluruhnya</span>
                                <span
                                    >Rp {totalAmount.toLocaleString(
                                        "id-ID",
                                    )}</span
                                >
                            </div>
                        </div>

                        {#if isCreator}
                            <div
                                class="flex items-center gap-2 mt-4 p-2 bg-blue-50 rounded-lg"
                            >
                                <input
                                    type="checkbox"
                                    id="filterVerified"
                                    bind:checked={showOnlyVerified}
                                    class="w-4 h-4 text-blue-600 rounded"
                                />
                                <label
                                    for="filterVerified"
                                    class="text-xs font-bold text-blue-700"
                                    >Hanya Rekap Pesanan Lunas</label
                                >
                            </div>
                        {/if}
                    </div>
                {/if}
            </section>

            <!-- Participant List -->
            <section>
                <h3
                    class="text-sm font-bold text-gray-700 uppercase tracking-wide mb-3 border-b pb-1 flex items-center gap-2"
                >
                    <User size={14} />
                    Rincian Peserta
                </h3>

                <div class="space-y-3">
                    {#each participants as p}
                        <div
                            class="bg-gray-50 p-3 rounded-lg flex justify-between items-start"
                        >
                            <div>
                                <p
                                    class="font-bold text-sm text-gray-900 flex items-center gap-1.5"
                                >
                                    {p.participant_name}
                                    {#if p.user_id === room.creator_id}
                                        <span
                                            class="text-[9px] bg-primary/10 text-primary px-1.5 py-0.5 rounded-full font-black uppercase"
                                            >Kamu</span
                                        >
                                    {/if}
                                </p>
                                <div class="text-xs text-gray-500 mt-1">
                                    {#each p.items as item}
                                        <span>{item.qty}x {item.name}, </span>
                                    {/each}
                                </div>
                            </div>
                            <div class="flex flex-col items-end gap-2">
                                <span
                                    class="font-mono font-bold text-sm text-gray-700"
                                >
                                    Rp {p.total_price.toLocaleString("id-ID")}
                                </span>

                                <div class="flex flex-col items-end gap-1.5">
                                    {#if p.payment_status === "verified"}
                                        <span
                                            class="text-[9px] font-black bg-green-100 text-green-600 px-1.5 py-0.5 rounded uppercase tracking-wider flex items-center gap-1"
                                        >
                                            <ShieldCheck size={10} />
                                            LUNAS & VERIFIED
                                        </span>
                                    {:else if p.transfer_proof_url}
                                        <div
                                            class="flex flex-col items-end gap-1"
                                        >
                                            <div
                                                class="flex items-center gap-1"
                                            >
                                                <span
                                                    class="text-[9px] font-black bg-blue-100 text-blue-600 px-1.5 py-0.5 rounded uppercase tracking-wider flex items-center gap-1"
                                                >
                                                    <Clock size={10} />
                                                    MENUNGGU VERIFIKASI
                                                </span>
                                                {#if p.user_id === currentUserId || isCreator}
                                                    <button
                                                        on:click={() =>
                                                            handleDeleteOrder(
                                                                p.id,
                                                                p.user_id,
                                                            )}
                                                        class="text-[9px] font-bold bg-white border border-red-200 text-red-500 hover:bg-red-50 px-1.5 py-0.5 rounded shadow-sm transition-all flex items-center gap-1"
                                                    >
                                                        <Trash2 size={10} />
                                                        HAPUS
                                                    </button>
                                                {/if}
                                            </div>
                                            <div
                                                class="flex items-center gap-1"
                                            >
                                                <a
                                                    href={p.transfer_proof_url}
                                                    target="_blank"
                                                    class="text-[9px] font-bold text-blue-500 hover:text-blue-700 flex items-center gap-1 bg-white border border-blue-100 px-1.5 py-0.5 rounded shadow-sm transition-all"
                                                >
                                                    <Eye size={10} />
                                                    Cek TF
                                                </a>
                                                {#if isCreator}
                                                    <button
                                                        on:click={() =>
                                                            handleVerify(p.id)}
                                                        class="text-[9px] font-bold bg-green-600 text-white hover:bg-green-700 px-1.5 py-0.5 rounded shadow-sm transition-all flex items-center gap-1"
                                                    >
                                                        <CheckCircle2
                                                            size={10}
                                                        />
                                                        VERIFIKASI
                                                    </button>
                                                {/if}
                                            </div>
                                        </div>
                                    {:else}
                                        <div class="flex items-center gap-1">
                                            <span
                                                class="text-[9px] font-black bg-red-100 text-red-600 px-1.5 py-0.5 rounded uppercase tracking-wider flex items-center gap-1"
                                            >
                                                <AlertCircle size={10} />
                                                PENDING TF
                                            </span>
                                            {#if p.user_id === currentUserId || isCreator}
                                                <button
                                                    on:click={() =>
                                                        handleDeleteOrder(
                                                            p.id,
                                                            p.user_id,
                                                        )}
                                                    class="text-[9px] font-bold bg-white border border-red-200 text-red-500 hover:bg-red-50 px-1.5 py-0.5 rounded shadow-sm transition-all flex items-center gap-1"
                                                >
                                                    <Trash2 size={10} />
                                                    HAPUS
                                                </button>
                                            {/if}
                                        </div>
                                    {/if}
                                </div>
                            </div>
                        </div>
                    {/each}
                </div>
            </section>
        </div>

        {#if isCreator}
            <div
                class="p-4 border-t bg-gray-50 flex-shrink-0 flex flex-col gap-2"
            >
                <div class="flex gap-2">
                    <button
                        class="flex-1 bg-white border border-gray-300 text-gray-700 py-3 rounded-lg font-bold flex items-center justify-center gap-2 hover:bg-gray-50 transition-colors shadow-sm"
                        on:click={handleCopyToClipboard}
                    >
                        <Copy size={18} />
                        Salin Rekap
                    </button>
                    <button
                        class="flex-[1.5] bg-green-600 text-white py-3 rounded-lg font-bold flex items-center justify-center gap-2 hover:bg-green-700 transition-colors shadow-sm disabled:opacity-50"
                        on:click={handleSendWhatsApp}
                        disabled={isCleaningUp}
                    >
                        {#if isCleaningUp}
                            <div
                                class="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"
                            ></div>
                            MEMPROSES...
                        {:else}
                            <MessageCircle size={18} />
                            {room.is_shop_managed
                                ? "Selesaikan & Salin"
                                : "Kirim ke WhatsApp Toko"}
                        {/if}
                    </button>
                </div>
                {#if !isCleaningUp}
                    <p
                        class="text-[10px] text-gray-400 text-center italic mt-1"
                    >
                        *Klik tombol hijau akan otomatis menutup room &
                        menghapus bukti TF
                    </p>
                {/if}
            </div>
        {:else}
            <div
                class="p-4 border-t bg-blue-50 flex-shrink-0 flex flex-col gap-3"
            >
                <p class="text-[11px] text-blue-700 font-medium text-center">
                    Pesan kamu sudah terekap. Pastikan pembuat room sudah
                    menerima detail pesananmu.
                </p>
                {#if creatorPhone}
                    <button
                        class="w-full bg-green-600 text-white py-3 rounded-xl font-bold flex items-center justify-center gap-2 hover:bg-green-700 transition-all shadow-md active:scale-[0.98]"
                        on:click={handleSendToCreator}
                    >
                        <MessageCircle size={18} />
                        Kirim ke Pembuat Room
                    </button>
                {/if}
            </div>
        {/if}
    </div>
</div>
