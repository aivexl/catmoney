# Alternative Image Compression Script
# Uses .NET System.Drawing to resize and optimize PNG icons
# No external API required

param(
    [Parameter(Mandatory = $false)]
    [string]$InputDir = "assets/icons",
    
    [Parameter(Mandatory = $false)]
    [string]$BackupDir = "assets/icons_backup",
    
    [Parameter(Mandatory = $false)]
    [int]$MaxWidth = 256,
    
    [Parameter(Mandatory = $false)]
    [int]$MaxHeight = 256
)

Add-Type -AssemblyName System.Drawing

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Get-FileSizeMB {
    param([string]$Path)
    return [math]::Round((Get-Item $Path).Length / 1MB, 2)
}

function Resize-Image {
    param(
        [string]$ImagePath,
        [int]$MaxWidth,
        [int]$MaxHeight
    )
    
    try {
        $fileName = Split-Path $ImagePath -Leaf
        $originalSize = Get-FileSizeMB $ImagePath
        
        Write-ColorOutput "Processing: $fileName (${originalSize}MB)" "Cyan"
        
        # Load image
        $img = [System.Drawing.Image]::FromFile($ImagePath)
        $originalWidth = $img.Width
        $originalHeight = $img.Height
        
        # Calculate new dimensions maintaining aspect ratio
        $ratioX = $MaxWidth / $originalWidth
        $ratioY = $MaxHeight / $originalHeight
        $ratio = [Math]::Min($ratioX, $ratioY)
        
        $newWidth = [int]($originalWidth * $ratio)
        $newHeight = [int]($originalHeight * $ratio)
        
        # Only resize if image is larger than max dimensions
        if ($originalWidth -le $MaxWidth -and $originalHeight -le $MaxHeight) {
            Write-ColorOutput "  Skipped: Already optimal size (${originalWidth}x${originalHeight})" "Yellow"
            $img.Dispose()
            return @{
                Success      = $true
                OriginalSize = $originalSize
                NewSize      = $originalSize
                Savings      = 0
                Skipped      = $true
            }
        }
        
        Write-ColorOutput "  Resizing: ${originalWidth}x${originalHeight} -> ${newWidth}x${newHeight}" "Cyan"
        
        # Create new bitmap
        $newImg = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
        $graphics = [System.Drawing.Graphics]::FromImage($newImg)
        
        # Set high quality rendering
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        
        # Draw resized image
        $graphics.DrawImage($img, 0, 0, $newWidth, $newHeight)
        
        # Save with compression
        $tempFile = "$ImagePath.tmp"
        $newImg.Save($tempFile, [System.Drawing.Imaging.ImageFormat]::Png)
        
        # Cleanup
        $graphics.Dispose()
        $newImg.Dispose()
        $img.Dispose()
        
        # Replace original
        Remove-Item $ImagePath -Force
        Move-Item $tempFile $ImagePath -Force
        
        $newSize = Get-FileSizeMB $ImagePath
        $savings = $originalSize - $newSize
        $savingsPercent = if ($originalSize -gt 0) { [math]::Round(($savings / $originalSize) * 100, 1) } else { 0 }
        
        Write-ColorOutput "  Success: ${originalSize}MB -> ${newSize}MB (saved ${savingsPercent}%)" "Green"
        
        return @{
            Success      = $true
            OriginalSize = $originalSize
            NewSize      = $newSize
            Savings      = $savings
            Skipped      = $false
        }
    }
    catch {
        Write-ColorOutput "  Error: $($_.Exception.Message)" "Red"
        return @{
            Success = $false
            Error   = $_.Exception.Message
        }
    }
}

# Main script
Write-ColorOutput "`n=== Cat Money Manager - Image Optimization ===" "Cyan"
Write-ColorOutput "Resizing PNG icons to ${MaxWidth}x${MaxHeight} maximum`n" "Cyan"

# Check if input directory exists
if (-not (Test-Path $InputDir)) {
    Write-ColorOutput "ERROR: Input directory not found: $InputDir" "Red"
    exit 1
}

# Create backup directory
if (-not (Test-Path $BackupDir)) {
    Write-ColorOutput "Creating backup directory: $BackupDir" "Cyan"
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
}

# Get all PNG files
$pngFiles = Get-ChildItem -Path $InputDir -Filter "*.png" | Where-Object { $_.Name -notlike ".gitkeep" }

if ($pngFiles.Count -eq 0) {
    Write-ColorOutput "No PNG files found in $InputDir" "Yellow"
    exit 0
}

Write-ColorOutput "Found $($pngFiles.Count) PNG files to process`n" "Cyan"

# Backup original files
Write-ColorOutput "Backing up original files..." "Cyan"
foreach ($file in $pngFiles) {
    Copy-Item $file.FullName -Destination $BackupDir -Force
}
Write-ColorOutput "Backup complete`n" "Green"

# Process each file
$totalOriginalSize = 0
$totalNewSize = 0
$successCount = 0
$failCount = 0
$skippedCount = 0

foreach ($file in $pngFiles) {
    $result = Resize-Image -ImagePath $file.FullName -MaxWidth $MaxWidth -MaxHeight $MaxHeight
    
    if ($result.Success) {
        $totalOriginalSize += $result.OriginalSize
        $totalNewSize += $result.NewSize
        if ($result.Skipped) {
            $skippedCount++
        }
        else {
            $successCount++
        }
    }
    else {
        $failCount++
    }
}

# Summary
Write-ColorOutput "`n=== Optimization Summary ===" "Cyan"
Write-ColorOutput "Total files processed: $($pngFiles.Count)" "Cyan"
Write-ColorOutput "Optimized: $successCount" "Green"
Write-ColorOutput "Skipped: $skippedCount" "Yellow"
Write-ColorOutput "Failed: $failCount" $(if ($failCount -gt 0) { "Red" } else { "Cyan" })
Write-ColorOutput "Original total size: ${totalOriginalSize}MB" "Cyan"
Write-ColorOutput "Optimized total size: ${totalNewSize}MB" "Green"
$totalSavings = $totalOriginalSize - $totalNewSize
$totalSavingsPercent = if ($totalOriginalSize -gt 0) { [math]::Round(($totalSavings / $totalOriginalSize) * 100, 1) } else { 0 }
Write-ColorOutput "Total savings: ${totalSavings}MB (${totalSavingsPercent}%)" "Green"
Write-ColorOutput "`nBackup location: $BackupDir`n" "Yellow"
