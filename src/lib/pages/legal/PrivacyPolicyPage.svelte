<script lang="ts">
    export let onBack: () => void = () => window.history.back();
</script>

<div class="legal-page">
    <header class="header bg-primary sticky-top">
        <button class="back-btn" on:click={onBack}>←</button>
        <h1>Kebijakan Privasi</h1>
    </header>

    <main class="content">
        <div class="legal-card rounded-lg shadow-soft">
            <p class="updated">Terakhir diperbarui: 11 Januari 2026</p>

            <section>
                <h2>1. Pendahuluan</h2>
                <p>
                    OrbFood ("kami", "kita", atau "aplikasi") berkomitmen untuk
                    melindungi privasi pengguna. Kebijakan Privasi ini
                    menjelaskan bagaimana kami mengumpulkan, menggunakan, dan
                    melindungi informasi pribadi Anda saat menggunakan layanan
                    kami.
                </p>
            </section>

            <section>
                <h2>2. Data yang Kami Kumpulkan</h2>
                <p>Kami dapat mengumpulkan informasi berikut:</p>
                <ul>
                    <li>
                        <strong>Informasi Akun:</strong> Nama, alamat email, dan
                        foto profil dari akun Google Anda
                    </li>
                    <li>
                        <strong>Informasi Toko:</strong> Nama toko, alamat, nomor
                        WhatsApp (untuk pemilik toko)
                    </li>
                    <li>
                        <strong>Riwayat Pesanan:</strong> Detail pesanan, tanggal,
                        dan total pembayaran
                    </li>
                    <li>
                        <strong>Lokasi:</strong> Desa yang Anda pilih untuk filter
                        toko terdekat
                    </li>
                </ul>
            </section>

            <section>
                <h2>3. Penggunaan Data</h2>
                <p>Data Anda digunakan untuk:</p>
                <ul>
                    <li>
                        Memproses dan mengirim pesanan ke toko melalui WhatsApp
                    </li>
                    <li>Menyimpan riwayat pesanan Anda</li>
                    <li>
                        Menampilkan toko dan menu yang relevan berdasarkan
                        lokasi
                    </li>
                    <li>Memverifikasi pendaftaran toko baru</li>
                    <li>Menghubungi Anda jika diperlukan terkait pesanan</li>
                </ul>
            </section>

            <section>
                <h2>4. Penyimpanan Data</h2>
                <p>
                    Data Anda disimpan dengan aman menggunakan layanan Supabase
                    yang berlokasi di server cloud. Kami menerapkan
                    langkah-langkah keamanan standar industri untuk melindungi
                    data Anda dari akses tidak sah.
                </p>
            </section>

            <section>
                <h2>5. Berbagi Data</h2>
                <p>
                    Kami <strong>tidak menjual</strong> data pribadi Anda. Data hanya
                    dibagikan kepada:
                </p>
                <ul>
                    <li>
                        Toko yang menerima pesanan Anda (nama dan detail
                        pesanan)
                    </li>
                    <li>
                        Layanan pihak ketiga yang diperlukan (Google Auth,
                        Supabase)
                    </li>
                </ul>
            </section>

            <section>
                <h2>6. Hak Pengguna</h2>
                <p>Anda berhak untuk:</p>
                <ul>
                    <li>Mengakses data pribadi Anda</li>
                    <li>Meminta koreksi data yang tidak akurat</li>
                    <li>Meminta penghapusan akun dan data Anda</li>
                    <li>Menarik persetujuan kapan saja</li>
                </ul>
            </section>

            <section>
                <h2>7. Cookie dan Penyimpanan Lokal</h2>
                <p>
                    Kami menggunakan sessionStorage dan localStorage untuk
                    menyimpan preferensi Anda (seperti filter desa) dan cache
                    data untuk pengalaman yang lebih cepat. Data ini hanya
                    disimpan di perangkat Anda.
                </p>
            </section>

            <section>
                <h2>8. Perubahan Kebijakan</h2>
                <p>
                    Kami dapat memperbarui Kebijakan Privasi ini dari waktu ke
                    waktu. Perubahan signifikan akan diberitahukan melalui
                    aplikasi.
                </p>
            </section>

            <section>
                <h2>9. Hubungi Kami</h2>
                <p>
                    Jika Anda memiliki pertanyaan tentang Kebijakan Privasi ini,
                    silakan hubungi kami di:
                </p>
                <p class="contact">
                    <strong>Email:</strong> orbefood3@gmail.com<br />
                </p>
            </section>
        </div>
    </main>
</div>

<style>
    .legal-page {
        display: flex;
        flex-direction: column;
        flex: 1;
        background: var(--bg-soft);
    }

    .header {
        position: sticky;
        top: 0;
        z-index: 10;
        display: flex;
        align-items: center;
        padding: 12px 16px;
        color: white;
        gap: 16px;
    }

    .back-btn {
        background: none;
        color: white;
        font-size: 24px;
        padding: 0;
    }

    .header h1 {
        margin: 0;
        font-size: 18px;
    }

    .content {
        padding: 20px;
        padding-bottom: 60px;
    }

    .legal-card {
        background: white;
        padding: 24px;
    }

    .updated {
        font-size: 12px;
        color: var(--text-hint);
        margin-bottom: 24px;
        font-style: italic;
    }

    section {
        margin-bottom: 24px;
    }

    section:last-child {
        margin-bottom: 0;
    }

    h2 {
        font-size: 16px;
        font-weight: 700;
        color: var(--primary);
        margin: 0 0 12px 0;
    }

    p {
        font-size: 14px;
        line-height: 1.6;
        color: var(--text-main);
        margin: 0 0 12px 0;
    }

    ul {
        margin: 0;
        padding-left: 20px;
    }

    li {
        font-size: 14px;
        line-height: 1.8;
        color: var(--text-main);
    }

    .contact {
        background: var(--bg-soft);
        padding: 16px;
        border-radius: 8px;
        margin: 0;
    }
</style>
