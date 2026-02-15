<script lang="ts">
    import { createEventDispatcher, onMount } from "svelte";
    import {
        X,
        Clock,
        Users,
        Upload,
        CreditCard,
        Building2,
    } from "lucide-svelte";
    import { supabase } from "../../services/supabase";

    export let storeName: string;
    export let isLoading = false;
    export let isShopOwner = false; // New prop to detect if user is shop owner

    const dispatch = createEventDispatcher();

    let roomName = `${storeName} Order`;
    let duration = 30; // minutes
    let useFixedTime = false;
    let fixedTime = ""; // HH:mm
    let openingTime = ""; // For shop owners only (HH:mm)

    // Payment method fields
    let paymentMethod: "qris" | "bank_transfer" = "qris";
    let qrisFile: File | null = null;
    let qrisPreview: string | null = null;
    let bankName = "";
    let bankAccountNumber = "";
    let bankAccountName = "";

    const durationOptions = [
        { label: "15 Menit", value: 15 },
        { label: "30 Menit", value: 30 },
        { label: "45 Menit", value: 45 },
        { label: "1 Jam", value: 60 },
        { label: "2 Jam", value: 120 },
    ];

    // ============================
    // Auto-fill from User Profile
    // ============================
    onMount(async () => {
        const {
            data: { user },
        } = await supabase.auth.getUser();
        if (!user) return;

        const { data: profile } = await supabase
            .from("user_profiles")
            .select(
                "payment_method, qris_image_url, bank_name, bank_account_number, bank_account_name",
            )
            .eq("id", user.id)
            .single();

        if (profile) {
            if (profile.payment_method) {
                paymentMethod = profile.payment_method as
                    | "qris"
                    | "bank_transfer";
            }
            if (profile.qris_image_url) {
                qrisPreview = profile.qris_image_url;
            }
            if (profile.bank_name) {
                bankName = profile.bank_name;
            }
            if (profile.bank_account_number) {
                bankAccountNumber = profile.bank_account_number;
            }
            if (profile.bank_account_name) {
                bankAccountName = profile.bank_account_name;
            }
        }
    });

    async function processImage(file: File): Promise<Blob> {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = (e) => {
                const img = new Image();
                img.onload = () => {
                    const canvas = document.createElement("canvas");
                    let width = img.width;
                    let height = img.height;
                    const maxDim = 1000;
                    if (width > height) {
                        if (width > maxDim) {
                            height *= maxDim / width;
                            width = maxDim;
                        }
                    } else {
                        if (height > maxDim) {
                            width *= maxDim / height;
                            height = maxDim;
                        }
                    }
                    canvas.width = width;
                    canvas.height = height;
                    const ctx = canvas.getContext("2d");
                    ctx?.drawImage(img, 0, 0, width, height);
                    canvas.toBlob(
                        (blob) => {
                            if (blob) resolve(blob);
                            else reject(new Error("Gagal kompres gambar"));
                        },
                        "image/jpeg",
                        0.7,
                    );
                };
                img.src = e.target?.result as string;
            };
            reader.onerror = reject;
            reader.readAsDataURL(file);
        });
    }

    async function handleQrisUpload(event: Event) {
        const target = event.target as HTMLInputElement;
        const file = target.files?.[0];
        if (file) {
            qrisFile = file;
            const compressedBlob = await processImage(file);
            qrisPreview = URL.createObjectURL(compressedBlob);
        }
    }

    async function handleSubmit() {
        if (!roomName.trim()) {
            alert("Nama room wajib diisi!");
            return;
        }

        // Validate payment method
        if (paymentMethod === "qris" && !qrisFile) {
            alert("Upload QRIS wajib untuk metode QRIS!");
            return;
        }

        if (paymentMethod === "bank_transfer") {
            if (!bankName || !bankAccountNumber || !bankAccountName) {
                alert("Data rekening harus lengkap!");
                return;
            }
        }

        // Calculate closing time
        let closingTimeISO;
        if (useFixedTime && fixedTime) {
            const [hours, minutes] = fixedTime.split(":").map(Number);
            const closingDate = new Date();
            closingDate.setHours(hours, minutes, 0, 0);
            if (closingDate < new Date()) {
                closingDate.setDate(closingDate.getDate() + 1);
            }
            closingTimeISO = closingDate.toISOString();
        } else {
            closingTimeISO = new Date(
                Date.now() + duration * 60000,
            ).toISOString();
        }

        // Calculate opening time (shop owners only)
        let openingTimeISO = null;
        if (isShopOwner && openingTime) {
            const [hours, minutes] = openingTime.split(":").map(Number);
            const openingDate = new Date();
            openingDate.setHours(hours, minutes, 0, 0);
            if (openingDate >= new Date(closingTimeISO)) {
                // Opening time should be before closing time
                alert("Waktu buka harus sebelum waktu tutup!");
                return;
            }
            openingTimeISO = openingDate.toISOString();
        }

        // Use Base64 QRIS directly from preview (already compressed on selection)
        let qrisUrl = qrisPreview;
        if (qrisFile) {
            const {
                data: { user },
            } = await supabase.auth.getUser();
            if (!user) {
                alert("User tidak terdeteksi!");
                return;
            }

            const compressedBlob = await processImage(qrisFile);
            const fileName = `${user.id}/${Date.now()}.jpg`;
            const { error: uploadError } = await supabase.storage
                .from("qris_images")
                .upload(fileName, compressedBlob);

            if (uploadError) {
                console.error("Failed to upload QRIS:", uploadError);
                alert("Gagal upload QRIS!");
                return;
            }

            const {
                data: { publicUrl },
            } = supabase.storage.from("qris_images").getPublicUrl(fileName);
            qrisUrl = publicUrl;
        }

        // ============================
        // Save Payment Info to Profile
        // ============================
        const userId = (await supabase.auth.getUser()).data.user?.id;
        if (userId) {
            const profileUpdate: any = {
                payment_method: paymentMethod,
            };

            if (paymentMethod === "qris") {
                profileUpdate.qris_image_url = qrisUrl;
                profileUpdate.bank_name = null;
                profileUpdate.bank_account_number = null;
                profileUpdate.bank_account_name = null;
            } else {
                profileUpdate.bank_name = bankName;
                profileUpdate.bank_account_number = bankAccountNumber;
                profileUpdate.bank_account_name = bankAccountName;
                // Keep existing QRIS for future use (don't nullify)
            }

            const { error: profileError } = await supabase
                .from("user_profiles")
                .update(profileUpdate)
                .eq("id", userId);

            if (profileError) {
                console.error("Failed to save payment info:", profileError);
                // Don't block room creation, just log the error
            }
        }

        dispatch("submit", {
            name: roomName,
            closingTime: closingTimeISO,
            openingTime: openingTimeISO,
        });
    }
