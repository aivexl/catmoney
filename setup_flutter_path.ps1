# Script untuk menambahkan Flutter ke PATH sementara
# Ganti path berikut dengan lokasi Flutter Anda
$flutterPath = "C:\flutter\bin"

# Cek apakah path Flutter ada
if (Test-Path $flutterPath) {
    # Tambahkan ke PATH untuk sesi ini
    $env:PATH = "$flutterPath;$env:PATH"
    Write-Host "Flutter path ditambahkan: $flutterPath" -ForegroundColor Green
    Write-Host "Sekarang jalankan: flutter run -d chrome" -ForegroundColor Yellow
} else {
    Write-Host "Flutter tidak ditemukan di: $flutterPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Silakan:" -ForegroundColor Yellow
    Write-Host "1. Download Flutter dari: https://docs.flutter.dev/get-started/install/windows"
    Write-Host "2. Extract ke folder (contoh: C:\flutter)"
    Write-Host "3. Edit script ini dan ganti `$flutterPath dengan lokasi Flutter Anda"
    Write-Host "4. Atau tambahkan Flutter ke System PATH secara permanen"
}





