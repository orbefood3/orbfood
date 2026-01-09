# Panduan Integrasi Cloudinary ☁️

Dokumen ini berisi langkah-langkah untuk menghubungkan aplikasi Orbfood2 dengan layanan Cloudinary untuk upload gambar.

## 1. Persiapan Akun Cloudinary
1.  Daftar atau login di [Cloudinary Console](https://console.cloudinary.com/).
2.  Pada **Dashboard**, cari **Product Environment Credentials**.
3.  Salin **Cloud Name** Anda.

## 2. Membuat Upload Preset (PENTING)
Agar aplikasi bisa mengupload gambar tanpa harus mengekspos API Secret di frontend (Unsigned Upload), Anda perlu membuat "Upload Preset".

1.  Buka **Settings** (ikon gerigi di pojok kanan atas) -> **Upload**.
2.  Scroll ke bawah ke bagian **Upload presets**.
3.  Klik **Add upload preset**.
4.  Pada halaman konfigurasi preset:
    - **Name**: Berikan nama (contoh: `orbfood_uploads`).
    - **Signing Mode**: Ubah menjadi **Unsigned**.
    - **Folder** (Opsional): Tentukan folder penyimpanan (contoh: `orbfood/menus`).
5.  Klik **Save**.
6.  Salin **Name** dari preset yang baru Anda buat.

## 3. Konfigurasi Environment Variables

### Frontend (.env file)
Untuk **development lokal**, tambahkan di file `.env`:

```env
# Cloudinary Config - Upload (Frontend)
VITE_CLOUDINARY_CLOUD_NAME=your_cloud_name
VITE_CLOUDINARY_UPLOAD_PRESET=your_upload_preset
```

> **Catatan:** Pastikan tidak ada spasi di sekitar tanda sama dengan (=).

### Backend (Supabase Secrets) - LEBIH AMAN ✅
**JANGAN** simpan API Key/Secret di file `.env`! Gunakan Supabase Secrets:

1. Buka [Cloudinary Console](https://console.cloudinary.com/)
2. Pada **Dashboard**, di bagian **Product Environment Credentials**:
   - **API Key**: Salin nilai ini
   - **API Secret**: Klik tombol "Show" atau "Reveal" untuk melihat, lalu salin

3. Buka **Supabase Dashboard** → Project Settings → **Edge Functions** → **Secrets**
4. Tambahkan secrets berikut:
   - `CLOUDINARY_CLOUD_NAME` = `your_cloud_name`
   - `CLOUDINARY_API_KEY` = `your_api_key`
   - `CLOUDINARY_API_SECRET` = `your_api_secret`

> **Keamanan:** Dengan cara ini, credentials **tidak pernah** tersimpan di kode atau file lokal, sehingga aman dari kebocoran!

## 4. Deploy Edge Function (Untuk Fitur Hapus Gambar)
Aplikasi menggunakan Supabase Edge Function untuk menghapus gambar **secara aman** - credentials tidak pernah terekspos ke browser.

### Production (Wajib)
```bash
npx supabase functions deploy delete-image
```

Pastikan Supabase Secrets sudah di-set (lihat langkah 3 di atas).

### Lokal (Development - Opsional)
Jika ingin test deletion di lokal:
```bash
npx supabase functions serve
```

> **Note:** Untuk development, Anda bisa skip test deletion dan langsung deploy ke production.

## 5. Penggunaan di Kode
Layanan upload dan delete sudah dibuat di `src/lib/services/cloudinary.ts`.

### Upload Gambar
```typescript
import { uploadImage } from '$lib/services/cloudinary';

// Upload file (tipe File dari <input type="file" />)
const url = await uploadImage(file);
console.log(url); // https://res.cloudinary.com/...
```

### Hapus Gambar
```typescript
import { deleteImage, getPublicIdFromUrl } from '$lib/services/cloudinary';

// Ekstrak public_id dari URL
const publicId = getPublicIdFromUrl(imageUrl);

// Hapus gambar
if (publicId) {
  await deleteImage(publicId);
}
```

### Optimasi Gambar (WebP & Auto Quality)
Gunakan fungsi `getOptimizedImageUrl` untuk menampilkan gambar agar lebih ringan dan SEO friendly.

```typescript
import { getOptimizedImageUrl } from '$lib/services/cloudinary';

// Mengubah URL mentah menjadi URL dengan f_auto,q_auto
const optimalUrl = getOptimizedImageUrl(menu.primary_image, 300); // 300 adalah lebar (width) opsional
```

## Troubleshooting
- **Error 401 (Unauthorized) saat upload**: Biasanya karena Upload Preset belum diset ke **Unsigned** atau nama preset salah.
- **Gambar tidak muncul**: Cek `VITE_CLOUDINARY_CLOUD_NAME` apakah sudah benar.
- **Error saat hapus gambar**: 
  - Pastikan Edge Function sudah di-deploy (`npx supabase functions deploy delete-image`)
  - Pastikan `CLOUDINARY_API_KEY` dan `CLOUDINARY_API_SECRET` sudah di-set di Supabase Edge Functions Secrets
  - Cek console browser dan Supabase Logs untuk error detail
