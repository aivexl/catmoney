# Script to run Flutter in Chrome
# Usage: .\run_flutter_chrome.ps1 [flutter_path]
# Example: .\run_flutter_chrome.ps1 "C:\flutter"

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
        "$env:USERPROFILE\dev\flutter"
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
    Write-Host "  .\run_flutter_chrome.ps1 -FlutterPath 'C:\flutter'" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Or install Flutter from:" -ForegroundColor Yellow
    Write-Host "  https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Cyan
    exit 1
}

$flutterBat = "$FlutterPath\bin\flutter.bat"
Write-Host "Using Flutter at: $FlutterPath" -ForegroundColor Green
Write-Host "Launching in Chrome..." -ForegroundColor Yellow
Write-Host ""

& $flutterBat run -d chrome



