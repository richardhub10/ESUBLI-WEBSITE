Add-Type -AssemblyName System.Drawing

$srcPath = Join-Path $PSScriptRoot "..\assets\raw\background_orig.jpg"
$dstPath = Join-Path $PSScriptRoot "..\assets\images\background.jpg"

$src = [System.Drawing.Bitmap]::FromFile($srcPath)
$w = $src.Width
$h = $src.Height

$dst = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

# High-quality unsharp mask / convolution sharpen kernel
# Kernel weights:
# [ 0,  -0.5, 0 ]
# [ -0.5, 3.0, -0.5 ]
# [ 0,  -0.5, 0 ]
$kC = 2.6
$kE = -0.4

for ($y = 0; $y -lt $h; $y++) {
    $yPrev = [Math]::Max(0, $y - 1)
    $yNext = [Math]::Min($h - 1, $y + 1)
    
    for ($x = 0; $x -lt $w; $x++) {
        $xPrev = [Math]::Max(0, $x - 1)
        $xNext = [Math]::Min($w - 1, $x + 1)
        
        $c = $src.GetPixel($x, $y)
        $t = $src.GetPixel($x, $yPrev)
        $b = $src.GetPixel($x, $yNext)
        $l = $src.GetPixel($xPrev, $y)
        $r = $src.GetPixel($xNext, $y)
        
        $rVal = $c.R * $kC + ($t.R + $b.R + $l.R + $r.R) * $kE
        $gVal = $c.G * $kC + ($t.G + $b.G + $l.G + $r.G) * $kE
        $bVal = $c.B * $kC + ($t.B + $b.B + $l.B + $r.B) * $kE
        
        # Clamp between 0 and 255
        $rClamped = [int][Math]::Min(255, [Math]::Max(0, [Math]::Round($rVal)))
        $gClamped = [int][Math]::Min(255, [Math]::Max(0, [Math]::Round($gVal)))
        $bClamped = [int][Math]::Min(255, [Math]::Max(0, [Math]::Round($bVal)))
        
        $dst.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $rClamped, $gClamped, $bClamped))
    }
}

# Save with 96% JPEG quality
$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
$encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]96)

$dst.Save($dstPath, $codec, $encoderParams)

$src.Dispose()
$dst.Dispose()

Write-Host "Sharpened background saved to $dstPath"
