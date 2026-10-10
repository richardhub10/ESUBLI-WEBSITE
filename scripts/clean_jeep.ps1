Add-Type -AssemblyName System.Drawing

$srcPath = Join-Path $PSScriptRoot "..\assets\raw\trail-jeep.png"
$dstPath = Join-Path $PSScriptRoot "..\assets\raw\trail-jeep-clean.png"

$src = [System.Drawing.Bitmap]::FromFile($srcPath)
Write-Host "Width: $($src.Width), Height: $($src.Height)"

# Crop out the text on the left (x from 0 to 45) or cover text with parchment tone
# Let's see: sample parchment color from x=50, y=20
$cropX = 38 # cut off the leftmost 38px containing text
$newW = $src.Width - $cropX
$newH = $src.Height

$dst = New-Object System.Drawing.Bitmap($newW, $newH, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($dst)
$srcRect = New-Object System.Drawing.Rectangle($cropX, 0, $newW, $newH)
$dstRect = New-Object System.Drawing.Rectangle(0, 0, $newW, $newH)
$g.DrawImage($src, $dstRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)

$g.Dispose()
$src.Dispose()

$dst.Save($dstPath, [System.Drawing.Imaging.ImageFormat]::Png)
$dst.Dispose()

Write-Host "Cleaned image saved to $dstPath"
