# 🔥 Hot Reload Guide - Flutter Web

## ✅ Hot Reload Otomatis

Flutter **sudah memiliki hot reload otomatis** built-in! Setelah menjalankan aplikasi, setiap perubahan di file Dart akan **otomatis ter-refresh** di Chrome.

## 🚀 Cara Menggunakan

### 1. Jalankan Aplikasi di Chrome
```bash
flutter run -d chrome
```

### 2. Hot Reload Otomatis
- ✅ **Setiap save file** → Browser akan otomatis refresh
- ✅ **Tidak perlu manual refresh** → Flutter handle sendiri
- ✅ **Sangat cepat** → Hanya update bagian yang berubah

### 3. Manual Hot Reload (Opsional)
Jika perlu manual trigger:
- Tekan **`r`** di terminal → Hot Reload
- Tekan **`R`** di terminal → Hot Restart (full restart)
- Tekan **`q`** di terminal → Quit

## ⚡ Tips untuk Development

### Hot Reload vs Hot Restart

**Hot Reload** (otomatis atau tekan `r`):
- ✅ Cepat (1-2 detik)
- ✅ Maintain state aplikasi
- ✅ Cocok untuk perubahan UI
- ❌ Tidak cocok untuk perubahan logic di `initState()`

**Hot Restart** (tekan `R`):
- ✅ Full restart aplikasi
- ✅ Reset semua state
- ✅ Cocok untuk perubahan di `initState()` atau constructor

### Kapan Perlu Hot Restart?

Gunakan Hot Restart jika:
- Mengubah `initState()`
- Mengubah constructor
- Mengubah static variables
- Mengubah enum values
- Mengubah theme/colors yang sudah di-load

## 🎯 Workflow Development

1. **Jalankan sekali:**
   ```bash
   flutter run -d chrome
   ```

2. **Edit file** di editor (lib/*.dart)

3. **Save file** → Browser **otomatis refresh** ✨

4. **Lihat perubahan** langsung di Chrome

## 🔧 Troubleshooting

### Hot Reload Tidak Bekerja?

1. **Cek terminal** - pastikan app masih running
2. **Cek browser** - pastikan tab Chrome masih terbuka
3. **Coba Hot Restart** - tekan `R` di terminal
4. **Restart app** - stop (`q`) dan jalankan lagi

### Perubahan Tidak Muncul?

- Gunakan **Hot Restart** (`R`) untuk perubahan besar
- **Refresh manual browser** jika perlu
- **Cek console** untuk error messages

## 📝 Catatan

- Hot reload **hanya untuk development mode**
- Untuk production build, gunakan `flutter build web`
- Hot reload **tidak bekerja** untuk perubahan di `pubspec.yaml` (perlu restart)

---

**Selamat coding! Setiap perubahan akan otomatis ter-refresh di Chrome! 🎉**







