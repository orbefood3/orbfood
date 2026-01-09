
## 🎭 Role User (di `user_profiles.role`)

```ts
'admin' | 'shop' | 'user'
```

### Penjelasan

| Role      | Bisa                                 |
| --------- | ------------------------------------ |
| **user**  | Pesan makanan, lihat history, review |
| **shop**  | Kelola toko & menu                   |
| **admin** | Verifikasi toko, moderasi            |

❌ Tidak ada role `pending`

---

# 🏪 STATUS TOKO (BUKAN ROLE)

Verifikasi **melekat di toko**, bukan user.

Di tabel `shops`:

```sql
is_verified BOOLEAN DEFAULT false
is_active BOOLEAN DEFAULT true
```

---

# 🔁 FLOW YANG BENAR (SESUAI KEINGINAN KAMU)

```
USER (role=user)
 ↓ daftar toko
SHOP dibuat (is_verified = false)
 ↓ admin approve
role user → shop
```

---

# 👤 UI USER BIASA (AKUN)

### Halaman Akun

```
👤 Akun Saya
-------------------
Nama
Email

🟦 Buka Toko
Mulai jualan makanan di sekitarmu

📦 Pesanan Saya
❤️ Favorit
⚙️ Pengaturan
```

---

# 📝 HALAMAN DAFTAR TOKO (USER → TOKO)

📍 Route:

```
/buka-toko
```

### UI

```
🛍️ Buka Toko

Nama Toko*
Kategori*
WhatsApp*
Alamat*

Jam Buka - Jam Tutup

[ Upload Logo ]
[ Upload Banner ]

🟧 AJUKAN TOKO
```

➡️ Submit → data masuk ke `shops`
➡️ `is_verified = false`

---

# ⏳ SETELAH DAFTAR (MASIH USER)

### UI Feedback

```
⏳ Pengajuan Toko Dikirim

Toko kamu sedang ditinjau admin.
Kami akan memberi tahu setelah disetujui.
```

➡️ Role tetap **user**
➡️ Menu toko **belum muncul**

---

# 🛡️ UI ADMIN – VERIFIKASI TOKO

📍 Route:

```
/admin/shops
```

### List

```
🕒 Toko Menunggu Verifikasi
--------------------------------
🍜 Warung Bu Sari
📍 Desa Sukamaju
📞 WA aktif

[ Approve ] [ Reject ]
```

---

# ✅ SAAT ADMIN APPROVE

### Backend

```sql
UPDATE shops SET is_verified = true WHERE id = ?
UPDATE user_profiles SET role = 'shop' WHERE id = owner_id
```

---

# 🎉 LOGIN ULANG → ROLE BERUBAH

User login ulang → redirect otomatis:

| Role  | Redirect          |
| ----- | ----------------- |
| user  | `/`               |
| shop  | `/toko/dashboard` |
| admin | `/admin`          |

---

# 🏪 UI TOKO (SETELAH APPROVE)

### Sidebar / Menu

```
🏪 Dashboard
🍔 Menu
📸 Gambar
🕒 Jam Operasional
⚙️ Profil Toko
🚪 Logout
```

❌ Tidak ada:

* Pesanan saya
* Favorit
* Review

> Fokus: **jualan**

---

# 🔒 RLS (LOGIKA SINGKAT)

| Aksi                 | Boleh |
| -------------------- | ----- |
| User baca toko       | ✅     |
| User CRUD menu       | ❌     |
| Shop CRUD menu       | ✅     |
| Shop lihat toko lain | ❌     |
| Admin lihat semua    | ✅     |

Siap. Kita bikin **alur + UI/UX sisi TOKO** yang **jelas, aman, dan tidak ribet**, sesuai konsep kamu:

> 🔑 **User biasa → daftar toko → diverifikasi admin → berubah role jadi TOKO (bukan user biasa lagi)**

Aku jelaskan **step-by-step + tampilan halaman**.

---

# 🧑‍💼 KONSEP ROLE (PENTING, BIAR JELAS)

### 🎭 Role yang ada

1. **USER**

   * Bisa pesan makanan
   * Bisa login Google
   * Bisa daftar toko

2. **PENDING_TOKO**

   * Sudah daftar
   * Menunggu verifikasi admin
   * Tidak bisa jualan

3. **TOKO**

   * Bisa kelola menu
   * Terima pesanan WA
   * Tidak bisa pesan seperti user biasa

> ✅ Setelah disetujui → **role berubah permanen ke TOKO**

---

# 👤 HALAMAN USER – TOMBOL “BUKA TOKO”

📍 **Lokasi:**

* Halaman Akun / Profil

### UI

```
👤 Akun Saya
---------------------
Nama: Irfan
Login: Google

🟦 Buka Toko Anda
Mulai jualan makanan di sekitar Anda
```

➡️ Klik **Buka Toko** → ke halaman pendaftaran toko

---

# 📝 HALAMAN DAFTAR TOKO (FORM)

### 🧱 UI Struktur (1 halaman, ringan)

