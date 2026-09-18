Add-Type -AssemblyName System.Drawing

$src = 'C:\Users\SHIVANU\.gemini\antigravity-ide\brain\13cb95f1-b267-442c-a912-c9402d64ea8f\.user_uploaded\media_1789754127491.jpg'
$img = [System.Drawing.Image]::FromFile($src)

# Combined mockups on the left (x: 8 to 556, y: 18 to 566)
$rect = New-Object System.Drawing.Rectangle(8, 18, 548, 548)
$bmp = New-Object System.Drawing.Bitmap($rect.Width, $rect.Height)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$destRect = New-Object System.Drawing.Rectangle(0, 0, $rect.Width, $rect.Height)
$g.DrawImage($img, $destRect, $rect, [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()

$outPath1 = 'C:\Users\SHIVANU\Downloads\PORTFOLIO WEBSITE\assets\projects\aura-alloy-showcase.png'
$bmp.Save($outPath1, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
$img.Dispose()

Write-Output "Cropped showcase image saved to $outPath1"
