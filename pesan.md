
# 🏠 HOME – ALUR & UI/UX MENU



## 2️⃣ MENU REKOMENDASI (CARD PORTRAIT – SLIDER)

📍 **Letak:** tepat di bawah header
📍 **Tujuan:** menu unggulan / promo / toko favorit

### 🧱 Bentuk Card (Portrait)

```
┌───────────────┐
│   [ Gambar ]  │
│               │
│ Nama Menu     │
│ Nama Toko     │
│ Rp 15.000     │
│ [+ Tambah]    │
└───────────────┘
```

### 🧠 UX Behavior

* Swipe horizontal (drag)
* Auto snap per card
* Tombol **+ Tambah** langsung masuk keranjang
* Tidak pindah halaman

---

## 3️⃣ MENU LAINNYA (CARD LANDSCAPE – LIST)

📍 **Di bawah slider rekomendasi**

### 🧱 Card Landscape

```
┌───────────────┐
│ [IMG]  Nama   │
│        Toko   │
│        Rp     │
│        [+]    │
└───────────────┘
```

### UX Rules

* Satu menu = satu baris
* Klik card → detail menu
* Klik [+] → langsung masuk keranjang

---

## 🛒 KERANJANG (BOTTOM FIXED)

> ⚠️ **Ini penting & tepat**: user TIDAK perlu scroll ke bawah

### 🔒 Kondisi

* Muncul **HANYA jika ada item**
* Fixed bottom (sticky)

### UI

```
┌────────────────────────┐
│ 🛒 3 item | Rp 45.000  │  →  Lihat Keranjang
└────────────────────────┘
```

---

## 4️⃣ HALAMAN KERANJANG

### 📄 Struktur

* Nama Toko
* List menu:

  * Nama
  * Qty (+ / -)
  * Harga
* Catatan pesanan (textarea)
* Total harga

---

### 🔘 CTA BESAR (BOTTOM FIXED)

```
┌────────────────────────┐
│ PESAN VIA WHATSAPP     │
└────────────────────────┘
```

---

## 5️⃣ ALUR CHECKOUT → WHATSAPP

### 🔄 Saat klik **Pesan via WhatsApp**

#### Step 1 – Validasi ringan

* Nama pembeli (wajib)
* Catatan (opsional)
* Lokasi ❌ (belum wajib)

---

#### Step 2 – Generate Draft WA (Otomatis)

📨 **Format pesan otomatis**

```
Halo! Saya Irfan.

Saya mau pesan:
- Nasi Goreng (2) - Rp 30.000
- Es Teh (1) - Rp 5.000

Total: Rp 35.000

Catatan:
Pedas sedang

Lokasi saya akan saya kirimkan setelah ini.
```

➡️ Redirect ke:

```
https://wa.me/628xxx?text=ENCODED_MESSAGE
```

---

#### Step 3 – Share Lokasi Manual

Setelah WA terbuka:

* User klik 📎 → Location → Share Live Location / Current

🧠 **Kenapa ini bagus?**

* Lebih natural buat user desa
* Tidak ribet izin lokasi browser
* Sesuai kebiasaan WA

---

## 🔐 LOGIN (OPSIONAL & HALUS)

### Saat checkout:

Popup ringan:

> “Masuk agar pesanan tersimpan dan bisa beri ulasan”

Button:

* Login Google
* Lewati (tetap bisa WA)

🧠 UX:

* Tidak memaksa
* Tapi memberi **value jelas**
tapi pastikan jika user sudah login sebelumnya tak muncul pop up ini dan fiturnya yang terbuka akarena loginnya berfunsgsi dengan benar seperti pesanan terimpan ke historyu dan lainnya
---

## 🔁 ALUR RINGKAS USER (FLOW)

```
HOME
 ↓
Lihat Menu
 ↓
Tambah ke Keranjang
 ↓
Keranjang (Bottom Fixed)
 ↓
Pesan via WhatsApp
 ↓
Chat WA terbuka
 ↓
Share Lokasi
 ↓
Selesai
```
