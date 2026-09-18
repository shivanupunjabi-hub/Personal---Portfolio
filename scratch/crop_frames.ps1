Add-Type -AssemblyName System.Drawing

$src = 'C:\Users\SHIVANU\.gemini\antigravity-ide\brain\13cb95f1-b267-442c-a912-c9402d64ea8f\.user_uploaded\media_1789754127491.jpg'
$img = [System.Drawing.Image]::FromFile($src)

# Frame 1: Left window (x: 8, y: 16, w: 260, h: 546)
$rect1 = New-Object System.Drawing.Rectangle(8, 16, 260, 546)
$bmp1 = New-Object System.Drawing.Bitmap($rect1.Width, $rect1.Height)
$g1 = [System.Drawing.Graphics]::FromImage($bmp1)
$g1.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g1.DrawImage($img, (New-Object System.Drawing.Rectangle(0, 0, $rect1.Width, $rect1.Height)), $rect1, [System.Drawing.GraphicsUnit]::Pixel)
$g1.Dispose()
$bmp1.Save('C:\Users\SHIVANU\Downloads\PORTFOLIO WEBSITE\assets\projects\aura-frame-1.png', [System.Drawing.Imaging.ImageFormat]::Png)
$bmp1.Dispose()

# Frame 2: Right window with pink dots header (x: 278, y: 16, w: 270, h: 546)
$rect2 = New-Object System.Drawing.Rectangle(278, 16, 270, 546)
$bmp2 = New-Object System.Drawing.Bitmap($rect2.Width, $rect2.Height)
$g2 = [System.Drawing.Graphics]::FromImage($bmp2)
$g2.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g2.DrawImage($img, (New-Object System.Drawing.Rectangle(0, 0, $rect2.Width, $rect2.Height)), $rect2, [System.Drawing.GraphicsUnit]::Pixel)
$g2.Dispose()
$bmp2.Save('C:\Users\SHIVANU\Downloads\PORTFOLIO WEBSITE\assets\projects\aura-frame-2.png', [System.Drawing.Imaging.ImageFormat]::Png)
$bmp2.Dispose()

# Full mockup graphic (x: 8, y: 16, w: 542, h: 546)
$rectFull = New-Object System.Drawing.Rectangle(8, 16, 542, 546)
$bmpFull = New-Object System.Drawing.Bitmap($rectFull.Width, $rectFull.Height)
$gFull = [System.Drawing.Graphics]::FromImage($bmpFull)
$gFull.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gFull.DrawImage($img, (New-Object System.Drawing.Rectangle(0, 0, $rectFull.Width, $rectFull.Height)), $rectFull, [System.Drawing.GraphicsUnit]::Pixel)
$gFull.Dispose()
$bmpFull.Save('C:\Users\SHIVANU\Downloads\PORTFOLIO WEBSITE\assets\projects\aura-alloy-dual-mockup.png', [System.Drawing.Imaging.ImageFormat]::Png)
$bmpFull.Dispose()

$img.Dispose()
Write-Output "Frames and dual mockup cropped successfully!"
