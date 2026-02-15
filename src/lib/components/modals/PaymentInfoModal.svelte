<script lang="ts">
    import { createEventDispatcher } from "svelte";
    import { X, Info, Copy, Check } from "lucide-svelte";

    export let show = false;
    export let roomName: string;
    export let paymentMethod: "qris" | "bank_transfer";
    export let qrisImageUrl: string | null = null;
    export let bankName: string | null = null;
    export let bankAccountNumber: string | null = null;
    export let bankAccountName: string | null = null;

    const dispatch = createEventDispatcher();

    let copied = false;

    async function copyText(text: string) {
        try {
            await navigator.clipboard.writeText(text);
            copied = true;
            setTimeout(() => (copied = false), 2000);
        } catch (err) {
            console.error("Failed to copy:", err);
        }
    }
</script>

{#if show}
    <div
        class="fixed inset-0 z-[100] flex items-end sm:items-center justify-center p-0 sm:p-4 bg-black/60 backdrop-blur-sm animate-in fade-in duration-300"
    >
        <!-- Modal Content -->
        <div
            class="relative bg-white w-full max-w-lg rounded-t-3xl sm:rounded-2xl shadow-2xl overflow-hidden animate-in slide-in-from-bottom-full sm:zoom-in-95 duration-300 flex flex-col max-h-[85vh]"
        >
            <!-- Header -->
            <div
                class="p-5 border-b flex justify-between items-center bg-gradient-to-r from-primary/5 to-primary/10"
            >
                <div>
                    <h2
                        class="text-xl font-black text-gray-900 flex items-center gap-2"
                    >
                        <Info size={24} class="text-primary" />
                        Info Pembayaran
                    </h2>
                    <p class="text-xs text-gray-500 mt-0.5">
                        Bayar ke pembuat room: <span class="font-bold"
                            >{roomName}</span
                        >
                    </p>
                </div>
                <button
                    on:click={() => dispatch("close")}
                    class="text-gray-400 hover:text-gray-600 p-2 rounded-full hover:bg-gray-200 transition-all"
                >
                    <X size={20} />
                </button>
            </div>

            <!-- Content -->
            <div class="flex-1 overflow-y-auto p-6">
                {#if paymentMethod === "qris"}
                    <!-- QRIS Payment -->
                    <div class="space-y-4">
                        <div
                            class="flex items-center justify-center gap-2 text-sm font-black text-primary uppercase tracking-wider"
                        >
                            💳 Scan QRIS di Bawah
                        </div>
                        {#if qrisImageUrl}
                            <div
                                class="relative bg-gray-50 rounded-2xl p-4 border-2 border-dashed border-gray-200"
                            >
                                <img
                                    src={qrisImageUrl}
                                    alt="QRIS Code"
                                    class="w-full max-w-sm mx-auto rounded-lg shadow-md"
                                />
                            </div>
                        {:else}
                            <div
                                class="bg-red-50 border border-red-200 rounded-xl p-4 text-center"
                            >
                                <p class="text-sm text-red-600 font-medium">
                                    ⚠️ QRIS tidak tersedia
                                </p>
                            </div>
                        {/if}
                    </div>
                {:else if paymentMethod === "bank_transfer"}
                    <!-- Bank Transfer Payment -->
                    <div class="space-y-4">
                        <div
                            class="flex items-center justify-center gap-2 text-sm font-black text-primary uppercase tracking-wider mb-4"
                        >
                            🏦 Transfer ke Rekening
                        </div>

                        <!-- Bank Name -->
                        <div
                            class="bg-gray-50 rounded-xl p-4 border border-gray-100"
                        >
                            <label
                                class="text-xs font-bold text-gray-500 uppercase"
                                >Bank</label
                            >
                            <div class="flex items-center justify-between mt-2">
                                <p class="text-lg font-black text-gray-900">
                                    {bankName || "N/A"}
                                </p>
                            </div>
                        </div>

                        <!-- Account Number -->
                        <div
                            class="bg-gray-50 rounded-xl p-4 border border-gray-100"
                        >
                            <label
                                class="text-xs font-bold text-gray-500 uppercase"
                                >Nomor Rekening</label
                            >
                            <div
                                class="flex items-center justify-between mt-2 gap-3"
                            >
                                <p
                                    class="text-lg font-black text-gray-900 tracking-wider"
                                >
                                    {bankAccountNumber || "N/A"}
                                </p>
                                {#if bankAccountNumber}
                                    <button
                                        on:click={() =>
                                            copyText(bankAccountNumber || "")}
                                        class="flex items-center gap-1 px-3 py-1.5 bg-primary/10 text-primary rounded-lg text-xs font-bold hover:bg-primary/20 transition-colors"
                                    >
                                        {#if copied}
                                            <Check size={14} />
                                            Copied!
                                        {:else}
                                            <Copy size={14} />
                                            Copy
                                        {/if}
                                    </button>
                                {/if}
                            </div>
                        </div>

                        <!-- Account Holder Name -->
                        <div
                            class="bg-gray-50 rounded-xl p-4 border border-gray-100"
                        >
                            <label
                                class="text-xs font-bold text-gray-500 uppercase"
                                >Atas Nama</label
                            >
                            <div class="flex items-center justify-between mt-2">
                                <p class="text-lg font-black text-gray-900">
                                    {bankAccountName || "N/A"}
                                </p>
                            </div>
                        </div>
                    </div>
                {/if}

                <!-- Important Note -->
                <div
                    class="mt-6 bg-blue-50 border border-blue-100 rounded-xl p-4"
                >
                    <p
                        class="text-xs text-blue-700 font-medium leading-relaxed"
                    >
                        ℹ️ <strong>Penting:</strong> Setelah transfer, jangan lupa
                        upload bukti pembayaran di halaman checkout agar bisa diverifikasi
                        oleh pembuat room.
                    </p>
                </div>
            </div>

            <!-- Footer -->
            <div class="p-4 border-t bg-white flex-shrink-0">
                <button
                    class="w-full py-3 bg-primary text-white font-black rounded-2xl shadow-lg shadow-primary/20 hover:scale-[1.02] active:scale-95 transition-all"
                    on:click={() => dispatch("proceed")}
                >
                    Mengerti, Lanjut Pesan
                </button>
            </div>
        </div>
    </div>
{/if}

<style>
    .animate-in {
        animation: fadeIn 0.3s ease-out;
    }

    @keyframes fadeIn {
        from {
            opacity: 0;
        }
        to {
            opacity: 1;
        }
    }
</style>
