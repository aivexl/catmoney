# Panduan Setup Google Drive Auto-Backup
## Konfigurasi OAuth untuk Login Google Drive

**Status:** ⚠️ Memerlukan Setup OAuth  
**Platform:** Web (Chrome/Edge/Firefox)  
**Waktu Setup:** ~10-15 menit (sekali saja)

---

## ❌ Error yang Terjadi

```
Sign in to localhost with google.com
Can't continue with google.com.
Something went wrong
```

**Penyebab:** OAuth Client ID belum dikonfigurasi di Google Cloud Console.

---

## 📱 Mobile Configuration (Android/iOS)

**PENTING:** Untuk mobile, Anda **TIDAK** menggunakan Client ID Web. Anda perlu menambahkan konfigurasi Android/iOS di Google Cloud Console.

### Android Setup

> [!IMPORTANT]
> Android memerlukan OAuth client ID terpisah dengan SHA-1 fingerprint. Ikuti langkah berikut dengan teliti.

#### Langkah 1: Dapatkan SHA-1 Fingerprint

Buka terminal/PowerShell di folder project, lalu jalankan:

```powershell
cd android
.\gradlew signingReport
```

Cari output seperti ini:
```
Variant: debug
Config: debug
Store: C:\Users\YourName\.android\debug.keystore
Alias: AndroidDebugKey
MD5: XX:XX:XX:...
SHA1: A1:B2:C3:D4:E5:F6:... ← COPY INI
SHA-256: ...
```

**Copy SHA-1 fingerprint** (contoh: `A1:B2:C3:D4:E5:F6:...`)

#### Langkah 2: Buat OAuth Client ID untuk Android

