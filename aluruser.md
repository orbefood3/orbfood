

# 🎯 PRINSIP UTAMA UI/UX orbefood

> **Pesan dulu → Login belakangan (kalau perlu)**

❗ Jangan paksa login di awal
❗ Login = *value*, bukan *barrier*

---

## 1️⃣ ALUR BESAR USER (SIMPEL & MASUK AKAL)

```text
Buka web
↓
Browse toko & menu (tanpa login)
↓
Add to cart
↓
Checkout (WhatsApp)
↓
(Opsional) Login agar pesanan tersimpan & bisa review

## 2️⃣ STRUKTUR HALAMAN UTAMA (ShopeeFood-like)

### 🏠 Home

* Search bar besar (sticky)
* Kategori (horizontal scroll)
* List toko (card besar)

**Card Toko**

* Nama toko
* Status: 🟢 Buka / 🔴 Tutup
* Estimasi harga
* Button: `Lihat Menu`

👉 **Tidak ada login button mencolok di sini**

---

### 🏪 Halaman Toko

Mirip ShopeeFood versi ringan:

**Header**

* Nama toko
* Status buka
* Lokasi singkat

**Menu List**

* Card menu

  * Foto
  * Nama
  * Harga
  * `+ Tambah`

**Bottom Cart Bar (sticky)**

> `🛒 3 item | Rp 25.000 | Lihat Keranjang`

---

## 3️⃣ CART & CHECKOUT (TANPA LOGIN)

### 🛒 Keranjang (Bottom Sheet / Page)

* List item
* Qty + / -
* Catatan per pesanan

### Tombol utama:

```text
Pesan via WhatsApp
m
```
saat klik pesan via whatsapp akan muncul popup login
setelah itu akan diarahkan ke whatsapp
lalu sudah dengan draft nama dari akun dan pesanan yang sudah diisi


---login dengan intergrasi google

## 4️⃣ MOMEN LOGIN YANG TEPAT (KRUSIAL)

### 🎯 MOMEN #1 — SAAT CHECKOUT

Popup ringan (bukan full page):

> 🔐 **Simpan pesanan kamu?**
> Login agar:
>
> * Pesanan masuk riwayat
> * Bisa review makanan
> * Lebih cepat pesan ulang
>
> [Login Sekarang] 

--setelkah user login tak perlu ada po up ini lagi

### 🎯 MOMEN #2 — SAAT AKSES HISTORY / REVIEW

Kalau user klik:

* `Riwayat Pesanan`
* `Tulis Review`

> “Untuk melihat riwayat & memberi review, silakan login dulu.”

---

## 5️⃣ LOGIN FLOW (SANGAT SEDERHANA)



 Google 

👉 Setelah login:

* Cart **tidak hilang**
* Jika checkout sebelumnya → disimpan sebagai history

---

## 6️⃣ RIWAYAT PESANAN (LOGIN USER)

### 📜 Order History Page

List card:

* Nama toko
* Tanggal
* Total
* Status: `Selesai`

**Aksi:**

* 🔁 Pesan Lagi
* ✍️ Tulis Review

---

## 7️⃣ REVIEW FLOW (WAJIB DARI HISTORY)

❗ **Review TIDAK bisa tanpa history**

Flow:

```text
History
→ Pilih pesanan
→ Tulis review menu yang dibeli
```

**Form Review**

* Rating ⭐ 1–5
* Komentar singkat
* Optional foto

👉 Ini bikin review **lebih terpercaya** & anti spam.

---

## 8️⃣ NAVIGATION (ShopeeFood-like tapi minimal)

### Bottom Navigation (Mobile)

```
Home |  Favorit |  Pesanan |  Akun
```

* **Home** → bebas login
* **Favorit** → minta login jika kosong
* **Pesanan** → login required
* **Akun** → login/register

---


### Komponen

* Card besar
* Radius membulat
* Button besar & jelas
* Font readable (Inter / Poppins)
