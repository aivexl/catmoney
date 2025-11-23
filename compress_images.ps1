# Image Compression Script for Cat Money Manager
# Compresses PNG icons using TinyPNG API
# 
# Usage: .\compress_images.ps1 -ApiKey "YOUR_API_KEY"
# Get free API key from: https://tinypng.com/developers

param(
    [Parameter(Mandatory = $false)]
    [string]$ApiKey = "",
    
    [Parameter(Mandatory = $false)]
    [string]$InputDir = "assets/icons",
    
    [Parameter(Mandatory = $false)]
    [string]$BackupDir = "assets/icons_backup"
)

# Colors for output
$ErrorColor = "Red"
$SuccessColor = "Green"
$InfoColor = "Cyan"
$WarningColor = "Yellow"

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Get-FileSizeMB {
    param([string]$Path)
    return [math]::Round((Get-Item $Path).Length / 1MB, 2)
}

function Compress-ImageWithTinyPNG {
    param(
        [string]$ImagePath,
        [string]$ApiKey
    )
    
    try {
        $fileName = Split-Path $ImagePath -Leaf
        Write-ColorOutput "Compressing: $fileName" $InfoColor
        
        # Read file as bytes
        $imageBytes = [System.IO.File]::ReadAllBytes($ImagePath)
        $originalSize = Get-FileSizeMB $ImagePath
        
        # Create HTTP request
        $uri = "https://api.tinify.com/shrink"
        $base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("api:$ApiKey"))
        
        $headers = @{
            "Authorization" = "Basic $base64Auth"
        }
        
        # Upload image
        Write-ColorOutput "  Uploading..." $InfoColor
        $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $imageBytes -ContentType "image/png"
        
        if ($response.output.url) {
            # Download compressed image
            Write-ColorOutput "  Downloading compressed version..." $InfoColor
            $compressedBytes = Invoke-RestMethod -Uri $response.output.url -Method Get
            
            # Save compressed image
            [System.IO.File]::WriteAllBytes($ImagePath, $compressedBytes)
            
            $newSize = Get-FileSizeMB $ImagePath
            $savings = $originalSize - $newSize
            $savingsPercent = [math]::Round(($savings / $originalSize) * 100, 1)
            
            Write-ColorOutput "  Success: $originalSize MB -> $newSize MB (saved $savingsPercent%)" $SuccessColor
            
            return @{
                Success      = $true
                OriginalSize = $originalSize
                NewSize      = $newSize
                Savings      = $savings
            }
        }
    }
    catch {
        Write-ColorOutput "  Error: $($_.Exception.Message)" $ErrorColor
        return @{
            Success = $false
            Error   = $_.Exception.Message
        }
    }
}

# Main script
Write-ColorOutput "`n=== Cat Money Manager - Image Compression ===" $InfoColor
Write-ColorOutput "Using TinyPNG API for lossless compression`n" $InfoColor

# Check if API key is provided
if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    Write-ColorOutput "ERROR: API key is required!" $ErrorColor
    Write-ColorOutput "Get your free API key from: https://tinypng.com/developers" $WarningColor
    Write-ColorOutput "Usage: .\compress_images.ps1 -ApiKey 'YOUR_API_KEY'`n" $InfoColor
    exit 1
}

# Check if input directory exists
if (-not (Test-Path $InputDir)) {
    Write-ColorOutput "ERROR: Input directory not found: $InputDir" $ErrorColor
    exit 1
}

# Create backup directory
if (-not (Test-Path $BackupDir)) {
    Write-ColorOutput "Creating backup directory: $BackupDir" $InfoColor
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
}

# Get all PNG files
$pngFiles = Get-ChildItem -Path $InputDir -Filter "*.png" | Where-Object { $_.Name -notlike ".gitkeep" }

if ($pngFiles.Count -eq 0) {
    Write-ColorOutput "No PNG files found in $InputDir" $WarningColor
    exit 0
}

Write-ColorOutput "Found $($pngFiles.Count) PNG files to compress`n" $InfoColor

# Backup original files
Write-ColorOutput "Backing up original files..." $InfoColor
foreach ($file in $pngFiles) {
    Copy-Item $file.FullName -Destination $BackupDir -Force
}
Write-ColorOutput "Backup complete`n" $SuccessColor

# Compress each file
$totalOriginalSize = 0
$totalNewSize = 0
$successCount = 0
$failCount = 0

foreach ($file in $pngFiles) {
    $result = Compress-ImageWithTinyPNG -ImagePath $file.FullName -ApiKey $ApiKey
    
    if ($result.Success) {
        $totalOriginalSize += $result.OriginalSize
        $totalNewSize += $result.NewSize
        $successCount++
    }
    else {
        $failCount++
    }
    
    Start-Sleep -Milliseconds 500  # Rate limiting
}

# Summary
Write-ColorOutput "`n=== Compression Summary ===" $InfoColor
Write-ColorOutput "Total files processed: $($pngFiles.Count)" $InfoColor
Write-ColorOutput "Successful: $successCount" $SuccessColor
Write-ColorOutput "Failed: $failCount" $(if ($failCount -gt 0) { $ErrorColor } else { $InfoColor })
Write-ColorOutput "Original total size: $totalOriginalSize MB" $InfoColor
Write-ColorOutput "Compressed total size: $totalNewSize MB" $SuccessColor
Write-ColorOutput "Total savings: $([math]::Round($totalOriginalSize - $totalNewSize, 2)) MB ($([math]::Round((($totalOriginalSize - $totalNewSize) / $totalOriginalSize) * 100, 1))%)" $SuccessColor
Write-ColorOutput "`nBackup location: $BackupDir`n" $WarningColor
