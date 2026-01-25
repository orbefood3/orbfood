
## 1️⃣ ganti halaman paforit jadi BLOG (Konten / Promo / Edukasi)

### 🎯 Tujuan

* SEO
* Edukasi UMKM & user
* Promo makanan / event
* Tidak ribet seperti media besar

---

### 📱 Struktur UI (Mobile First)

**Header**

* Logo (biru tua)
* Icon search
* Icon akun (login / avatar)

---

**Hero Section (opsional)**

* Card lebar
* Gambar makanan / promo
* Judul besar
* CTA: *“Lihat Menu”*

---

**List Artikel (Card-based)**
Setiap card:

* Thumbnail (rounded)
* Judul (max 2 baris)
* Excerpt singkat
* Badge kategori (Promo / Cerita Toko / Tips)

🟦 Warna badge: orange
🟦 Background card: putih / abu muda

---

**Detail Blog**

* Cover image full width
* Judul besar
* Meta (tanggal, kategori)
* Konten markdown
* CTA bawah:

  * “Pesan makanan sekarang”
  * “Lihat toko terkait”

---

💡 **UX decision**

* Blog **tanpa login**
* CTA selalu arahkan ke pemesanan

---

## 2️⃣ UI/UX HALAMAN PESANAN (RIWAYAT PESANAN)

> ⚠️ **WAJIB LOGIN**
> Kalau belum login → tampilkan **empty state persuasif**

---

### 🚪 Jika BELUM LOGIN

**Empty State**

* Ilustrasi makanan
* Teks:

  > “Masuk untuk melihat riwayat pesanan dan memberi ulasan”
* Button:

  * Login Google
  * Login WhatsApp

---

### 📦 Jika SUDAH LOGIN

**Tab / Filter**

* Semua
* Diproses
* Selesai
* Dibatalkan

---

**List Pesanan (Card)**
Setiap card:

* Nama Toko
* Status (badge warna):

  * 🟡 Diproses
  * 🟢 Selesai
  * 🔴 Batal
* Tanggal & Jam
* Total harga
* CTA:

  * “Lihat Detail”
  * “Pesan Lagi”

---

🧠 UX penting:

* Card **clickable seluruhnya**
* Status langsung terlihat (tanpa buka detail)

---

## 3️⃣ UI/UX DETAIL PESANAN

### 📄 Struktur Halaman

**Header**

* Tombol back
* Judul: “Detail Pesanan”

---

**Info Toko**

* Logo toko
* Nama toko
* Alamat singkat
* Tombol: Chat / Hubungi

---

**Status Timeline (simple)**

* Pesanan dibuat
* Diproses
* Siap / Dikirim
* Selesai

(tidak serumit ShopeeFood)

---

**Daftar Menu**

* Nama menu
* Qty
* Harga
* Catatan (jika ada)

---

**Ringkasan Harga**

* Subtotal
* Ongkir
* Total (bold)

---

**Action Area**
Jika status = **SELESAI**:

* ⭐ “Beri Review”
* 🛒 “Pesan Lagi”

Jika status ≠ selesai:

* Info saja (tidak ada review)

---

🔒 **Rule UX penting**

> Review **HANYA BISA** dari pesanan di history yang terkonfirmasi toko telah di kirim
> Ini bikin sistem kamu rapi & kredibel

---

## 4️⃣ UI/UX HALAMAN AKUN (PROFILE)

### 🧑‍💼 Header Akun

* Avatar
* Nama user
* Nomor / Email
* Status login (Google / WA)

---

### 📋 Menu Akun (List Icon)

1. **Riwayat Pesanan**
2. **Alamat Pengiriman**
3. **Ulasan Saya**
4. **Bantuan**
5. **Tentang Aplikasi**
6. **Keluar**

---

### 📍 UX Catatan

* Semua menu **1 kolom**
* Icon sederhana (lucide / heroicons)
* Touch-friendly

---