1. **Buka Google Cloud Console** → [Credentials](https://console.cloud.google.com/apis/credentials)
2. **Create Credentials** → **OAuth client ID**
3. **Application type**: Pilih **Android**
4. **Name**: `CatMoneyManager Android`
5. **Package name**: `com.machineloops.catmoneymanager`
6. **SHA-1 certificate fingerprint**: Paste SHA-1 yang sudah di-copy
7. Klik **Create**

> [!NOTE]
> Anda **TIDAK** perlu download `google-services.json` untuk OAuth. File ini hanya diperlukan jika menggunakan Firebase.

#### Langkah 3: Verifikasi Konfigurasi

Setelah membuat OAuth client ID:
- ✅ Package name harus **exact match**: `com.machineloops.catmoneymanager`
- ✅ SHA-1 fingerprint harus dari keystore yang digunakan (debug atau release)
- ✅ OAuth client ID akan otomatis aktif (tidak perlu konfigurasi tambahan di kode)


### iOS Setup

1. **Buka Google Cloud Console** > Credentials.
2. **Create Credentials** > **OAuth client ID**.
3. Application type: **iOS**.
4. **Bundle ID:** `com.machineloops.catmoneymanager` (sesuai `ios/Runner.xcodeproj`).
5. **Create**.
6. **Download `GoogleService-Info.plist`** dan letakkan di `ios/Runner/`.
7. **Add URL Scheme** di `ios/Runner/Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
   	<dict>
   		<key>CFBundleTypeRole</key>
   		<string>Editor</string>
   		<key>CFBundleURLSchemes</key>
   		<array>
   			<string>com.googleusercontent.apps.CLIENT_ID_REVERSED</string>
   		</array>
   	</dict>
   </array>
   ```

---

## ✅ Solusi: Setup OAuth Client ID

### Langkah 1: Buat Project di Google Cloud Console

1. **Buka Google Cloud Console:**
   - Kunjungi: https://console.cloud.google.com/
   - Login dengan akun Google Anda

2. **Buat Project Baru:**
   - Klik dropdown project di atas (atau "Select a project")
   - Klik **"New Project"**
   - Nama project: `CatMoneyManager` (atau nama lain)
   - Klik **"Create"**

3. **Tunggu beberapa detik** sampai project dibuat

---

### Langkah 2: Enable Google Drive API

1. **Buka API Library:**
   - Klik menu ☰ di kiri atas
   - Pilih **"APIs & Services"** → **"Library"**

2. **Cari Google Drive API:**
   - Ketik "Google Drive API" di kotak pencarian
   - Klik pada **"Google Drive API"**
   - Klik tombol **"Enable"**

3. **Tunggu beberapa detik** sampai API aktif

---

### Langkah 3: Konfigurasi OAuth Consent Screen

1. **Buka OAuth Consent Screen:**
   - Menu ☰ → **"APIs & Services"** → **"OAuth consent screen"**

2. **Pilih User Type:**
   - Pilih **"External"** (untuk testing)
   - Klik **"Create"**

3. **Isi Informasi App:**
   - **App name:** `CatMoneyManager`
   - **User support email:** [email Anda]
   - **App logo:** (optional, bisa dilewati)
   - **Developer contact email:** [email Anda]
   - Klik **"Save and Continue"**

4. **Scopes:**
   - Klik **"Add or Remove Scopes"**
   - Centang: `.../auth/drive.file`
   - Klik **"Update"**
   - Klik **"Save and Continue"**

5. **Test Users:**
   - Klik **"Add Users"**
   - Masukkan email Anda (untuk testing)
   - Klik **"Add"**
   - Klik **"Save and Continue"**

6. **Summary:**
   - Review informasi
   - Klik **"Back to Dashboard"**

---

### Langkah 4: Buat OAuth Client ID

1. **Buka Credentials:**
   - Menu ☰ → **"APIs & Services"** → **"Credentials"**

2. **Create Credentials:**
   - Klik **"+ Create Credentials"** di atas
   - Pilih **"OAuth client ID"**

3. **Pilih Application Type:**
   - Application type: **"Web application"**
   - Name: `CatMoneyManager Web Client`

4. **Konfigurasi Authorized Origins:**
   - Klik **"+ Add URI"** di bagian "Authorized JavaScript origins"
   - Tambahkan URL berikut (satu per satu):
     ```
     http://localhost
     http://localhost:5000
     http://localhost:8080
     ```

5. **Konfigurasi Authorized Redirect URIs:**
   - Klik **"+ Add URI"** di bagian "Authorized redirect URIs"
   - Tambahkan URL berikut:
     ```
     http://localhost
     ```

6. **Create:**
   - Klik **"Create"**
   - Pop-up akan muncul dengan Client ID dan Client Secret

7. **Copy Client ID:**
   - **PENTING:** Copy **Client ID** (contoh: `123456789-abc123xyz.apps.googleusercontent.com`)
   - Simpan di notepad sementara
   - Klik **"OK"**

---

### Langkah 5: Update Kode dengan Client ID

**File:** `lib/services/google_drive_service.dart`

Cari baris ini (sekitar line 24-28):

```dart
static final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'https://www.googleapis.com/auth/drive.file',
  ],
);
```

**Ganti dengan:**

```dart
static final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: 'PASTE_CLIENT_ID_ANDA_DISINI.apps.googleusercontent.com',
  scopes: [
    'email',
    'https://www.googleapis.com/auth/drive.file',
  ],
);
```

**Contoh setelah diganti:**

```dart
static final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: '123456789-abc123xyz.apps.googleusercontent.com',
  scopes: [
    'email',
    'https://www.googleapis.com/auth/drive.file',
  ],
);
```

---

### Langkah 6: Jalankan Ulang Aplikasi

```bash
# Stop aplikasi yang sedang berjalan (Ctrl+C di terminal)
# Lalu jalankan ulang:
flutter run -d chrome
```

---

## 🧪 Test Google Drive Login

### 1. Buka Data Management Screen

- Buka aplikasi di Chrome
- Klik menu **"Lainnya"** (bottom navigation)
- Scroll ke bagian **"Backup Otomatis Google Drive"**

### 2. Klik Sign In

- Klik tombol **"Sign In"**
- Pop-up Google OAuth akan muncul
- **Jika muncul warning "This app isn't verified":**
  - Klik **"Advanced"**
  - Klik **"Go to CatMoneyManager (unsafe)"**
  - Ini normal untuk app dalam development

### 3. Pilih Akun Google

- Pilih akun Google Anda
- Review permissions:
  - ✅ See and download files created with this app
  - ✅ Upload files to Google Drive
- Klik **"Allow"**

### 4. Verifikasi Login Berhasil

- Status berubah menjadi: **"Terhubung ke Google Drive"**
- Tombol berubah menjadi: **"Sign Out"**
- Toggle "Aktifkan Auto Backup" sekarang bisa diaktifkan

### 5. Test Auto-Backup

- Toggle **"Aktifkan Auto Backup"** → **ON**
- Kembali ke Home screen
- Tambahkan transaksi baru
- ✅ Backup otomatis akan upload ke Google Drive!

### 6. Cek Google Drive

1. Buka: https://drive.google.com/
2. Lihat file baru dengan nama: `catmoneymanager_auto_backup_[timestamp].json`
3. ✅ Backup berhasil!

---

## 🔧 Troubleshooting

### Error 1: "redirect_uri_mismatch"

**Penyebab:** Redirect URI tidak cocok

**Solusi:**
1. Buka Google Cloud Console → Credentials
2. Edit OAuth Client ID
3. Tambahkan redirect URI yang sesuai:
   - `http://localhost`
   - Port yang digunakan Flutter (cek di terminal)

### Error 2: "Access blocked: This app's request is invalid"

**Penyebab:** Authorized JavaScript origins tidak lengkap

**Solusi:**
1. Buka Google Cloud Console → Credentials
2. Edit OAuth Client ID
3. Tambahkan origins:
   ```
   http://localhost
   http://localhost:5000
   http://localhost:8080
   ```

### Error 3: "This app isn't verified"

**Penyebab:** App belum diverifikasi Google (normal untuk development)

**Solusi:**
1. Klik **"Advanced"**
2. Klik **"Go to CatMoneyManager (unsafe)"**
3. Ini aman karena app buatan sendiri

### Error 4: "400: admin_policy_enforced"

**Penyebab:** Akun Google Workspace dengan kebijakan ketat

**Solusi:**
1. Gunakan akun Gmail pribadi untuk testing
2. Atau minta admin Workspace untuk whitelist app

### Error 5: Client ID tidak berfungsi

**Penyebab:** Client ID tidak disalin dengan benar

**Solusi:**
1. Pastikan Client ID lengkap (termasuk `.apps.googleusercontent.com`)
2. Tidak ada spasi atau karakter tambahan
3. Jalankan `flutter clean` lalu `flutter run -d chrome`

---

## 📱 Port Detection untuk Flutter Web

Flutter Web biasanya menggunakan port random. Untuk mengetahui port:

```bash
flutter run -d chrome
```

Output akan menampilkan:
```
Launching lib/main.dart on Chrome in debug mode...
Building application for the web...
Serving web on http://localhost:54321
```

Port: `54321` ← Tambahkan ini ke Authorized JavaScript origins

---

## 🌐 Deploy ke Production

### Untuk Hosting (Firebase, Netlify, dll)

1. **Update Authorized Origins:**
   - Tambahkan domain production Anda:
   ```
   https://your-domain.com
   https://www.your-domain.com
   ```

2. **Update Redirect URIs:**
   - Tambahkan:
   ```
   https://your-domain.com
   ```

3. **Verifikasi Domain:**
   - Google Cloud Console → OAuth consent screen
   - Verify domain ownership jika diperlukan

4. **Submit for Verification:**
   - Untuk production, submit app untuk Google verification
   - Atau tetap gunakan mode "Testing" (limit 100 users)

---

## 🔒 Keamanan

### Scope yang Digunakan

```
https://www.googleapis.com/auth/drive.file
```

**Akses:**
- ✅ Hanya file yang dibuat oleh app ini
- ❌ TIDAK bisa akses file lain di Drive
- ✅ User bisa revoke access kapan saja

### Revoke Access

User bisa revoke access di:
- https://myaccount.google.com/permissions
- Cari "CatMoneyManager"
- Klik "Remove Access"

---

## 📊 Quota & Limits

### Google Drive API Quotas (Free Tier)

- **Queries per day:** 1,000,000,000
- **Queries per 100 seconds per user:** 1,000
- **Queries per 100 seconds:** 10,000

**Kesimpulan:** Lebih dari cukup untuk personal use!

---

## ✅ Checklist Setup

- [ ] Project dibuat di Google Cloud Console
- [ ] Google Drive API enabled
- [ ] OAuth Consent Screen dikonfigurasi
- [ ] Test user ditambahkan
- [ ] OAuth Client ID dibuat
- [ ] Authorized JavaScript origins ditambahkan
- [ ] Client ID disalin
- [ ] Client ID dipaste ke `google_drive_service.dart`
- [ ] App di-run ulang
- [ ] Login berhasil
- [ ] Auto-backup diaktifkan
- [ ] Test upload berhasil

---

## 🎯 Summary

**Waktu Setup:** 10-15 menit  
**Biaya:** GRATIS  
**Kesulitan:** Medium (sekali setup, selanjutnya mudah)

**Setelah Setup:**
- ✅ Login Google Drive works
- ✅ Auto-backup ke Google Drive
- ✅ Manual backup ke Google Drive
- ✅ Secure OAuth authentication
- ✅ Production-ready

---

## 📞 Bantuan

Jika masih ada error setelah mengikuti panduan ini, cek:

1. **Client ID sudah benar?**
   - Copy ulang dari Google Cloud Console
   - Pastikan lengkap dengan `.apps.googleusercontent.com`

2. **Authorized Origins sudah benar?**
   - `http://localhost` + port yang digunakan
   - Cek port di terminal saat `flutter run`

3. **App di-run ulang setelah update Client ID?**
   - `flutter clean`
   - `flutter run -d chrome`

4. **Email sudah ditambahkan sebagai Test User?**
   - OAuth consent screen → Test users
   - Tambahkan email yang digunakan untuk login

---

**Status:** ✅ Setup guide complete  
**Next Step:** Follow langkah 1-6 di atas untuk enable Google Drive login!
