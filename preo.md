# Dokumentasi Fitur Group Order - OrbFood

Fitur **Group Order** memungkinkan pengguna untuk memesan makanan bersama-sama dalam satu "Room" di sebuah toko. Fitur ini mempermudah koordinasi pesanan, rekap otomatis, dan verifikasi pembayaran kolektif sebelum dikirim ke pemilik toko melalui WhatsApp.

---

## 1. Peran Pengguna (User Roles)

### A. Room Creator (Pembuat Room)
- Pengguna yang pertama kali membuka room di toko tertentu.
- Bertanggung jawab menentukan nama room dan batas waktu order.
- Memiliki otoritas untuk **memverifikasi bukti transfer** (TF) peserta lain.
- Bertanggung jawab mengirimkan rekap pesanan final ke WhatsApp Toko.

### B. Participant (Peserta)
- Pengguna yang bergabung ke room yang sudah ada.
- Memilih menu dan melakukan checkout secara mandiri.
- **Wajib melakukan Login** untuk mengikuti group order.
- Mengunggah bukti transfer saat checkout jika memilih bayar via transfer.

---

## 2. Alur Proses Pesanan (Process Flow)

### Langkah 1: Inisialisasi Room
1. **Pembuat Room** masuk ke halaman toko dan memilih opsi **"Group Order"**.
2. Mengisi form pembuatan room:
   - **Nama Room**: Misal "Makan Siang Kantor".
   - **Batas Waktu**: Bisa menggunakan durasi (15m, 30m, dll) atau jam tetap (misal 12:00).
3. Room aktif dan muncul di daftar room toko tersebut.

### Langkah 2: Bergabung & Memesan
1. **Peserta** lain masuk ke halaman toko yang sama.
2. Klik tombol **"Joined Group Order"** atau pilih room dari daftar yang aktif.
3. Peserta memilih menu seperti biasa.
4. Saat checkout di halaman keranjang:
   - Status pesanan terdeteksi sebagai bagian dari room tertentu.
   - Peserta mengunggah **Bukti Transfer** (jika ada).
   - Pesanan dikunci (`submitted`) dan masuk ke daftar rekap room.

### Langkah 3: Verifikasi Pembayaran
1. **Pembuat Room** membuka modal **"Ringkasan Pesanan"**.
2. Untuk setiap peserta yang sudah upload TF, Pembuat Room melihat status **"Menunggu Verifikasi"**.
3. Pembuat Room mengecek gambar bukti transfer dan klik tombol **"Verifikasi"**.
4. Status berubah menjadi **"Lunas & Verified"**.

### Langkah 4: Rekap & Order ke Toko
1. Setelah semua (atau sebagian) pesanan diverifikasi, Pembuat Room dapat memilih opsi:
   - **"Hanya Rekap Pesanan Lunas"**: Rekap hanya berisi item yang sudah diverifikasi pembayarannya.
2. Pembuat Room klik **"Kirim Rekap ke WA"**.
3. Sistem membuka WhatsApp dengan teks draft pesanan yang rapi dan terperinci.

### Langkah 5: Finalisasi & Pembersihan
1. Setelah pesanan dikirim, Pembuat Room klik **"Selesaikan & Hapus Bukti TF"**.
2. Sistem menjalankan **Edge Function** untuk:
   - Menghapus semua file bukti transfer dari Storage (demi privasi & efisiensi).
   - Menutup room secara permanen.
   - Menghapus link bukti transfer dari database.

---

## 3. Implementasi Teknis (Technical Highlights)

- **Keamanan (RLS)**: Hanya peserta dalam room yang sama yang dapat melihat rekap pesanan bersama.
- **Efisiensi Storage**: Menggunakan Supabase Storage dengan otomatisasi penghapusan file via Edge Function setelah room selesai.
- **UI Responsif**: Stacking cerdas antara "Sticky Footer Group Order" dan "Cart Bar" agar tidak saling menutupi.
- **PWA Ready**: Mendukung notifikasi instalasi untuk akses cepat di perangkat mobile.

---

*Dokumentasi ini dibuat untuk memandu pengembangan dan penggunaan fitur Group Order di platform OrbFood.*
