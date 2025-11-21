# Script to build Flutter APK for Android
# Usage: .\build_apk.ps1 [flutter_path]

param(
    [string]$FlutterPath = ""
)

if($FlutterPath -eq "") {
    # Try to find Flutter automatically
    $searchPaths = @(
        "$env:LOCALAPPDATA\flutter",
        "C:\flutter",
        "C:\src\flutter",
        "$env:USERPROFILE\flutter",
        "$env:USERPROFILE\development\flutter",
        "$env:USERPROFILE\dev\flutter",
        "E:\flutter"
    )
    
    foreach($path in $searchPaths) {
        if(Test-Path "$path\bin\flutter.bat") {
            $FlutterPath = $path
            break
        }
    }
}

if($FlutterPath -eq "" -or -not (Test-Path "$FlutterPath\bin\flutter.bat")) {
    Write-Host "Flutter SDK not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please provide Flutter path:" -ForegroundColor Yellow
    Write-Host "  .\build_apk.ps1 -FlutterPath 'E:\flutter'" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Or install Flutter from:" -ForegroundColor Yellow
    Write-Host "  https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Cyan
    exit 1
}

$flutterBat = "$FlutterPath\bin\flutter.bat"
Write-Host "Using Flutter at: $FlutterPath" -ForegroundColor Green
Write-Host "Building APK for Android..." -ForegroundColor Yellow
Write-Host ""

& $flutterBat build apk --release

if($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ APK built successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "APK location:" -ForegroundColor Yellow
    Write-Host "  build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "You can install this APK on your Android device!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "❌ Build failed!" -ForegroundColor Red
}