```
🛍️ Daftar Toko
-----------------------

Nama Toko*
Kategori*
(No dropdown ribet: Makanan / Minuman / Camilan)

No WhatsApp*
Alamat Singkat*
(deskripsi bebas)

Jam Buka
Jam Tutup

Upload Logo (opsional)
Upload Banner (opsional)

[ ] Saya menyatakan data benar

🟧 AJUKAN TOKO
```

### UX Notes

* Form **sederhana**
* Tidak perlu KTP / legalitas dulu
* Cocok untuk UMKM desa

---

# ⏳ STATUS SETELAH DAFTAR

Setelah klik **Ajukan Toko** 👇

### UI Feedback

```
⏳ Pengajuan Toko Dikirim

Toko Anda sedang menunggu verifikasi admin.
Proses biasanya 1x24 jam.

Kami akan memberi notifikasi setelah disetujui.
```

➡️ Akun berubah status:

```
USER → PENDING_TOKO
```

---

# 🛡️ HALAMAN ADMIN – VERIFIKASI TOKO (KONSEP)

(Admin bisa manual, tidak perlu UI kompleks dulu)

### Data yang dicek admin:

* Nama toko
* WA aktif
* Alamat masuk akal
* Tidak duplikat

### Aksi Admin:

* ✅ Setujui
* ❌ Tolak (opsional alasan)

---

# 🔁 SAAT ADMIN MENYETUJUI

### Backend Action

```
shops.is_verified = true
shops.is_active = true
```

Dan **role user berubah**:

```
auth.users.role = "shop"
```

atau via `user_profiles.role = 'shop'`

---

# 🎉 UI SETELAH DISETUJUI (LOGIN ULANG)

Saat user login ulang:

### Redirect otomatis ke:

```
/toko/dashboard
```

### Popup / Banner

```
🎉 Selamat!
Toko Anda telah disetujui.
Sekarang Anda bisa mulai jualan.
```

---

# 🏪 DASHBOARD TOKO (UI/UX)

### Sidebar / Menu

```
🏪 Dashboard
📋 Pesanan (via WA)
🍔 Menu Saya
📸 Kelola Foto
🕒 Jam Operasional
⚙️ Pengaturan Toko
```

---

## 📋 DASHBOARD UTAMA TOKO

### Tampilan

```
Halo, Toko Bu Sari 👋

📦 Total Menu: 12
👀 Dilihat: 120
📲 Pesanan Hari Ini: 5

🟧 Tambah Menu
```

---

# 🍔 HALAMAN KELOLA MENU (TOKO)

### List Menu

```
[IMG] Nasi Goreng  Rp 15.000  🟢
[IMG] Es Teh       Rp 5.000   🟢
```

* Toggle aktif/nonaktif
* Edit harga
* Hapus menu

---

# ❌ USER TIDAK BISA PESAN LAGI SETELAH JADI TOKO

### UX Handling

* Menu **Pesanan Saya** disembunyikan
* Diganti:

```
📋 Kelola Toko
```

🧠 **Alasan UX**

* Menghindari role bingung
* Fokus 1 peran

---

# 🔐 RLS & KEAMANAN (SINGKAT)

* `shops.owner_id = auth.uid()`
* User tanpa toko ❌ tidak bisa akses dashboard
* PENDING_TOKO ❌ tidak bisa input menu
* Hanya TOKO yang bisa CRUD menu

---

# 🔄 FLOW RINGKAS (SUPER JELAS)

```
USER
 ↓ klik
BUKA TOKO
 ↓
ISI FORM
 ↓
PENDING_TOKO
 ↓ (admin approve)
TOKO
 ↓
DASHBOARD TOKO
```

---

# 🏪 DASHBOARD TOKO (UI/UX)

### Sidebar / Menu

```
🏪 Dashboard
📋 Pesanan (via WA)
🍔 Menu Saya
📸 Kelola Foto
🕒 Jam Operasional
⚙️ Pengaturan Toko
```

---

## 📋 DASHBOARD UTAMA TOKO

### Tampilan

```
Halo, Toko Bu Sari 👋

📦 Total Menu: 12
👀 Dilihat: 120
📲 Pesanan Hari Ini: 5

🟧 Tambah Menu
```

---

# 🍔 HALAMAN KELOLA MENU (TOKO)

### List Menu

```
[IMG] Nasi Goreng  Rp 15.000  🟢
[IMG] Es Teh       Rp 5.000   🟢
```

* Toggle aktif/nonaktif
* Edit harga
* Hapus menu

---

# ❌ USER TIDAK BISA PESAN LAGI SETELAH JADI TOKO

### UX Handling

* Menu **Pesanan Saya** disembunyikan
* Diganti:

```
📋 Kelola Toko
```

🧠 **Alasan UX**

* Menghindari role bingung
* Fokus 1 peran

---

# 🔐 RLS & KEAMANAN (SINGKAT)

* `shops.owner_id = auth.uid()`
* User tanpa toko ❌ tidak bisa akses dashboard
* PENDING_TOKO ❌ tidak bisa input menu
* Hanya TOKO yang bisa CRUD menu

---

# 🔄 FLOW RINGKAS (SUPER JELAS)

```
USER
 ↓ klik
BUKA TOKO
 ↓
ISI FORM
 ↓
PENDING_TOKO
 ↓ (admin approve)
TOKO
 ↓
DASHBOARD TOKO
```

---