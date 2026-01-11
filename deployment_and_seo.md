# Panduan Deployment & Optimasi SEO OrbFood

Dokumen ini menjelaskan cara melakukan deployment ke Vercel serta strategi untuk meningkatkan visibilitas toko agar mudah ditemukan oleh pelanggan.

---

## 🚀 Deployment ke Vercel

OrbFood dibangun dengan **Svelte + Vite** dan menggunakan **Supabase** sebagai backend. Ikuti langkah berikut untuk deploy ke Vercel:

### 1. Persiapan Repositori
Pastikan kode Anda sudah di-push ke GitHub, GitLab, atau Bitbucket.

### 2. Hubungkan ke Vercel
1. Masuk ke [Vercel Dashboard](https://vercel.com/dashboard).
2. Klik **"Add New"** -> **"Project"**.
3. Impor repositori OrbFood Anda.

### 3. Konfigurasi Environment Variables
Vercel membutuhkan kunci API Supabase agar aplikasi bisa berjalan. Tambahkan variabel berikut di menu **Environment Variables**:

| Key | Value |
| :--- | :--- |
| `VITE_SUPABASE_URL` | URL project Supabase Anda |
| `VITE_SUPABASE_ANON_KEY` | Anon Key project Supabase Anda |

### 4. Build Settings

### 5. Google Auth Setup
Untuk mengaktifkan login dengan Google, ikuti langkah-langkah berikut:
1. **Aktifkan Google Provider di Supabase**:
   - Buka Supabase Dashboard Anda, navigasi ke **Authentication** -> **Providers**.
   - Aktifkan **Google** dan masukkan `Client ID` serta `Client Secret` dari Google Cloud Console Anda.
   - Tambahkan `https://<your-supabase-project-id>.supabase.co/auth/v1/callback` sebagai `Authorized redirect URIs` di Google Cloud Console.
2. **Tambahkan Environment Variables di Vercel**:
   - `VITE_GOOGLE_CLIENT_ID` | Client ID dari Google Cloud Console Anda
   - `VITE_GOOGLE_CLIENT_SECRET` | Client Secret dari Google Cloud Console Anda

---

## 🔍 Strategi Pencarian & SEO Area

OrbFood memiliki fitur pencarian berbasis area (Desa/Kelurahan) yang sangat kuat. Agar toko lebih mudah ditemukan:

### 1. Optimasi Nama & Deskripsi Toko
- **Gunakan Kata Kunci Lokal**: Masukkan nama desa atau kelurahan di dalam deskripsi toko. Contoh: *"Warung Bakso terenak di Desa Genteng..."*
- **Kategori yang Jelas**: Pastikan memilih kategori yang tepat (e.g., Kuliner, Minuman) karena user sering memfilter berdasarkan kategori.

- **Indexable**: Link ini dapat di-index oleh mesin pencari karena menggunakan routing yang konsisten.

### 3. Statistik Interaksi
OrbFood memprioritaskan toko dengan tingkat interaksi tinggi di menu **"Rekomendasi Toko"**.
- Semakin banyak pelanggan yang mengklik tombol WhatsApp atau Maps di halaman toko Anda, semakin tinggi peringkat toko Anda di halaman utama.

### 4. Meta Tags Dinamis
Aplikasi telah dikonfigurasi untuk mengubah judul halaman secara dinamis saat user membuka toko tertentu. Ini membantu mesin pencari memahami konten dari setiap link yang dibagikan.

---

## 💡 Tips Tambahan
- **Foto Banner yang Menarik**: Gunakan foto berkualitas tinggi untuk banner toko. Foto yang bagus meningkatkan kemungkinan user mengklik toko Anda.
- **Update Menu Berkala**: Toko yang aktif mengupdate menu cenderung mendapatkan lebih banyak perhatian dari pelanggan lokal.

---

**OrbFood - Memajukan UMKM Lokal dengan Teknologi!**
