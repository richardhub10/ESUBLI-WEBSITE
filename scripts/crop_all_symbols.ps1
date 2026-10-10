Add-Type -AssemblyName System.Drawing

$symbolsDir = Join-Path $PSScriptRoot "..\symbols"
$pureDir = Join-Path $PSScriptRoot "..\symbols\pure"
if (-not (Test-Path $pureDir)) { New-Item -ItemType Directory -Path $pureDir -Force | Out-Null }

$files = Get-ChildItem -Path $symbolsDir -File | Where-Object { 
    $_.Extension -match '\.(jpg|png)$' -and $_.Name -notmatch '^README'
}

Write-Host "Found $($files.Count) symbol files to process."

function Process-Symbol($file) {
    try {
        $src = [System.Drawing.Bitmap]::FromFile($file.FullName)
        $w = $src.Width
        $h = $src.Height
        
        # 1. Calculate column darkness
        $colCounts = New-Object int[] $w
        for ($x = 0; $x -lt $w; $x++) {
            $dark = 0
            for ($y = 0; $y -lt $h; $y++) {
                $p = $src.GetPixel($x, $y)
                # consider non-white if brightness < 0.88
                if ($p.GetBrightness() -lt 0.88 -and $p.A -gt 30) { $dark++ }
            }
            $colCounts[$x] = $dark
        }
        
        # 2. Find first cluster (the symbol on the left)
        $minX = -1; $maxX = -1
        $inCluster = $false
        for ($x = 0; $x -lt $w; $x++) {
            if ($colCounts[$x] -gt 0) {
                if (-not $inCluster) {
                    $inCluster = $true
                    if ($minX -eq -1) { $minX = $x }
                }
                $maxX = $x
            } else {
                if ($inCluster) {
                    # We reached the whitespace gap between symbol and text!
                    break
                }
            }
        }
        
        if ($minX -eq -1) {
            $minX = 0; $maxX = [int]($w / 2)
        }
        
        # 3. Find vertical bounds of the symbol within [minX, maxX]
        $minY = $h; $maxY = -1
        for ($y = 0; $y -lt $h; $y++) {
            for ($x = $minX; $x -le $maxX; $x++) {
                $p = $src.GetPixel($x, $y)
                if ($p.GetBrightness() -lt 0.88 -and $p.A -gt 30) {
                    if ($y -lt $minY) { $minY = $y }
                    if ($y -gt $maxY) { $maxY = $y }
                }
            }
        }
        
        if ($minY -gt $maxY) { $minY = 0; $maxY = $h - 1 }
        
        # Square canvas with padding
        $pad = 12
        $symW = ($maxX - $minX + 1)
        $symH = ($maxY - $minY + 1)
        $dim = [Math]::Max($symW, $symH) + ($pad * 2)
        
        $outBmp = New-Object System.Drawing.Bitmap $dim, $dim, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $offsetX = [int](($dim - $symW) / 2)
        $offsetY = [int](($dim - $symH) / 2)
        
        # Render clean golden ink glyph (#F4D086 / #DFB467)
        for ($y = $minY; $y -le $maxY; $y++) {
            for ($x = $minX; $x -le $maxX; $x++) {
                $p = $src.GetPixel($x, $y)
                $darkness = 1.0 - $p.GetBrightness()
                if ($p.A -gt 30 -and $darkness -gt 0.10) {
                    $alpha = [int][Math]::Min(255, [Math]::Max(0, ($darkness - 0.10) / 0.5 * 255))
                    $outX = $offsetX + ($x - $minX)
                    $outY = $offsetY + ($y - $minY)
                    if ($outX -ge 0 -and $outX -lt $dim -and $outY -ge 0 -and $outY -lt $dim) {
                        $outBmp.SetPixel($outX, $outY, [System.Drawing.Color]::FromArgb($alpha, 244, 208, 134))
                    }
                }
            }
        }
        
        $src.Dispose()
        
        # Generate clean standard filename (e.g. "KA.jpg" -> "ka.png", "BI I.png" -> "bi.png")
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name).ToLower()
        # Clean spaces like "bi i" -> "bi", "ku u" -> "ku"
        $cleanName = ($baseName -replace '\s+[a-z]$', '').Trim()
        
        $outPath = Join-Path $pureDir "$cleanName.png"
        $outBmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
        $outBmp.Dispose()
        Write-Host "Processed $($file.Name) -> $cleanName.png"
    } catch {
        Write-Warning "Error processing $($file.Name): $_"
    }
}

foreach ($f in $files) {
    Process-Symbol $f
}

Write-Host "Done processing all symbols!"
