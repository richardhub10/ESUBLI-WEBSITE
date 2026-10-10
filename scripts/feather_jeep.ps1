Add-Type -AssemblyName System.Drawing

$srcPath = Join-Path $PSScriptRoot "..\assets\raw\trail-jeep-clean.png"
$dstPath = Join-Path $PSScriptRoot "..\assets\raw\trail-jeep-feathered.png"

$src = [System.Drawing.Bitmap]::FromFile($srcPath)
$w = $src.Width
$h = $src.Height

$dst = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

# Feather margins
$fadeLeft = 25
$fadeRight = 20
$fadeTop = 15
$fadeBottom = 15

for ($x = 0; $x -lt $w; $x++) {
    for ($y = 0; $y -lt $h; $y++) {
        $p = $src.GetPixel($x, $y)
        
        # Calculate alpha factor based on distance from edges
        $alphaF = 1.0
        if ($x -lt $fadeLeft) { $alphaF *= ($x / $fadeLeft) }
        if ($x -gt ($w - $fadeRight)) { $alphaF *= (($w - $x) / $fadeRight) }
        if ($y -lt $fadeTop) { $alphaF *= ($y / $fadeTop) }
        if ($y -gt ($h - $fadeBottom)) { $alphaF *= (($h - $y) / $fadeBottom) }
        
        $newA = [int]([Math]::Round($p.A * $alphaF))
        if ($newA -gt 255) { $newA = 255 }
        if ($newA -lt 0) { $newA = 0 }
        
        $dst.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($newA, $p.R, $p.G, $p.B))
    }
}

$dst.Save($dstPath, [System.Drawing.Imaging.ImageFormat]::Png)
$src.Dispose()
$dst.Dispose()

Write-Host "Feathered image saved to $dstPath"
