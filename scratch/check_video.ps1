$shell = New-Object -ComObject Shell.Application
$folder = $shell.Namespace('C:\Users\SHIVANU\Downloads\PORTFOLIO WEBSITE\assets\projects')
$files = @('lv_0_20260908063228.mp4', 'lv_0_20260912181025.mp4', 'lv_0_20260914143720.mp4')
foreach ($f in $files) {
    $item = $folder.ParseName($f)
    $w = $folder.GetDetailsOf($item, 316)
    $h = $folder.GetDetailsOf($item, 314)
    $dur = $folder.GetDetailsOf($item, 27)
    Write-Output "$f -> Width: $w, Height: $h, Duration: $dur"
}
