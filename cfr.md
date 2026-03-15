# CFR - Analisa Halaman dan Fitur Project OrbFood

Project ini adalah SPA Svelte (hash-based routing), jadi perpindahan halaman utama diatur dari state aplikasi dan `window.location.hash`.

## 1) Halaman User/Public

### 1.1 Beranda (`home`)
- Menampilkan rekomendasi toko.
- Menampilkan daftar menu lintas toko.
- Pencarian toko dan menu.
- Filter desa (disimpan ke localStorage).
- Filter khusus toko dengan delivery.
- Pagination/load-more menu.

Referensi: `src/lib/pages/user/HomePage.svelte`

### 1.2 Detail Toko (`#/shop/:slug`)
- Menampilkan profil toko (logo, banner, deskripsi, status buka/tutup, jam operasional).
- Menampilkan daftar menu toko.
- Aksi sosial: Instagram, TikTok, Google Maps.
- Tombol chat WhatsApp toko.
- Share link toko.
- Integrasi Group Order (lihat/join/buat room).
- Integrasi cart bar dan modal detail menu.

Referensi: `src/lib/pages/user/StorePage.svelte`

### 1.3 Keranjang
- List item keranjang + quantity control.
- Edit item/customization dari keranjang.
- Checkout normal (create order + kirim format pesan ke WhatsApp toko).
- Checkout Group Order.
- Upload bukti transfer untuk peserta Group Order.

Referensi: `src/lib/pages/user/CartPage.svelte`

### 1.4 Blog (`blog`) dan Detail Artikel (`#/blog/:slug`)
- List artikel, kategori, pencarian.
- Featured article.
- Pagination/load-more artikel.
- Halaman detail artikel + share.

Referensi:
- `src/lib/pages/user/BlogPage.svelte`
- `src/lib/pages/user/BlogDetailPage.svelte`

### 1.5 Riwayat Pesanan (`pesanan`)
- Menampilkan histori pesanan user.
- Status order (diproses/selesai/batal/pending).
- Aksi salin draft rekap untuk pesanan Group Order.
- Jika belum login: login gate + persetujuan privacy/terms.

Referensi: `src/lib/pages/user/OrdersPage.svelte`

### 1.6 Akun (`akun`)
- Menampilkan data profil user.
- Logout.
- Navigasi ke riwayat pesanan.
- Akses tombol "Buka Toko" untuk user biasa.

Referensi: `src/lib/pages/user/ProfilePage.svelte`

### 1.7 Pengajuan Buka Toko
- Form pengajuan toko baru.
- Persetujuan Privacy Policy dan Terms.
- Data masuk sebagai toko pending verifikasi admin.

Referensi: `src/lib/pages/user/BukaTokoPage.svelte`

### 1.8 Halaman Legal
- `#/privacy`: Kebijakan Privasi.
- `#/terms`: Syarat dan Ketentuan.

Referensi:
- `src/lib/pages/legal/PrivacyPolicyPage.svelte`
- `src/lib/pages/legal/TermsOfServicePage.svelte`

## 2) Halaman Shop Owner (Role `shop`)

### 2.1 Dashboard Toko
Tab utama:
- Dashboard ringkasan toko.
- Menu Saya.
- Pesanan Masuk.
- Group Order.
- Pengaturan Toko.

Tambahan:
- Share link toko.
- Menampilkan pengumuman dari blog berstatus announcement.

Referensi: `src/lib/pages/shop/ShopDashboard.svelte`

### 2.2 Menu Saya
- CRUD menu.
- Upload gambar menu.
- Search menu.
- Infinite scroll/pagination.
- Dukungan menu package + option groups + option items (custom menu).

Referensi: `src/lib/pages/shop/ShopMenus.svelte`

### 2.3 Pesanan Masuk
- Menampilkan order yang masuk untuk toko.
- Update status pesanan (complete/cancel).

Referensi: `src/lib/pages/admin/AdminOrders.svelte` (dipakai ulang untuk shop)

### 2.4 Group Order Toko
- Melihat daftar room Group Order untuk toko.
- Membuat room baru.
- Membuka rekap peserta.

Referensi: `src/lib/pages/shop/ShopGroupOrders.svelte`

### 2.5 Pengaturan Toko
- Edit informasi toko (nama, deskripsi, kategori, alamat, desa, kontak).
- Kelola link sosial/media.
- Atur jam operasional.
- Toggle delivery/open status.
- Upload logo/banner toko.

Referensi: `src/lib/pages/shop/ShopSettings.svelte`

## 3) Halaman Admin (Role `admin`)

### 3.1 Dashboard Admin
Tab utama:
- Dashboard statistik.
- Verifikasi toko.
- Semua toko.
- Pengguna.
- Manajemen desa.
- Blog.
- Pengaturan platform.

Referensi: `src/lib/pages/admin/AdminDashboard.svelte`

### 3.2 Dashboard Statistik
- Total user, toko, menu, order.
- Toko aktif/pending.
- Total interaksi (WA taps + maps taps).

Referensi: `src/lib/pages/admin/AdminStats.svelte`

### 3.3 Verifikasi Toko
- Approve pengajuan toko.
- Reject pengajuan toko.
- Saat approve, role user owner di-upgrade ke `shop`.

Referensi: `src/lib/pages/admin/AdminDashboard.svelte`

### 3.4 Manajemen Semua Toko
- Search + pagination.
- Lihat detail toko.
- Aktif/nonaktif toko.
- Hapus toko.

Referensi: `src/lib/pages/admin/AdminShops.svelte`

### 3.5 Manajemen Pengguna
- Search + pagination user profiles.
- Ubah role (`user`, `shop`, `admin`).
- Hapus profil user.

Referensi: `src/lib/pages/admin/AdminUsers.svelte`

### 3.6 Manajemen Desa
- CRUD data desa.

Referensi: `src/lib/pages/admin/AdminVillages.svelte`

### 3.7 Blog & Artikel
- CRUD post blog.
- Status post: `draft`, `published`, `announcement`.
- Upload cover image.

Referensi: `src/lib/pages/admin/AdminBlog.svelte`

### 3.8 Pengaturan Platform
- Kelola nama platform.
- WhatsApp admin.
- Jam operasional platform.
- Teks banner pengumuman.

Referensi: `src/lib/pages/admin/AdminSettings.svelte`

## 4) Fitur Global Penting

- Auth Google via Supabase + role-based dashboard.
- Hash routing untuk deep link:
  - `#/shop/:slug`
  - `#/blog/:slug`
  - `#/group/:code`
  - `#/privacy`
  - `#/terms`
- Cart store dengan dukungan custom menu/options.
- Group order store dengan persistence localStorage.
- Realtime update rekap group order (creator view).
- Upload media:
  - Cloudinary untuk gambar konten/menu/toko.
  - Supabase Storage untuk QRIS dan bukti transfer.
- PWA install prompt (`beforeinstallprompt`).

## 5) Entry dan Navigasi Utama

- Entry app: `src/main.ts`
- Orkestrasi halaman + role switching + hash handler: `src/App.svelte`
- Bottom nav user: `src/lib/components/navigation/BottomNav.svelte`
- Cart bar: `src/lib/components/navigation/CartBar.svelte`
