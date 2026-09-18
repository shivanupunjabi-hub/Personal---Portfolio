$shell = New-Object -ComObject Shell.Application
$folder = $shell.Namespace('C:\Users\SHIVANU\Downloads\PORTFOLIO WEBSITE\assets\projects')
$item = $folder.ParseName('lv_0_20260908063228.mp4')
for ($i = 0; $i -lt 320; $i++) {
    $name = $folder.GetDetailsOf($null, $i)
    $val = $folder.GetDetailsOf($item, $i)
    if ($val) {
        Write-Output "${i} [${name}]: ${val}"
    }
}
