
Aku jelaskan **layout utama → komponen → ukuran → UX rules**, lalu contoh struktur SvelteKit.

---

# 🖥️ TATA LETAK ADMIN (DESKTOP-FIRST)

## 🎯 Prinsip Desain

* **Sidebar kiri tetap**
* **Konten kanan fleksibel**
* **Tidak bottom nav**
* **Minim animasi**
* **Padat tapi tidak sesak**

---

# 🧱 STRUKTUR LAYOUT UTAMA

```
┌──────────────────────────────────────────┐
│ Topbar (optional)                        │
├───────┬──────────────────────────────────┤
│       │                                  │
│ Side  │   Main Content Area              │
│ bar   │                                  │
│       │                                  │
│       │                                  │
└───────┴──────────────────────────────────┘
```

---

## 📌 UKURAN IDEAL

| Elemen           | Ukuran      |
| ---------------- | ----------- |
| Sidebar          | 240px       |
| Topbar           | 56px        |
| Konten max-width | 1280–1440px |
| Padding konten   | 24px        |

---

# 📂 SIDEBAR ADMIN (KIRI)

### Isi Sidebar

```
Orbefood Admin
──────────────────
🏪 Verifikasi Toko
🏬 Semua Toko
📦 Pesanan
📝 Blog
📊 Statistik
⚙️ Pengaturan
──────────────────
🚪 Logout
```

### UX Rules

* Active state jelas
* Icon + teks
* Bisa collapse (opsional)

---

# 🔝 TOPBAR (OPSIONAL)

Digunakan hanya untuk:

* Nama admin
* Quick search
* Logout (opsional)

```
Admin > Verifikasi Toko
                         👤 Admin
```

---

# 🧩 MAIN CONTENT AREA

## 1️⃣ Dashboard Admin (`/admin`)

### Layout: Card Grid

```
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ 🏪 Toko Baru │ │ 🍔 Total Menu│ │ 📦 Pesanan   │
│     12       │ │    1.240     │ │     56       │
└──────────────┘ └──────────────┘ └──────────────┘

📊 Grafik Pesanan (lebar penuh)
```

---

## 2️⃣ Verifikasi Toko (`/admin/shops/pending`)

### Layout: Table + Action

```
┌────────────────────────────────────────────┐
│ Nama Toko | Lokasi | WA | Aksi             │
├────────────────────────────────────────────┤
│ Bu Sari   | Desa A | ✓  | [Approve][Tolak]│
│ Pak Budi  | Desa B | ✓  | [Approve][Tolak]│
└────────────────────────────────────────────┘
```

### UX

* Klik baris → detail panel kanan / modal
* Approve tanpa reload

---

## 3️⃣ Semua Toko (`/admin/shops`)

```
[🔍 Cari toko]  [Filter: Aktif / Nonaktif]

┌────────────────────────────────────────────┐
│ Toko | Owner | Status | Aktif | Aksi       │
├────────────────────────────────────────────┤
│ ...                                        │
└────────────────────────────────────────────┘
```

---
---

## 5️⃣ Pesanan (`/admin/orders`) – READ ONLY

```
Tanggal | Toko | Total | Status
--------------------------------
08/01   | Bu Sari | 45k | WA Sent
```

---

## 6️⃣ Blog Admin

### Layout: Split

```
┌───────────────┐ ┌────────────────────────┐
│ Daftar Post   │ │ Editor Markdown         │
│               │ │                        │
└───────────────┘ └────────────────────────┘
```

---

# 🎨 WARNA & VISUAL

### Palet Admin

| Elemen     | Warna    |
| ---------- | -------- |
| Background | #F8FAFC  |
| Sidebar    | #0F172A  |
| Text       | #1E293B  |
| Primary    | Biru tua |
| Danger     | Merah    |

---

# 🧠 UX RULES ADMIN (PENTING)

✔️ Semua aksi **jelas & eksplisit**
✔️ Tidak ada swipe
✔️ Konfirmasi untuk aksi destruktif
✔️ Tidak terlalu banyak warna
✔️ Fokus data

---

# 🧩 IMPLEMENTASI DI SVELTEKIT

### `src/routes/admin/+layout.svelte`

* Sidebar
* Topbar
* `<slot />`

---

## 📌 KESIMPULAN

> Admin **bukan user biasa**, jadi:

* Desktop-first
* Sidebar
* Tabel
* Data-driven

Struktur ini:
✔️ Mudah dikembangkan
✔️ Nyaman dipakai lama
✔️ Cocok MVP → scale

---
