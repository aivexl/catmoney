# 📋 Requirements untuk Aplikasi Cat Money Manager (Flutter)

## 🎯 Ringkasan
Aplikasi money manager untuk Android dan iOS dengan tema pastel dan kucing menggunakan Flutter.

## 💻 Software yang Dibutuhkan

### 1. **Flutter SDK** (Wajib)
- **Versi**: 3.0.0 atau lebih baru
- **Download**: https://flutter.dev/docs/get-started/install
- **Cara Install**:
  - Download Flutter SDK untuk Windows/Mac/Linux
  - Extract ke folder (contoh: `C:\flutter` atau `~/flutter`)
  - Tambahkan ke PATH environment variable
  - Verifikasi: `flutter doctor`

### 2. **Dart SDK** (Otomatis dengan Flutter)
- Sudah termasuk dalam Flutter SDK
- Tidak perlu install terpisah

### 3. **Untuk Android Development**

#### a. Java Development Kit (JDK)
- **Versi**: JDK 17 (disarankan)
- **Download**: https://adoptium.net/
- **Set Environment Variable**:
  - Windows: 
    - System Properties → Environment Variables
    - Tambahkan `JAVA_HOME` = `C:\Program Files\Java\jdk-17`
    - Tambahkan `%JAVA_HOME%\bin` ke PATH
  - Mac/Linux:
    - Tambahkan ke `~/.bashrc` atau `~/.zshrc`:
      ```bash
      export JAVA_HOME=/path/to/jdk-17
      export PATH=$JAVA_HOME/bin:$PATH
      ```

#### b. Android Studio
- **Download**: https://developer.android.com/studio
- **Yang perlu diinstall**:
  - Android SDK (API Level 33 atau lebih baru)
  - Android SDK Platform-Tools
  - Android Virtual Device (AVD) Manager
  - Android Emulator
  - **Flutter Plugin** (dari Android Studio → Plugins)
  - **Dart Plugin** (dari Android Studio → Plugins)
  
- **Set Environment Variables**:
  - Windows:
    - `ANDROID_HOME` = `C:\Users\<username>\AppData\Local\Android\Sdk`
    - Tambahkan ke PATH:
      - `%ANDROID_HOME%\platform-tools`
      - `%ANDROID_HOME%\tools`
  - Mac/Linux:
    - Tambahkan ke `~/.bashrc` atau `~/.zshrc`:
      ```bash
      export ANDROID_HOME=$HOME/Library/Android/sdk
      export PATH=$PATH:$ANDROID_HOME/platform-tools
      export PATH=$PATH:$ANDROID_HOME/tools
      ```

#### c. Verifikasi Android Setup
```bash
# Cek Java
java -version

# Cek Android SDK
echo $ANDROID_HOME  # Mac/Linux
echo %ANDROID_HOME% # Windows

# Cek ADB
adb version
```

### 4. **Untuk iOS Development** (Hanya macOS)

#### a. Xcode
- **Versi**: 14.0 atau lebih baru
- **Download**: App Store (gratis, tapi besar ~15GB)
- **Install Command Line Tools**:
  ```bash
  xcode-select --install
  ```

#### b. CocoaPods
- **Install**:
  ```bash
  sudo gem install cocoapods
  ```
- **Verifikasi**: `pod --version`

### 5. **IDE (Pilihan)**

#### a. Android Studio (Disarankan)
- Download: https://developer.android.com/studio
- Install Flutter dan Dart plugins
- Lebih lengkap untuk development

#### b. VS Code (Alternatif)
- Download: https://code.visualstudio.com/
- Install Flutter extension
- Lebih ringan dan cepat

#### c. IntelliJ IDEA
- Download: https://www.jetbrains.com/idea/
- Install Flutter dan Dart plugins

## 🖥️ System Requirements

### Minimum:
- **RAM**: 8GB (16GB disarankan)
- **Storage**: 10GB free space (untuk Flutter SDK + Android Studio)
- **OS**: 
  - Windows 10/11 (64-bit)
  - macOS 11+ (untuk iOS development)
  - Linux (untuk Android development)

### Untuk Android Emulator:
- RAM: 4GB+ untuk emulator
- Enable Virtualization di BIOS (Intel VT-x atau AMD-V)

## 🚀 Quick Start

1. **Install Flutter SDK**:
   ```bash
   # Download dari https://flutter.dev
   # Extract dan tambahkan ke PATH
   ```

2. **Verifikasi installation**:
   ```bash
   flutter doctor
   ```

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

4. **Jalankan aplikasi**:
   ```bash
   flutter run
   ```

## 📱 Testing di Device

### Android:
1. Enable Developer Options di Android device
2. Enable USB Debugging
3. Connect via USB
4. Run: `flutter run`

### iOS:
1. Connect iPhone via USB
2. Trust computer
3. Select device di Xcode
4. Run: `flutter run`

## 🎨 Fitur Aplikasi

✅ Tema pastel yang cantik  
✅ UI bertema kucing dengan emoji  
✅ Tracking income dan expense  
✅ Kategori transaksi  
✅ Penyimpanan data lokal  
✅ Statistik saldo  
✅ Tampilan yang user-friendly  

## 📚 Resources Tambahan

- **Flutter Docs**: https://flutter.dev/docs
- **Dart Docs**: https://dart.dev/guides
- **Flutter Packages**: https://pub.dev/
- **Flutter Community**: https://flutter.dev/community

## ⚠️ Catatan Penting

1. **iOS development HANYA bisa di macOS** - tidak bisa di Windows/Linux
2. **Android development bisa di semua OS** (Windows/Mac/Linux)
3. **Pastikan Flutter sudah di PATH** sebelum menjalankan commands
4. **Jalankan `flutter doctor`** untuk cek setup yang kurang
5. **Gunakan device fisik** untuk testing yang lebih baik (lebih cepat dari emulator)

## 🆘 Troubleshooting

### Flutter doctor menunjukkan masalah:
- Ikuti saran dari `flutter doctor`
- Install missing components
- Set environment variables yang diperlukan

### Android build error:
- Pastikan `ANDROID_HOME` sudah di-set
- Pastikan JDK sudah terinstall
- Run: `flutter clean` lalu `flutter pub get`

### iOS build error (macOS):
- Pastikan Xcode sudah terinstall
- Run: `cd ios && pod install && cd ..`
- Pastikan CocoaPods sudah terinstall

### Module not found:
```bash
flutter clean
flutter pub get
```

## 💡 Tips

1. **Gunakan device fisik** untuk testing (lebih cepat)
2. **Hot reload** dengan tekan `r` di terminal saat app running
3. **Hot restart** dengan tekan `R` di terminal
4. **Gunakan Flutter DevTools** untuk debugging
5. **Backup data** sebelum build production
