Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile('C:\Users\SHIVANU\.gemini\antigravity-ide\brain\13cb95f1-b267-442c-a912-c9402d64ea8f\.user_uploaded\media_1789754127491.jpg')
Write-Output "Width: $($img.Width) Height: $($img.Height)"
$img.Dispose()
