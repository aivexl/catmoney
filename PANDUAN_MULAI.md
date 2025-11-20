# 🐱 Panduan Memulai Cat Money Manager (Flutter)

## ✅ Yang Sudah Dibuat

Project aplikasi Cat Money Manager dengan Flutter sudah siap dengan:

### 📁 Struktur Project
- ✅ Konfigurasi Flutter (pubspec.yaml)
- ✅ Tema pastel dengan warna-warna cantik
- ✅ Widget UI bertema kucing
- ✅ Fitur money manager lengkap
- ✅ State management dengan Provider
- ✅ Data storage (SharedPreferences)

### 🎨 Fitur yang Tersedia
- ✅ Home screen dengan saldo dan statistik
- ✅ Tambah transaksi (income/expense)
- ✅ Kategori transaksi dengan emoji kucing
- ✅ Penyimpanan data lokal
- ✅ Tema pastel yang konsisten
- ✅ Hot reload untuk development cepat

## 📋 Yang Perlu Anda Lakukan

### Step 1: Install Flutter SDK

1. **Download Flutter SDK**
   - Website: https://flutter.dev/docs/get-started/install
   - Pilih sesuai OS Anda (Windows/Mac/Linux)

2. **Extract Flutter SDK**
   - Extract ke folder (contoh: `C:\flutter` atau `~/flutter`)
   - Jangan extract ke folder yang memerlukan admin privileges

3. **Tambahkan ke PATH**
   - Windows: System Properties → Environment Variables → PATH
   - Mac/Linux: Tambahkan ke `~/.bashrc` atau `~/.zshrc`:
     ```bash
     export PATH="$PATH:/path/to/flutter/bin"
     ```

4. **Verifikasi Installation**
   ```bash
   flutter doctor
   ```

### Step 2: Install Android Studio (untuk Android)

1. **Download Android Studio**
   - Website: https://developer.android.com/studio

2. **Install Android SDK**
   - Buka Android Studio
   - Tools → SDK Manager
   - Install Android SDK (API 33+)

3. **Install Flutter Plugin**
   - File → Settings → Plugins
   - Cari "Flutter" dan install
   - Dart plugin akan otomatis terinstall

4. **Set Environment Variables**
   - Windows: `ANDROID_HOME` = `C:\Users\<username>\AppData\Local\Android\Sdk`
   - Mac/Linux: Tambahkan ke `~/.bashrc`:
     ```bash
     export ANDROID_HOME=$HOME/Library/Android/sdk
     export PATH=$PATH:$ANDROID_HOME/platform-tools
     ```

### Step 3: Setup Project

```bash
# 1. Install dependencies
flutter pub get

# 2. Verifikasi setup
flutter doctor

# 3. Jalankan aplikasi
flutter run
```

## 📱 Cara Menggunakan

1. **Home Screen**: Lihat saldo total, pemasukan, dan pengeluaran
2. **Tab Tambah**: Klik untuk menambah transaksi baru
3. **Pilih Tipe**: Pilih pemasukan atau pengeluaran
4. **Isi Data**: Masukkan jumlah, deskripsi, dan pilih kategori
5. **Simpan**: Transaksi akan tersimpan dan muncul di home screen

## 🎨 Customization

### Mengubah Warna Tema
Edit file: `lib/theme/app_colors.dart`

### Menambah Kategori
Edit file: `lib/models/category.dart`

### Mengubah Tampilan
Edit file di folder `lib/screens/` dan `lib/widgets/`

## 🛠️ Development Commands

```bash
# Run aplikasi
flutter run

# Hot reload (saat app running, tekan 'r')
# Hot restart (saat app running, tekan 'R')
# Quit (saat app running, tekan 'q')

# Build APK untuk Android
flutter build apk

# Build App Bundle untuk Play Store
flutter build appbundle

# Build untuk iOS (macOS only)
flutter build ios
```

## 🐛 Troubleshooting

**Problem: "flutter: command not found"**
- Pastikan Flutter sudah di PATH
- Restart terminal/command prompt
- Verifikasi: `flutter --version`

**Problem: "Android SDK not found"**
- Pastikan `ANDROID_HOME` sudah di-set
- Install Android SDK dari Android Studio
- Cek: `echo $ANDROID_HOME` atau `echo %ANDROID_HOME%`

**Problem: "No devices found"**
- Pastikan device sudah connect via USB
- Enable USB Debugging di device
- Atau buat emulator dari Android Studio

**Problem: "Module not found"**
```bash
flutter clean
flutter pub get
```

**Problem: Build error**
```bash
flutter clean
cd android && ./gradlew clean && cd ..
flutter pub get
flutter run
```

## 📚 File Penting

- `REQUIREMENTS.md` - Daftar lengkap requirements
- `pubspec.yaml` - Dependencies project
- `lib/main.dart` - Entry point aplikasi
- `lib/theme/` - Tema dan warna
- `lib/models/` - Data models
- `lib/screens/` - Screen aplikasi
- `lib/widgets/` - Widget reusable

## 🚀 Next Steps

1. Install Flutter SDK dan semua requirements
2. Setup project dengan `flutter pub get`
3. Jalankan aplikasi dengan `flutter run`
4. Customize sesuai kebutuhan
5. Build untuk production (jika sudah siap)

## 💡 Tips Flutter

- **Hot Reload**: Tekan `r` untuk reload cepat
- **Hot Restart**: Tekan `R` untuk restart
- **Widget Inspector**: Gunakan Flutter DevTools
- **Performance**: Gunakan `flutter run --profile` untuk testing performance
- **Build Size**: Optimize dengan `flutter build apk --split-per-abi`

## 🎓 Learning Resources

- **Flutter Docs**: https://flutter.dev/docs
- **Flutter Cookbook**: https://flutter.dev/docs/cookbook
- **Flutter YouTube**: https://www.youtube.com/c/flutterdev
- **Dart Language**: https://dart.dev/guides

Selamat coding dengan Flutter! 🐱✨
