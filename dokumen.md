# Dokumentasi Aplikasi Web OrbFood

Dokumentasi ini menjelaskan tumpukan teknologi (tech stack), alat (tools), pustaka (libraries), dan kerangka kerja (framework) yang digunakan dalam pengembangan aplikasi ini.

## 🚀 Tech Stack Utama

Aplikasi ini dibangun dengan teknologi modern yang berfokus pada kecepatan, skalabilitas, dan pengalaman pengguna yang luar biasa.

### ⚙️ Frontend & Framework
- **[Svelte 4](https://svelte.dev/)**: Framework utama yang digunakan untuk membangun antarmuka pengguna (UI). Svelte dipilih karena performanya yang tinggi dengan melakukan kompilasi koda di waktu build.
- **[Vite](https://vitejs.dev/)**: Tool build yang sangat cepat untuk pengembangan frontend modern.
- **[TypeScript](https://www.typescriptlang.org/)**: Digunakan untuk keamanan tipe data (type safety), membuat koda lebih stabil dan mudah dipelihara.

### 🎨 Styling & Desain
- **[Tailwind CSS 4](https://tailwindcss.com/)**: Framework CSS utility-first yang digunakan untuk styling yang cepat dan responsif.
- **[Lucide Svelte](https://lucide.dev/)**: Pustaka ikon yang bersih dan modern untuk Svelte.

### 🗄️ Backend & Database
- **[Supabase](https://supabase.com/)**: Platform Backend-as-a-Service (BaaS) yang menyediakan:
  - **PostgreSQL**: Database relasional utama.
  - **Authentication**: Manajemen user dan OAuth (Google Auth).
  - **Storage**: Penyimpanan file (gambar menu, profil, dll).
  - **Realtime**: Update data secara langsung tanpa refresh.

## 📂 Struktur Proyek

Aplikasi ini menggunakan struktur yang terorganisir untuk mempermudah pengembangan:

- `/src/lib/components/`: Berisi komponen UI yang dapat digunakan kembali (cards, navigation, ui elements).
- `/src/lib/pages/`: Berisi halaman aplikasi yang dibagi berdasarkan peran:
  - `user/`: Halaman untuk pembeli (Home, Store, Cart, Orders, Profile).
  - `shop/`: Dashboard untuk pemilik toko/mitra.
  - `admin/`: Panel kontrol untuk administrator sistem.
  - `legal/`: Halaman kebijakan privasi dan ketentuan layanan.
- `/src/lib/services/`: Inisialisasi layanan eksternal seperti client Supabase.
- `/src/lib/stores/`: Manajemen state aplikasi menggunakan Svelte stores.

## 🛠️ Alat Pengembangan (Dev Tools)
- **Node.js & NPM**: Lingkungan eksekusi Javascript dan manajemen paket.
- **PostCSS & Autoprefixer**: Untuk pemrosesan CSS otomatis.
- **Svelte-Check**: Alat untuk pengecekan tipe dan diagnostik Svelte.

## ✨ Fitur Utama
1. **Multi-Role System**: Mendukung peran User, Shop, dan Admin dalam satu aplikasi.
2. **Realtime Ordering**: Proses pemesanan yang responsif.
3. **Shop Management**: Pemilik toko dapat mengelola menu, kategori, dan pesanan sendiri.
4. **Blog System**: Fitur artikel untuk berita atau promosi.
5. **Modern UI**: Desain yang bersih, responsif, dan mobile-first.

---
*Dibuat untuk memberikan gambaran teknis aplikasi OrbFood.*
