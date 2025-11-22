# 🔧 Cara Disable Google Drive Feature (Sementara)
## Quick Fix untuk Error Google Drive Login

**Status:** ✅ Feature flag sudah ditambahkan  
**Waktu Fix:** 30 detik  
**Kesulitan:** Sangat Mudah

---

## 🎯 Kapan Perlu Disable?

Disable Google Drive feature sementara jika:
- ✅ Belum setup OAuth Client ID
- ✅ Masih dalam tahap development/testing
- ✅ Ingin fokus testing fitur lain dulu
- ✅ Google login terus error

---

## ⚡ Cara Disable (30 Detik)

### Langkah 1: Buka File Config

```
lib/config/features_config.dart
```

### Langkah 2: Ubah Flag

**Sebelum:**
```dart
class FeaturesConfig {
  static const bool enableGoogleDriveBackup = true;  // ← TRUE
  ...
}
```

**Sesudah:**
```dart
class FeaturesConfig {
  static const bool enableGoogleDriveBackup = false;  // ← FALSE
  ...
}
```

### Langkah 3: Save & Run

```bash
flutter run -d chrome
```

**DONE!** Google Drive section akan hidden dan tidak ada lagi error login! ✅

---

## ✅ Apa yang Terjadi Setelah Disable?

### Yang Tetap Berfungsi

- ✅ **Export ke Excel** → Masih berfungsi normal
- ✅ **Import dari Excel** → Masih berfungsi normal
- ✅ **Backup JSON Lokal** → Masih berfungsi normal
- ✅ **Restore dari Backup** → Masih berfungsi normal
- ✅ **Semua fitur transaction** → Tidak terpengaruh

### Yang Di-disable

- ❌ **Auto-backup Google Drive** → Hidden dari UI
- ❌ **Manual backup Google Drive** → Hidden dari UI
- ❌ **Google login button** → Hidden dari UI

### UI Changes

Akan muncul pesan:
```
⚠️ Google Drive backup sementara dinonaktifkan.

Untuk mengaktifkan, set FeaturesConfig.enableGoogleDriveBackup = true
di file lib/config/features_config.dart setelah OAuth setup selesai.
```

---

## 🚀 Cara Enable Kembali

### Setelah OAuth Setup Selesai

1. **Setup OAuth Client ID** (ikuti: `GOOGLE_DRIVE_SETUP.md`)
2. **Buka:** `lib/config/features_config.dart`
3. **Ubah kembali:**
   ```dart
   static const bool enableGoogleDriveBackup = true;
   ```
4. **Save & Run:**
   ```bash
   flutter run -d chrome
   ```

---

## 📊 Feature Flags Lainnya

File `lib/config/features_config.dart` juga punya flags lain:

```dart
class FeaturesConfig {
  /// Google Drive backup
  static const bool enableGoogleDriveBackup = false;  // ← Ubah ini
  
  /// Excel features (export/import)
  static const bool enableExcelFeatures = true;
  
  /// Local JSON backup/restore  
  static const bool enableLocalBackup = true;
  
  /// Debug info
  static const bool showDebugInfo = false;
}
```

Ubah sesuai kebutuhan development/testing Anda!

---

## 🎯 Rekomendasi

### Untuk Testing (Sekarang)

```dart
static const bool enableGoogleDriveBackup = false;  // ← DISABLE
```

**Kenapa?**
- ✅ Fokus testing fitur transaction dulu
- ✅ Tidak ada error Google login
- ✅ Excel export/import masih jalan
- ✅ Development lebih cepat

### Untuk Production (Nanti)

```dart
static const bool enableGoogleDriveBackup = true;  // ← ENABLE
```

**Setelah:**
1. OAuth Client ID sudah setup
2. Google login sudah tested
3. Ready untuk auto-backup ke cloud

---

## ✅ Summary

**Problem:** Google Drive login error  
**Quick Fix:** Disable feature dengan ubah 1 line code  
**Impact:** Fitur lain tetap berfungsi 100%  
**Time:** 30 detik  

**File to Edit:**
```
lib/config/features_config.dart
```

**Line to Change:**
```dart
static const bool enableGoogleDriveBackup = false;  // ← dari true ke false
```

**Command:**
```bash
flutter run -d chrome
```

**Result:**
- ✅ No more Google Drive errors
- ✅ All other features work normally
- ✅ Clean UI without Google Drive section

---

## 🔄 Next Steps

### Opsi 1: Tetap Disable (Mudah)

- Lanjutkan development fitur lain
- Google Drive setup belakangan
- Semua fitur backup lokal tetap tersedia

### Opsi 2: Setup OAuth (15 menit)

- Follow guide: `GOOGLE_DRIVE_SETUP.md`
- Enable feature kembali
- Dapat auto-backup ke cloud

---

**Status:** ✅ Fix ready  
**Next Action:** Ubah 1 line di `features_config.dart`  
**ETA:** App akan jalan tanpa error dalam 30 detik!










