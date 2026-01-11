<script lang="ts">
    export let onBack: () => void = () => window.history.back();
</script>

<div class="legal-page">
    <header class="header bg-primary sticky-top">
        <button class="back-btn" on:click={onBack}>←</button>
        <h1>Syarat dan Ketentuan</h1>
    </header>

    <main class="content">
        <div class="legal-card rounded-lg shadow-soft">
            <p class="updated">Terakhir diperbarui: 11 Januari 2026</p>

            <section>
                <h2>1. Penerimaan Syarat</h2>
                <p>
                    Dengan menggunakan aplikasi OrbFood, Anda setuju untuk
                    terikat dengan Syarat dan Ketentuan ini. Jika Anda tidak
                    setuju dengan ketentuan ini, mohon untuk tidak menggunakan
                    layanan kami.
                </p>
            </section>

            <section>
                <h2>2. Deskripsi Layanan</h2>
                <p>
                    OrbFood adalah platform yang menghubungkan pelanggan dengan
                    toko makanan lokal. Kami menyediakan:
                </p>
                <ul>
                    <li>Katalog menu dari berbagai toko makanan</li>
                    <li>Sistem pemesanan via WhatsApp</li>
                    <li>Riwayat pesanan untuk pengguna terdaftar</li>
                    <li>Dashboard untuk pemilik toko mengelola menu</li>
                </ul>
            </section>

            <section>
                <h2>3. Akun Pengguna</h2>
                <p>Untuk menggunakan fitur lengkap, Anda perlu:</p>
                <ul>
                    <li>Login menggunakan akun Google yang valid</li>
                    <li>Memberikan informasi yang akurat dan terkini</li>
                    <li>Menjaga kerahasiaan akun Anda</li>
                    <li>Bertanggung jawab atas semua aktivitas di akun Anda</li>
                </ul>
            </section>

            <section>
                <h2>4. Ketentuan untuk Pelanggan</h2>
                <p>Sebagai pelanggan, Anda setuju untuk:</p>
                <ul>
                    <li>Memberikan informasi pesanan yang benar dan lengkap</li>
                    <li>
                        Menyelesaikan pembayaran sesuai kesepakatan dengan toko
                    </li>
                    <li>Tidak menyalahgunakan sistem pemesanan</li>
                    <li>Menghormati kebijakan masing-masing toko</li>
                </ul>
            </section>

            <section>
                <h2>5. Ketentuan untuk Pemilik Toko</h2>
                <p>Sebagai pemilik toko yang terdaftar, Anda setuju untuk:</p>
                <ul>
                    <li>Memberikan informasi toko dan menu yang akurat</li>
                    <li>Memastikan ketersediaan menu yang ditampilkan</li>
                    <li>Merespons pesanan dengan tepat waktu</li>
                    <li>Mematuhi peraturan kesehatan dan keamanan pangan</li>
                    <li>Tidak menjual produk ilegal atau berbahaya</li>
                </ul>
            </section>

            <section>
                <h2>6. Transaksi dan Pembayaran</h2>
                <p>
                    OrbFood <strong>tidak memproses pembayaran</strong>. Semua
                    transaksi dilakukan langsung antara pelanggan dan toko
                    melalui WhatsApp atau metode yang disepakati bersama. Kami
                    tidak bertanggung jawab atas:
                </p>
                <ul>
                    <li>Sengketa pembayaran antara pelanggan dan toko</li>
                    <li>Kualitas produk yang diterima</li>
                    <li>Keterlambatan pengiriman atau pickup</li>
                </ul>
            </section>

            <section>
                <h2>7. Pembatalan Pesanan</h2>
                <p>
                    Pembatalan pesanan harus dikomunikasikan langsung dengan
                    toko melalui WhatsApp. Kebijakan pembatalan dan pengembalian
                    dana ditentukan oleh masing-masing toko.
                </p>
            </section>

            <section>
                <h2>8. Konten yang Dilarang</h2>
                <p>Pengguna dilarang untuk:</p>
                <ul>
                    <li>
                        Mengunggah konten yang melanggar hukum atau tidak pantas
                    </li>
                    <li>Menyebarkan informasi palsu atau menyesatkan</li>
                    <li>Melakukan spam atau penyalahgunaan sistem</li>
                    <li>Mengakses sistem secara tidak sah</li>
                </ul>
            </section>

            <section>
                <h2>9. Penghentian Layanan</h2>
                <p>
                    Kami berhak untuk menangguhkan atau menghentikan akun Anda
                    jika melanggar Syarat dan Ketentuan ini, tanpa pemberitahuan
                    sebelumnya.
                </p>
            </section>

            <section>
                <h2>10. Batasan Tanggung Jawab</h2>
                <p>
                    OrbFood disediakan "sebagaimana adanya". Kami tidak
                    menjamin:
                </p>
                <ul>
                    <li>Ketersediaan layanan tanpa gangguan</li>
                    <li>Akurasi informasi dari toko mitra</li>
                    <li>Hasil dari transaksi antara pengguna dan toko</li>
                </ul>
            </section>

            <section>
                <h2>11. Perubahan Ketentuan</h2>
                <p>
                    Kami dapat mengubah Syarat dan Ketentuan ini kapan saja.
                    Penggunaan berkelanjutan setelah perubahan berarti Anda
                    menyetujui ketentuan yang diperbarui.
                </p>
            </section>

            <section>
                <h2>12. Hukum yang Berlaku</h2>
                <p>
                    Syarat dan Ketentuan ini diatur oleh hukum Republik
                    Indonesia. Setiap sengketa akan diselesaikan melalui
                    musyawarah atau pengadilan yang berwenang.
                </p>
            </section>

            <section>
                <h2>13. Hubungi Kami</h2>
                <p>
                    Jika Anda memiliki pertanyaan tentang Syarat dan Ketentuan
                    ini, silakan hubungi:
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
