Add-Type -AssemblyName System.Drawing

$srcPath = Join-Path $PSScriptRoot "..\assets\images\app-screen.png"
$medallionPath = Join-Path $PSScriptRoot "..\assets\images\logo-medallion.png"
$basePath = Join-Path $PSScriptRoot "..\assets\images\app-screen-base.png"

$src = [System.Drawing.Bitmap]::FromFile($srcPath)
$width = $src.Width
$height = $src.Height

# Circle center in 385 x 842
$cx = 192.5
$cy = 222.5
$radius = 94.0 # inner radius to capture gold rim and full artwork

# 1. Create transparent logo medallion
$cropSize = 200
$half = $cropSize / 2
$medallion = New-Object System.Drawing.Bitmap($cropSize, $cropSize, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

for ($x = 0; $x -lt $cropSize; $x++) {
    for ($y = 0; $y -lt $cropSize; $y++) {
        $dx = $x - $half
        $dy = $y - $half
        $dist = [Math]::Sqrt($dx * $dx + $dy * $dy)

        $srcX = [int]($cx + $dx)
        $srcY = [int]($cy + $dy)

        if ($srcX -ge 0 -and $srcX -lt $width -and $srcY -ge 0 -and $srcY -lt $height) {
            $origPixel = $src.GetPixel($srcX, $srcY)

            if ($dist -le ($radius - 1.5)) {
                $medallion.SetPixel($x, $y, $origPixel)
            }
            elseif ($dist -le ($radius + 1.5)) {
                $alphaFactor = ($radius + 1.5 - $dist) / 3.0
                $alpha = [int]($origPixel.A * $alphaFactor)
                if ($alpha -lt 0) { $alpha = 0 }
                if ($alpha -gt 255) { $alpha = 255 }
                $medallion.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($alpha, $origPixel.R, $origPixel.G, $origPixel.B))
            }
            else {
                $medallion.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, 0, 0, 0))
            }
        }
    }
}
$medallion.Save($medallionPath, [System.Drawing.Imaging.ImageFormat]::Png)
$medallion.Dispose()
Write-Host "Created $medallionPath"

# 2. Create app-screen-base.png with background filled under the circle
$base = New-Object System.Drawing.Bitmap($src)

for ($y = [int]($cy - $radius - 5); $y -le [int]($cy + $radius + 5); $y++) {
    for ($x = [int]($cx - $radius - 5); $x -le [int]($cx + $radius + 5); $x++) {
        $dx = $x - $cx
        $dy = $y - $cy
        $dist = [Math]::Sqrt($dx * $dx + $dy * $dy)

        if ($dist -le ($radius + 2.0)) {
            # Compute smooth dark eye background color
            # Base color is dark warm charcoal: R=38, G=28, B=26 in center, with slight vertical gradient
            $yRatio = ($y - ($cy - $radius)) / ($radius * 2)
            $r = [int](32 + 20 * $yRatio)
            $g = [int](24 + 14 * $yRatio)
            $b = [int](24 + 8 * $yRatio)

            # Feather transition around edge
            if ($dist -gt ($radius - 4.0)) {
                $orig = $src.GetPixel($x, $y)
                $blend = ($dist - ($radius - 4.0)) / 6.0
                if ($blend -gt 1.0) { $blend = 1.0 }
                if ($blend -lt 0.0) { $blend = 0.0 }
                $fr = [int]($r * (1.0 - $blend) + $orig.R * $blend)
                $fg = [int]($g * (1.0 - $blend) + $orig.G * $blend)
                $fb = [int]($b * (1.0 - $blend) + $orig.B * $blend)
                $base.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $fr, $fg, $fb))
            } else {
                $base.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $r, $g, $b))
            }
        }
    }
}
$base.Save($basePath, [System.Drawing.Imaging.ImageFormat]::Png)
$base.Dispose()
$src.Dispose()
Write-Host "Created $basePath"
