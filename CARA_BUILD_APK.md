# 📱 Cara Build APK CatMoneyManager
## Panduan Lengkap Build Android APK

**Status:** ⚠️ Memerlukan Developer Mode di Windows  
**Waktu:** 5-10 menit (pertama kali)  
**Platform:** Android APK

---

## ⚠️ Requirement: Enable Developer Mode

### Mengapa Perlu Developer Mode?

Flutter memerlukan **symlink support** untuk build Android dengan plugins.  
Developer Mode di Windows 11 menyediakan fitur ini.

### Cara Enable Developer Mode (1 menit)

#### Opsi 1: Via Settings GUI

1. **Buka Windows Settings:**
   - Tekan `Win + I`
   - Atau ketik `ms-settings:developers` di Run (Win + R)

2. **Enable Developer Mode:**
   - Pilih **"Privacy & Security"** → **"For developers"**
   - Toggle **"Developer Mode"** → **ON**
   - Klik **"Yes"** pada konfirmasi

3. **Restart:**
   - Tidak perlu restart, tapi disarankan

#### Opsi 2: Via PowerShell (Quick)

Jalankan PowerShell as Administrator:

```powershell
start ms-settings:developers
```

Lalu toggle Developer Mode → ON

---

## 🚀 Build APK

### Setelah Developer Mode Enabled

#### 1. Build APK Release (Recommended)

```bash
flutter build apk --release
```

**Output:**
```
build/app/outputs/flutter-apk/app-release.apk
```

**Ukuran:** ~50-60 MB (compressed)

#### 2. Build APK Debug (Untuk Testing)

```bash
flutter build apk --debug
```

**Output:**
```
build/app/outputs/flutter-apk/app-debug.apk
```

**Ukuran:** ~80-90 MB (dengan debugging symbols)

#### 3. Build APK Split (Smaller Size)

Build untuk specific architecture:

```bash
# ARM64 (most modern Android phones)
flutter build apk --release --target-platform android-arm64

# ARM32 (older phones)
flutter build apk --release --target-platform android-arm

# x64 (emulators, tablets)
flutter build apk --release --target-platform android-x64
```

**Ukuran:** ~20-25 MB per architecture

---

## 📦 Build App Bundle (Google Play)

Untuk publish ke Google Play Store:

```bash
flutter build appbundle --release
```

**Output:**
```
build/app/outputs/bundle/release/app-release.aab
```

**Ukuran:** ~35-40 MB

---

## 🔧 Troubleshooting

### Error: "Building with plugins requires symlink support"

**Solusi:** Enable Developer Mode (lihat di atas)

### Error: "Gradle version mismatch"

**Sudah Fixed!** File `android/settings.gradle` dan `gradle-wrapper.properties` sudah diupdate ke:
- Android Gradle Plugin: 8.7.0
- Gradle: 8.9

### Error: "Execution failed for task ':app:lintVitalAnalyzeRelease'"

**Solusi:** Skip lint checks:

```bash
flutter build apk --release --no-tree-shake-icons
```

Atau edit `android/app/build.gradle`:

```gradle
android {
    lintOptions {
        checkReleaseBuilds false
        abortOnError false
    }
}
```

### Error: "OutOfMemory" during build

**Solusi:** Increase Gradle memory di `android/gradle.properties`:

```properties
org.gradle.jvmargs=-Xmx4096M -XX:MaxMetaspaceSize=1024m
```

---

## ✅ Verifikasi APK

### Check APK Size

```bash
flutter build apk --release --analyze-size
```

### Check APK Info

```bash
# Windows
Get-Item build/app/outputs/flutter-apk/app-release.apk

# Linux/Mac
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

---

## 📲 Install APK

### Via USB Cable

1. **Enable USB Debugging** di Android phone
2. **Connect** phone ke PC
3. **Install:**

```bash
flutter install
```

Atau manual:

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Via File Transfer

1. **Copy APK** ke phone (via Google Drive, WhatsApp, dll)
2. **Install** di phone
3. Izinkan **"Install from Unknown Sources"** jika diminta

---

## 🎨 Custom App Icon & Splash Screen

### Setup sudah ada di `pubspec.yaml`:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/cat_money_icon.png"
```

### Generate icons:

```bash
flutter pub run flutter_launcher_icons
```

---

## 📊 Build Variants

### Release Build (Production)

```bash
flutter build apk --release
```

**Features:**
- ✅ Optimized code
- ✅ Minified
- ✅ Obfuscated
- ✅ Small size
- ❌ No debugging

### Debug Build (Development)

```bash
flutter build apk --debug
```

**Features:**
- ✅ Hot reload
- ✅ Debugging enabled
- ✅ Stack traces
- ❌ Larger size
- ❌ Slower

### Profile Build (Performance Testing)

```bash
flutter build apk --profile
```

**Features:**
- ✅ Performance profiling
- ✅ Timeline
- ✅ Memory profiling
- ❌ Slightly larger than release

---

## 🔐 Signing APK (Production)

### Create Keystore

```bash
keytool -genkey -v -keystore catmoneymanager.jks -keyalg RSA -keysize 2048 -validity 10000 -alias catmoneymanager
```

### Configure Signing

Create `android/key.properties`:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=catmoneymanager
storeFile=E:/catmoneymanager/catmoneymanager.jks
```

Update `android/app/build.gradle`:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

---

## 📋 Build Checklist

Sebelum build production APK:

- [ ] **Developer Mode** enabled
- [ ] **Gradle** updated (8.9)
- [ ] **Android Gradle Plugin** updated (8.7.0)
- [ ] **App version** updated di `pubspec.yaml`
- [ ] **App icon** generated
- [ ] **Permissions** reviewed di `AndroidManifest.xml`
- [ ] **Testing** completed
- [ ] **Keystore** created (untuk production)
- [ ] **ProGuard rules** configured (jika perlu)

---

## 🎯 Quick Commands

### Build Release APK
```bash
flutter build apk --release
```

### Build & Install
```bash
flutter build apk --release && adb install build/app/outputs/flutter-apk/app-release.apk
```

### Build Split APKs (All architectures)
```bash
flutter build apk --release --split-per-abi
```

### Clean & Rebuild
```bash
flutter clean && flutter pub get && flutter build apk --release
```

---

## 📱 Output Files

### Single APK (Universal)

**Location:**
```
build/app/outputs/flutter-apk/app-release.apk
```

**Compatibility:** All Android devices  
**Size:** ~50-60 MB

### Split APKs

**Location:**
```
build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk  (~20 MB)
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk    (~25 MB)
build/app/outputs/flutter-apk/app-x86_64-release.apk       (~25 MB)
```

**Benefit:** Smaller size, but need to select correct APK for device

---

## ✅ Summary

**Requirement:**
- ✅ Windows Developer Mode enabled
- ✅ Android toolchain installed
- ✅ Gradle 8.9 + AGP 8.7.0 (already configured)

**Build Command:**
```bash
flutter build apk --release
```

**Output:**
```
build/app/outputs/flutter-apk/app-release.apk
```

**Next Steps:**
1. Enable Developer Mode
2. Run build command
3. Install APK to phone
4. Test app!

---

**Status:** 🚀 Ready to build  
**Action:** Enable Developer Mode di Windows Settings  
**ETA:** APK akan siap dalam 5-10 menit setelah Developer Mode enabled!









