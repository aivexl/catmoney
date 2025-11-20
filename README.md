# 🐱 Cat Money Manager

Aplikasi money manager yang lucu dengan tema pastel dan kucing untuk Android dan iOS menggunakan Flutter.

## 📋 Requirements yang Dibutuhkan

### 1. Software Development
- **Flutter SDK** (versi 3.0 atau lebih baru)
  - Download: https://flutter.dev/docs/get-started/install
  - Extract dan tambahkan ke PATH
- **Dart SDK** (sudah termasuk dengan Flutter)

### 2. Untuk Android Development
- **Java Development Kit (JDK)** - versi 17
  - Download: https://adoptium.net/
- **Android Studio**
  - Download: https://developer.android.com/studio
  - Install Android SDK (API level 33 atau lebih baru)
  - Install Flutter plugin di Android Studio
- **Environment Variables:**
  - `ANDROID_HOME` - path ke Android SDK
  - `JAVA_HOME` - path ke JDK

### 3. Untuk iOS Development (Hanya macOS)
- **Xcode** (versi 14 atau lebih baru)
  - Download dari App Store
  - Install Command Line Tools: `xcode-select --install`
- **CocoaPods**
  - Install: `sudo gem install cocoapods`

### 4. IDE (Pilihan)
- **Android Studio** (disarankan)
- **VS Code** dengan Flutter extension
- **IntelliJ IDEA**

## 🚀 Setup Project

1. **Verifikasi Flutter installation:**
```bash
flutter doctor
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Jalankan aplikasi:**

Android:
```bash
flutter run
```

iOS (macOS only):
```bash
flutter run
```

## 📱 Fitur

- ✨ Tema pastel yang cantik
- 🐱 Elemen UI bertema kucing
- 💰 Tracking income dan expense
- 📊 Statistik dan grafik
- 🏷️ Kategori transaksi
- 💾 Penyimpanan data lokal
- 📅 Filter berdasarkan tanggal

## 🎨 Tema Warna Pastel

- Pink: #FFB6C1
- Lavender: #E6E6FA
- Mint: #B2F5EA
- Peach: #FFDAB9
- Sky Blue: #B0E0E6
- Yellow: #FFFACD

## 📂 Struktur Project

```
catmoneymanager/
├── lib/
│   ├── main.dart
│   ├── models/          # Data models
│   ├── screens/         # Screen aplikasi
│   ├── widgets/         # Widget reusable
│   ├── providers/       # State management
│   ├── services/        # Services (storage, dll)
│   ├── theme/           # Tema dan warna
│   └── utils/           # Utility functions
├── android/             # Android native code
├── ios/                  # iOS native code
└── assets/              # Images, icons, dll
```

## 🛠️ Development

- Run app: `flutter run`
- Hot reload: Tekan `r` di terminal
- Hot restart: Tekan `R` di terminal
- Quit: Tekan `q` di terminal

## 📝 License

MIT
