

# 🛡️ ADMIN ORBEFOOD — KONTEN & UI/UX LENGKAP

## 🌐 GLOBAL ADMIN LAYOUT

### Desktop

* **Sidebar kiri (240px)** – fixed
* **Main content kanan** – scroll
* **Max width konten**: 1280px
* **Padding**: 24px

### Mobile

* Sidebar ➜ **Drawer (slide dari kiri)**
* Hamburger menu
* Header sticky

### Tech UI

* `@tailwindcss/forms`
* `lucide-svelte` (icon)
* `clsx` / `cva` (class management)
* Headless UI pattern (tanpa library berat)

---

# 1️⃣ DASHBOARD ADMIN (`/admin`)

### 🎯 Tujuan

Overview cepat kondisi platform

### Konten

* Total Toko
* Toko Menunggu Verifikasi
* Total Menu
* Total Pesanan (bulan ini)

### UI Desktop

```
┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│🏪 Toko   │ │⏳ Pending │ │🍔 Menu   │ │📦 Order  │
│ 120      │ │ 5        │ │ 1.240    │ │ 450      │
└──────────┘ └──────────┘ └──────────┘ └──────────┘

📊 Grafik Toko Baru / Pesanan
```

### Mobile

* Cards 1 kolom
* Grafik opsional (collapse)

### Tech Tambahan

* `recharts` (opsional)
* Skeleton loading

---

# 2️⃣ VERIFIKASI TOKO (`/admin/shops/pending`)

### 🎯 Tujuan

Approve / reject toko baru

### Konten

* Nama toko
* Lokasi
* WhatsApp
* Jam operasional
* Status verifikasi

### UI Desktop

```
┌──────────────────────────────────────────┐
│ 🍜 Warung Bu Sari                         │
│ 📍 Desa Sukamaju                          │
│ 📞 08xxxx                                │
│ ⏰ 08.00 - 20.00                         │
│ [ Approve ]   [ Tolak ]                  │
└──────────────────────────────────────────┘
```

### UX

* Klik card → modal detail
* Approve 1 klik
* Toast sukses

### Mobile

* Card full width
* Tombol besar

### Tech

* Modal Headless
* Toast notification

---

# 3️⃣ SEMUA TOKO (`/admin/shops`)

### 🎯 Tujuan

Monitoring & kontrol toko

### Konten

* Nama toko
* Owner
* Status aktif
* Total menu
* Total view

### UI Desktop (Table ringan)

```
Nama Toko | Owner | Menu | View | Status | Aksi
------------------------------------------------
Bu Sari   | Irfan | 12   | 120  | 🟢     | dengan icon
```

### Aksinya

* Nonaktifkan toko
* Aktifkan ulang
* view
### Mobile

* List card
* Aksi via dropdown

### Tech

* `IntersectionObserver` (lazy load)

---

# 4️⃣ PESANAN (MONITOR) di dalam toko di halaman semua toko
### 🎯 Tujuan

Monitoring aktivitas platform

### Konten

* Tanggal
* Toko
* Total harga
* Status (WA sent)

### UI Desktop

```
Tanggal | Toko | Total | Status
--------------------------------
08/01   | Bu Sari | 45k | ✔️
```

### UX

* Read-only
* Filter tanggal

### Mobile

* Stack list

### Tech

* Date range picker (opsional)

---

# 5️⃣ BLOG ADMIN (`/admin/blog`)

### 🎯 Tujuan

Konten branding & SEO

### Konten

* Judul
* Status
* Kategori
* Publish date

### UI Desktop (Split view)

```
[ Daftar Artikel ] | [ Editor Markdown ]
```

### UX

* Auto save
* Preview markdown

### Mobile

* Full editor
* Daftar collapse

### Tech

* Markdown editor ringan (`mdsvex` / `simplemde`)

---

# 6️⃣ STATISTIK (`/admin/stats`)

### 🎯 Tujuan

Insight pertumbuhan

### Konten

* Toko baru / bulan
* Pesanan / hari
* View toko

### UI Desktop

* Grafik line
* Card summary

### Mobile

* Card only
* Grafik optional

### Tech

* Chart ringan (optional)

---

# 7️⃣ PENGATURAN (`/admin/settings`)

### 🎯 Tujuan

Kontrol platform

### Konten

* Banner pengumuman
* Kontak admin
* Mode maintenance

### UI

```
Judul Pengumuman
[ textarea ]

[ SIMPAN ]
```

### Mobile

* Sama, vertikal

---

# 🔐 UX RULES ADMIN (WAJIB)

✔️ Semua aksi destructive → konfirmasi
✔️ Toast feedback
✔️ Tidak ada gesture tersembunyi
✔️ Loading state jelas

---

# 🎨 WARNA ADMIN

| Elemen     | Warna      |
| ---------- | ---------- |
| Sidebar    | Biru tua   |
| Background | Abu terang |
| Primary    | Biru       |
| Danger     | Merah      |
| Success    | Hijau      |

---

# 🧠 REKOMENDASI TECH UI TAMBAHAN (OPTIONAL)

| Kebutuhan        | Tool                |
| ---------------- | ------------------- |
| Modal & dropdown | Headless UI pattern |
| Icon             | lucide-svelte       |
| Toast            | Custom simple       |
| Form             | tailwind forms      |
| Chart            | recharts            |

---
