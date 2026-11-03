param([string]$out, [string]$file = "", [int]$x = 440, [int]$y = 185, [int]$w = 1110, [int]$h = 710, [int]$maskX = -1, [int]$maskY = -1)
Add-Type -AssemblyName System.Drawing
$dir = "D:\Git\WoW_Forever_Diary\screenshots\0.3.0"
New-Item -ItemType Directory -Force $dir | Out-Null
$shots = "D:\World of Warcraft\_anniversary_\Screenshots"
if ($file) { $f = Get-Item (Join-Path $shots $file) } else { $f = Get-ChildItem $shots | Sort-Object LastWriteTime | Select-Object -Last 1 }
$src = [System.Drawing.Image]::FromFile($f.FullName)
$bmp = New-Object System.Drawing.Bitmap $w, $h
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.DrawImage($src, (New-Object System.Drawing.Rectangle 0, 0, $w, $h), (New-Object System.Drawing.Rectangle $x, $y, $w, $h), [System.Drawing.GraphicsUnit]::Pixel)
if ($maskX -ge 0) { $g.FillRectangle((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 22, 16, 12))), $maskX, $maskY, ($w - $maskX), ($h - $maskY)) }
$bmp.Save("$dir\$out.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose(); $src.Dispose()
"$($f.Name) -> $out.png"
