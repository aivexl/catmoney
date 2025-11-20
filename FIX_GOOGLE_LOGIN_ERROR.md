# 🔧 Fix: Google Drive Login Error
## "Can't continue with google.com. Something went wrong"

**Status:** ⚠️ OAuth Client ID belum dikonfigurasi  
**Waktu Fix:** 10-15 menit  
**Kesulitan:** Medium (sekali setup)

---

## ❌ Error yang Terjadi

```
Sign in to localhost with google.com
Can't continue with google.com.
Something went wrong
```

**Screenshot:** Dialog error muncul saat klik "Sign In"

---

## ✅ Penyebab & Solusi

### Penyebab

File `lib/services/google_drive_service.dart` masih menggunakan placeholder:

```dart
static const String _clientId = 
    'YOUR_CLIENT_ID.apps.googleusercontent.com'; // ← BELUM DIGANTI!
```

### Solusi: Setup OAuth Client ID

**Ada 2 cara:**

---

## 🚀 Cara 1: Setup Lengkap (Recommended)

### Follow panduan lengkap di: **GOOGLE_DRIVE_SETUP.md**

Panduan lengkap step-by-step dengan screenshot guide:
1. Buat Project di Google Cloud Console
2. Enable Google Drive API
3. Konfigurasi OAuth Consent Screen
4. Buat OAuth Client ID
5. Copy Client ID ke kode
6. Test login

**Waktu:** 10-15 menit  
**Hasil:** Google Drive auto-backup berfungsi sempurna ✅

---

## ⚡ Cara 2: Quick Fix (Testing Only)

Untuk testing cepat tanpa setup Google Cloud:

### Step 1: Disable Google Drive Features

**File:** `lib/screens/data_management_screen.dart`

Cari section **"Backup Otomatis Google Drive"** dan comment out:

```dart
// Comment section Google Drive untuk testing
/*
if (kIsWeb) ...[
  // Google Drive backup section
  // ... (comment semua section ini)
],
*/
```

### Step 2: Use Local Backup Only

Gunakan fitur:
- ✅ Export/Import Excel (masih berfungsi)
- ✅ Backup/Restore JSON lokal (masih berfungsi)
- ❌ Auto-backup ke Google Drive (disabled)

### Step 3: Run App

```bash
flutter run -d chrome
```

**Catatan:** Ini hanya untuk testing. Untuk production, tetap perlu setup OAuth.

---

## 📋 Langkah Setup OAuth (Ringkas)

### 1. Buat OAuth Client ID

1. Buka: https://console.cloud.google.com/
2. Buat project baru: **CatMoneyManager**
3. Enable: **Google Drive API**
4. Buat: **OAuth Client ID** (Web application)
5. Authorized JavaScript origins:
   ```
   http://localhost
   http://localhost:5000
   http://localhost:8080
   ```
6. **Copy Client ID** yang muncul

### 2. Update Kode

**File:** `lib/services/google_drive_service.dart` (line 12-13)

**Sebelum:**
```dart
static const String _clientId = 
    'YOUR_CLIENT_ID.apps.googleusercontent.com';
```

**Sesudah:**
```dart
static const String _clientId = 
    'PASTE_CLIENT_ID_ANDA.apps.googleusercontent.com';
```

**Contoh:**
```dart
static const String _clientId = 
    '123456789-abc123xyz.apps.googleusercontent.com';
```

### 3. Run Ulang

```bash
# Stop app (Ctrl+C)
flutter clean
flutter run -d chrome
```

### 4. Test Login

1. Menu **Lainnya → Manajemen Data**
2. Scroll ke **"Backup Otomatis Google Drive"**
3. Klik **"Sign In"**
4. Login dengan Google
5. ✅ **"Terhubung ke Google Drive"**

---

## 🔍 Troubleshooting

### Error: "redirect_uri_mismatch"

**Solusi:**
- Tambahkan `http://localhost` ke Authorized JavaScript origins
- Cek port yang digunakan Flutter (di terminal)
- Tambahkan port tersebut juga (contoh: `http://localhost:54321`)

### Error: "Access blocked: This app's request is invalid"

**Solusi:**
- Pastikan Google Drive API sudah enabled
- Pastikan OAuth Consent Screen sudah dikonfigurasi
- Tambahkan email Anda sebagai Test User

### Error: "This app isn't verified"

**Solusi:**
- Klik **"Advanced"**
- Klik **"Go to CatMoneyManager (unsafe)"**
- Ini normal untuk development mode

### Error masih muncul setelah update Client ID

**Solusi:**
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

---

## 📊 Status Fitur

### Dengan OAuth Setup ✅

| Fitur | Status | Platform |
|-------|--------|----------|
| Export Excel | ✅ Works | Web, Desktop, Mobile |
| Import Excel | ✅ Works | Web, Desktop, Mobile |
| Backup JSON Lokal | ✅ Works | Web, Desktop, Mobile |
| Restore JSON | ✅ Works | Web, Desktop, Mobile |
| Auto-Backup Google Drive | ✅ Works | **Web Only** |
| Manual Backup Google Drive | ✅ Works | **Web Only** |

### Tanpa OAuth Setup ⚠️

| Fitur | Status | Platform |
|-------|--------|----------|
| Export Excel | ✅ Works | Web, Desktop, Mobile |
| Import Excel | ✅ Works | Web, Desktop, Mobile |
| Backup JSON Lokal | ✅ Works | Web, Desktop, Mobile |
| Restore JSON | ✅ Works | Web, Desktop, Mobile |
| Auto-Backup Google Drive | ❌ Error | Web |
| Manual Backup Google Drive | ❌ Error | Web |

---

## 🎯 Rekomendasi

### Untuk Testing (Sekarang)

Pilih salah satu:
1. **Setup OAuth** (15 menit) → Semua fitur berfungsi ✅
2. **Comment Google Drive section** (2 menit) → Fitur lain tetap jalan ✅

### Untuk Production (Nanti)

**WAJIB setup OAuth!** Untuk mendapatkan:
- ✅ Auto-backup ke Google Drive
- ✅ Data aman di cloud
- ✅ Multi-device sync (via Google Drive)
- ✅ Restore data dari mana saja

---

## 📝 Summary

**Error:** Google OAuth belum dikonfigurasi  
**Penyebab:** Client ID masih placeholder  
**Solusi:**
1. **Best:** Follow **GOOGLE_DRIVE_SETUP.md** untuk setup OAuth lengkap
2. **Quick:** Comment Google Drive section untuk testing

**File yang Perlu Diubah:**
- `lib/services/google_drive_service.dart` → Update Client ID (line 12-13)

**Setelah Update:**
```bash
flutter clean
flutter run -d chrome
```

**Hasil:**
- ✅ Google Drive login works
- ✅ Auto-backup ke cloud
- ✅ Semua fitur berfungsi sempurna!

---

## 📞 Next Steps

1. **Baca:** `GOOGLE_DRIVE_SETUP.md` untuk panduan lengkap
2. **Setup:** OAuth Client ID di Google Cloud Console
3. **Update:** Client ID di kode
4. **Test:** Login Google Drive
5. **Done:** Auto-backup ke cloud ready! 🎉

---

**Status:** ⚠️ Perlu action  
**Priority:** High (untuk production)  
**Complexity:** Medium (sekali setup, permanent fix)  
**Benefit:** 🔒 Data backup otomatis ke cloud!







