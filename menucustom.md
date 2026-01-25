

# 1️⃣ Konsep Dasar (1 kalimat)

> **Menu Paket** = menu utama
> **Option Group** = kelompok pilihan (topping, level, isian, dll)
> **Option Item** = pilihan di dalam group

---

# 2️⃣ Mekanisme di SISI TOKO (Admin)

## A. Saat Membuat Menu

Toko memilih:

* **Tipe menu**:

  * `single` → menu biasa
  * `package` → menu custom (prasmanan / topping)

Jika pilih `package` → **fitur option aktif**

---

## B. Toko Membuat OPTION GROUP

Option group **DIBUAT OLEH TOKO** (bukan sistem)

Contoh:

* Pilihan Isian
* Topping
* Level Pedas
* Tambahan

Setiap option group punya aturan:

* `required` → wajib dipilih atau tidak
* `min` → minimal pilihan
* `max` → maksimal pilihan

Contoh:

```
Option Group: Isian
required: true
min: 1
max: 5
```

---

## C. Toko Menambahkan OPTION ITEM

Di dalam option group, toko membuat item:

Contoh (Isian):

* Kerupuk (+0)
* Makaroni (+2.000)
* Bakso (+3.000)
* Ceker (+4.000)

Setiap item:

* Nama
* Harga tambahan
* Status aktif/nonaktif

---

## D. Relasi Data (logika, bukan tabel)

```
Menu Paket
 ├── Option Group (1..n)
 │     ├── Option Item (1..n)
 │     └── aturan min/max
```

➡️ Satu menu bisa punya **banyak group**
➡️ Group bisa dipakai **ulang** ke menu lain (opsional)

---

# 3️⃣ Mekanisme di SISI USER (Pembeli)

## A. User Buka Menu Paket

Sistem membaca:

* daftar option group
* aturan tiap group

---

## B. User Memilih Option

Untuk setiap option group:

* Jika `required = true` → **tidak bisa skip**
* Jika `max = 1` → radio (pilih satu)
* Jika `max > 1` → checkbox

Contoh:

```
Isian (pilih 1–5)
☑ Kerupuk
☑ Bakso
☐ Ceker
```

---

## C. Validasi SEBELUM Masuk Keranjang

Sistem cek:

* apakah semua `required` terpenuhi
* apakah jumlah pilihan sesuai `min/max`

Jika tidak:

* tombol “Tambah ke Keranjang” **disable**
* tampilkan pesan singkat

---

## D. Harga Otomatis

```
Harga akhir =
harga menu dasar
+ total harga option item
```

Disimpan sebagai:

* snapshot (bukan referensi live)

---

# 4️⃣ Saat Masuk Keranjang

Yang disimpan:

* menu_id
* nama menu
* harga dasar
* daftar option terpilih (nama + harga)
* total harga

➡️ **Harga TIDAK berubah** walau toko edit menu setelahnya

---

# 5️⃣ Contoh Nyata (Seblak Prasmanan)

### Toko:

* Menu: Seblak Prasmanan (Rp10.000)

Option Group:

1. Isian (wajib, 1–5)
2. Level Pedas (wajib, 1)
3. Topping (opsional, max 3)

---

### User pilih:

* Isian: Kerupuk, Bakso
* Level: Pedas 3
* Topping: Keju

Total:

```
10.000
+ Bakso 3.000
+ Keju 2.000
= 15.000
```

---

# 6️⃣ Kenapa model ini BAGUS untuk Orbefood?

✅ Fleksibel (seblak, kopi, mie, ayam geprek)
✅ Cocok untuk toko kecil
✅ Mudah dipahami pedagang
✅ Bisa reuse option group
✅ Tidak ribet UI
✅ Aman untuk scaling

---

# 7️⃣ Kesalahan yang harus DIHINDARI

❌ Sistem menentukan option group
❌ User bebas tambah tanpa batas
❌ Harga dihitung ulang dari menu live
❌ Option group tidak punya aturan min/max

---

## Ringkasan 1 Kalimat 🧠

> **Toko membuat menu → menentukan option group & aturannya → user memilih sesuai aturan → sistem validasi → harga dikunci di keranjang.**
