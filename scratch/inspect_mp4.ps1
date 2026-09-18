$files = @(
    'C:\Users\SHIVANU\Downloads\PORTFOLIO WEBSITE\assets\projects\lv_0_20260908063228.mp4',
    'C:\Users\SHIVANU\Downloads\PORTFOLIO WEBSITE\assets\projects\lv_0_20260912181025.mp4',
    'C:\Users\SHIVANU\Downloads\PORTFOLIO WEBSITE\assets\projects\lv_0_20260914143720.mp4'
)

foreach ($path in $files) {
    $fname = [System.IO.Path]::GetFileName($path)
    $fs = [System.IO.File]::OpenRead($path)
    $len = $fs.Length
    Write-Output "=== File: $fname (Size: $len bytes) ==="

    # Read top-level atoms
    $pos = 0
    $moovPos = -1
    $mdatPos = -1
    $br = New-Object System.IO.BinaryReader($fs)
    while ($pos -lt $len - 8) {
        $fs.Position = $pos
        $sizeBytes = $br.ReadBytes(4)
        [Array]::Reverse($sizeBytes)
        $atomSize = [System.BitConverter]::ToUInt32($sizeBytes, 0)

        $nameBytes = $br.ReadBytes(4)
        $atomName = [System.Text.Encoding]::ASCII.GetString($nameBytes)

        Write-Output "Atom at pos $pos : $atomName (size $atomSize)"
        if ($atomName -eq 'moov') { $moovPos = $pos }
        if ($atomName -eq 'mdat') { $mdatPos = $pos }

        if ($atomSize -eq 0) { break } # till EOF
        if ($atomSize -eq 1) { # 64-bit size
            $size64Bytes = $br.ReadBytes(8)
            [Array]::Reverse($size64Bytes)
            $atomSize = [System.BitConverter]::ToUInt64($size64Bytes, 0)
        }
        $pos += $atomSize
    }

    # Search for codec fourcc (avc1, hvc1, hev1, etc.)
    $fs.Position = 0
    $sample = New-Object byte[] ([Math]::Min(1024*1024*4, $len))
    $read = $fs.Read($sample, 0, $sample.Length)
    $sampleStr = [System.Text.Encoding]::ASCII.GetString($sample)
    
    $codecs = @('avc1', 'hvc1', 'hev1', 'mp4a', 'aac ', 'vp09', 'av01')
    $found = @()
    foreach ($c in $codecs) {
        if ($sampleStr.Contains($c)) { $found += $c }
    }

    # Also check end of file (last 4MB) if moov is at end
    if ($moovPos -gt ($len - 1024*1024*10)) {
        $fs.Position = [Math]::Max(0, $len - 1024*1024*4)
        $sampleEnd = New-Object byte[] ($len - $fs.Position)
        $fs.Read($sampleEnd, 0, $sampleEnd.Length) | Out-Null
        $sampleEndStr = [System.Text.Encoding]::ASCII.GetString($sampleEnd)
        foreach ($c in $codecs) {
            if ($sampleEndStr.Contains($c) -and -not ($found -contains $c)) { $found += $c }
        }
    }

    Write-Output "Codecs found in $fname : $($found -join ', ')"
    Write-Output "moov pos: $moovPos, mdat pos: $mdatPos"
    $fs.Close()
}
