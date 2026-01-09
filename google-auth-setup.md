# Pengaturan Otentikasi Google dengan Supabase di Svelte

Panduan ini memberikan instruksi langkah demi langkah untuk mengintegrasikan otentikasi Google OAuth ke dalam aplikasi Svelte Anda menggunakan Supabase.

## Prasyarat

- Akun Google Cloud Console
- Proyek Supabase
- Aplikasi Svelte Anda dengan klien Supabase yang dikonfigurasi (lihat `src/lib/supabase.ts`)

## Langkah 1: Siapkan Kredensial Google OAuth

1. Kunjungi [Google Cloud Console](https://console.cloud.google.com/).
2. Buat proyek baru atau pilih proyek yang ada.
3. Aktifkan Google+ API:
   - Navigasi ke "APIs & Services" > "Library"
   - Cari "Google+ API" dan aktifkan.
4. Buat kredensial OAuth 2.0:
   - Pergi ke "APIs & Services" > "Credentials"
   - Klik "Create Credentials" > "OAuth 2.0 Client IDs"
   - Konfigurasi layar persetujuan OAuth jika diminta
   - Atur Tipe Aplikasi ke "Web application"
   - Tambahkan URI pengalihan yang diotorisasi:
     - Untuk pengembangan: `http://localhost:5173/auth/callback` (sesuaikan port jika berbeda)
     - Untuk produksi: URL callback aplikasi Anda di supabnse
   - Catat Client ID dan Client Secret

## Langkah 2: Konfigurasi Otentikasi Google di Supabase

1. Masuk ke [Dasbor Supabase](https://supabase.com/dashboard).
2. Pilih proyek Anda.
3. Pergi ke "Authentication" > "Providers".
4. Cari "Google" dan klik untuk mengkonfigurasi.
5. Masukkan Client ID dan Client Secret dari Langkah 1.
6. Atur URL pengalihan agar sesuai dengan URL callback aplikasi Anda.
7. Aktifkan penyedia dan simpan.

## Langkah 3: Implementasikan Otentikasi Google di Aplikasi Svelte Anda

### Perbarui Variabel Lingkungan

Tambahkan yang berikut ke file `.env` Anda (jika belum ada):
```
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

### Buat Halaman Callback Otentikasi

Buat komponen Svelte baru untuk menangani callback OAuth:

```svelte
<!-- src/lib/AuthCallback.svelte -->
<script>
  import { onMount } from 'svelte';
  import { supabase } from './supabase';
  import { goto } from '$app/navigation';

  onMount(async () => {
    const { data, error } = await supabase.auth.getSession();
    if (error) {
      console.error('Error mendapatkan sesi:', error);
    } else if (data.session) {
      // Pengguna terotentikasi, alihkan ke beranda atau dasbor
      goto('/');
    } else {
      // Tangani kasus tanpa sesi
      goto('/login');
    }
  });
</script>

<div>Loading...</div>
```

### Tambahkan Tombol Masuk dengan Google

Di komponen login atau beranda Anda, tambahkan tombol untuk memicu masuk dengan Google:

```svelte
<!-- src/lib/LoginButton.svelte -->
<script>
  import { supabase } from './supabase';

  async function signInWithGoogle() {
    const { data, error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: `${window.location.origin}/auth/callback`
      }
    });

    if (error) {
      console.error('Error masuk dengan Google:', error);
    }
  }
</script>

<button on:click={signInWithGoogle}>
  Masuk dengan Google
</button>
```

### Tangani Status Otentikasi

Buat store atau konteks untuk mengelola status otentikasi di seluruh aplikasi Anda:

```javascript
// src/lib/authStore.js
import { writable } from 'svelte/store';
import { supabase } from './supabase';

export const user = writable(null);

supabase.auth.onAuthStateChange((event, session) => {
  user.set(session?.user ?? null);
});
```

### Lindungi Rute (Opsional)

Gunakan route guards SvelteKit atau periksa status otentikasi di komponen:

```svelte
<!-- src/routes/protected/+page.svelte -->
<script>
  import { user } from '$lib/authStore';
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';

  onMount(() => {
    const unsubscribe = user.subscribe(currentUser => {
      if (!currentUser) {
        goto('/login');
      }
    });

    return unsubscribe;
  });
</script>

<!-- Konten yang dilindungi di sini -->
```

## Langkah 4: Uji Integrasi

1. Jalankan server pengembangan Anda: `npm run dev`
2. Navigasi ke halaman login Anda
3. Klik tombol "Masuk dengan Google"
4. Selesaikan alur OAuth Google
5. Verifikasi bahwa pengguna terotentikasi dan dialihkan dengan tepat

## Pemecahan Masalah

- **Ketidakcocokan URI pengalihan**: Pastikan URI pengalihan di Google Cloud Console cocok dengan yang di Supabase dan kode Anda.
- **Masalah CORS**: Pastikan proyek Supabase Anda mengizinkan permintaan dari domain aplikasi Anda.
- **Sesi tidak bertahan**: Periksa bahwa cookie diaktifkan dan aplikasi Anda menangani perubahan status otentikasi dengan benar.

## Sumber Daya Tambahan

- [Dokumentasi Otentikasi Supabase](https://supabase.com/docs/guides/auth)
- [Dokumentasi Google OAuth 2.0](https://developers.google.com/identity/protocols/oauth2)
- [Panduan Otentikasi SvelteKit](https://kit.svelte.dev/docs#routing-pages)