</script>

<div
    class="fixed inset-0 z-50 flex items-end sm:items-center justify-center p-0 sm:p-4 bg-black/50 backdrop-blur-sm"
>
    <div
        class="bg-white w-full max-w-lg rounded-t-3xl sm:rounded-2xl shadow-2xl overflow-hidden animate-in fade-in zoom-in duration-200 max-h-[90vh] flex flex-col"
    >
        <!-- Header -->
        <div
            class="p-4 border-b flex justify-between items-center bg-gray-50 flex-shrink-0"
        >
            <h2 class="text-lg font-bold text-gray-800 flex items-center gap-2">
                <Users size={20} class="text-primary" />
                Buat Group Order
            </h2>
            <button
                on:click={() => dispatch("close")}
                class="text-gray-400 hover:text-gray-600 p-1 rounded-full hover:bg-gray-200"
            >
                <X size={20} />
            </button>
        </div>

        <!-- Scrollable Content -->
        <div class="flex-1 overflow-y-auto p-5 space-y-6">
            <!-- Room Name -->
            <div>
                <label
                    for="room-name"
                    class="block text-sm font-medium text-gray-700 mb-1"
                    >Nama Room</label
                >
                <input
                    id="room-name"
                    type="text"
                    bind:value={roomName}
                    class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                />
            </div>

            <!-- Opening Time (Shop Owners Only) -->
            {#if isShopOwner}
                <div>
                    <label
                        for="opening-time"
                        class="block text-sm font-medium text-gray-700 mb-1"
                    >
                        Waktu Buka Room (Opsional)
                    </label>
                    <input
                        id="opening-time"
                        type="time"
                        bind:value={openingTime}
                        class="w-full px-4 py-3 border-2 border-gray-100 rounded-xl focus:border-primary outline-none text-lg font-bold"
                    />
                    <p class="text-[10px] text-gray-400 mt-2 font-medium">
                        Misalnya jam 7 pagi untuk PO harian. Kosongkan jika
                        ingin buka sekarang.
                    </p>
                </div>
            {/if}

            <!-- Closing Time -->
            <div>
                <div class="flex justify-between items-center mb-2">
                    <label
                        for="fixed-time-input"
                        id="duration-label"
                        class="block text-sm font-medium text-gray-700"
                    >
                        Batas Waktu Order
                    </label>
                    <button
                        type="button"
                        class="text-[10px] font-black uppercase tracking-wider {useFixedTime
                            ? 'text-primary'
                            : 'text-gray-400'}"
                        on:click={() => (useFixedTime = !useFixedTime)}
                    >
                        {useFixedTime ? "Gunakan Durasi" : "Atur Jam Tetap"}
                    </button>
                </div>

                {#if useFixedTime}
                    <div
                        class="animate-in fade-in slide-in-from-top-1 duration-200"
                    >
                        <input
                            id="fixed-time-input"
                            type="time"
                            bind:value={fixedTime}
                            class="w-full px-4 py-3 border-2 border-gray-100 rounded-xl focus:border-primary outline-none text-lg font-bold"
                        />
                        <p class="text-[10px] text-gray-400 mt-2 font-medium">
                            Room akan otomatis ditutup pada jam yang ditentukan.
                        </p>
                    </div>
                {:else}
                    <div
                        class="grid grid-cols-3 gap-2"
                        role="group"
                        aria-labelledby="duration-label"
                    >
                        {#each durationOptions as option}
                            <button
                                type="button"
                                class="px-2 py-2 text-sm border rounded-lg transition-all {duration ===
                                option.value
                                    ? 'bg-primary text-white border-primary font-bold shadow-md'
                                    : 'bg-white text-gray-600 hover:bg-gray-50 border-gray-100'}"
                                on:click={() => (duration = option.value)}
                            >
                                {option.label}
                            </button>
                        {/each}
                    </div>
                {/if}
            </div>

            <!-- Payment Method Selection -->
            <div class="border-t pt-6">
                <h3 class="text-sm font-black text-gray-900 mb-3 uppercase">
                    💰 Metode Pembayaran
                </h3>
                <div class="grid grid-cols-2 gap-3 mb-4">
                    <button
                        type="button"
                        on:click={() => (paymentMethod = "qris")}
                        class="p-4 border-2 rounded-xl transition-all {paymentMethod ===
                        'qris'
                            ? 'border-primary bg-primary/5'
                            : 'border-gray-200 hover:border-gray-300'}"
                    >
                        <CreditCard
                            size={24}
                            class="mx-auto mb-2 {paymentMethod === 'qris'
                                ? 'text-primary'
                                : 'text-gray-400'}"
                        />
                        <p class="text-sm font-bold">QRIS</p>
                    </button>
                    <button
                        type="button"
                        on:click={() => (paymentMethod = "bank_transfer")}
                        class="p-4 border-2 rounded-xl transition-all {paymentMethod ===
                        'bank_transfer'
                            ? 'border-primary bg-primary/5'
                            : 'border-gray-200 hover:border-gray-300'}"
                    >
                        <Building2
                            size={24}
                            class="mx-auto mb-2 {paymentMethod ===
                            'bank_transfer'
                                ? 'text-primary'
                                : 'text-gray-400'}"
                        />
                        <p class="text-sm font-bold">Transfer Bank</p>
                    </button>
                </div>

                <!-- QRIS Upload -->
                {#if paymentMethod === "qris"}
                    <div class="space-y-2">
                        <label
                            class="block text-xs font-bold text-gray-500 uppercase"
                        >
                            Upload QRIS Code <span class="text-red-500">*</span>
                        </label>
                        {#if qrisPreview}
                            <div class="relative">
                                <img
                                    src={qrisPreview}
                                    alt="QRIS Preview"
                                    class="w-full max-w-xs mx-auto rounded-lg border-2 border-dashed border-primary p-2"
                                />
                                <button
                                    type="button"
                                    on:click={() => {
                                        qrisFile = null;
                                        qrisPreview = null;
                                    }}
                                    class="absolute top-2 right-2 bg-red-500 text-white p-1 rounded-full shadow-lg"
                                >
                                    <X size={16} />
                                </button>
                            </div>
                        {:else}
                            <label
                                class="flex flex-col items-center justify-center w-full h-32 border-2 border-dashed border-gray-300 rounded-lg cursor-pointer hover:bg-gray-50"
                            >
                                <Upload size={32} class="text-gray-400 mb-2" />
                                <span class="text-xs text-gray-500 font-medium">
                                    Klik untuk upload QRIS
                                </span>
                                <input
                                    type="file"
                                    accept="image/*"
                                    on:change={handleQrisUpload}
                                    class="hidden"
                                />
                            </label>
                        {/if}
                    </div>
                {/if}

                <!-- Bank Transfer Fields -->
                {#if paymentMethod === "bank_transfer"}
                    <div class="space-y-3">
                        <div>
                            <label
                                class="block text-xs font-bold text-gray-500 uppercase mb-1"
                            >
                                Nama Bank <span class="text-red-500">*</span>
                            </label>
                            <input
                                type="text"
                                bind:value={bankName}
                                placeholder="Contoh: BCA, Mandiri, BNI"
                                class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none"
                            />
                        </div>
                        <div>
                            <label
                                class="block text-xs font-bold text-gray-500 uppercase mb-1"
                            >
                                Nomor Rekening <span class="text-red-500"
                                    >*</span
                                >
                            </label>
                            <input
                                type="text"
                                bind:value={bankAccountNumber}
                                placeholder="1234567890"
                                class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none"
                            />
                        </div>
                        <div>
                            <label
                                class="block text-xs font-bold text-gray-500 uppercase mb-1"
                            >
                                Atas Nama <span class="text-red-500">*</span>
                            </label>
                            <input
                                type="text"
                                bind:value={bankAccountName}
                                placeholder="Nama Pemilik Rekening"
                                class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none"
                            />
                        </div>
                    </div>
                {/if}
            </div>
        </div>

        <!-- Footer -->
        <div
            class="p-4 border-t bg-gray-50 flex justify-end gap-3 flex-shrink-0"
        >
            <button
                class="px-4 py-2 text-gray-600 font-medium hover:bg-gray-200 rounded-lg transition-colors"
                on:click={() => dispatch("close")}
            >
                Batal
            </button>
            <button
                class="px-4 py-2 bg-primary text-white font-bold rounded-lg shadow-md hover:bg-primary/90 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
                on:click={handleSubmit}
                disabled={isLoading}
            >
                {#if isLoading}
                    <div
                        class="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"
                    ></div>
                {/if}
                Buat Room
            </button>
        </div>
    </div>
</div>

<style>
    .animate-in {
        animation: fadeIn 0.2s ease-out;
    }

    @keyframes fadeIn {
        from {
            opacity: 0;
            transform: translateY(-5px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
</style>
