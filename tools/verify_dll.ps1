param(
    [Parameter(Mandatory = $true)]
    [string]$DllPath
)

$ErrorActionPreference = "Stop"

function Get-PeSections {
    param([byte[]]$Bytes)

    $peOffset = [BitConverter]::ToInt32($Bytes, 0x3C)
    $numSections = [BitConverter]::ToInt16($Bytes, $peOffset + 6)
    $optionalHeaderSize = [BitConverter]::ToInt16($Bytes, $peOffset + 20)
    $optionalHeader = $peOffset + 24
    $sectionTable = $optionalHeader + $optionalHeaderSize
    $sections = @()

    for ($i = 0; $i -lt $numSections; $i++) {
        $off = $sectionTable + ($i * 40)
        $name = [Text.Encoding]::ASCII.GetString($Bytes, $off, 8).Trim([char]0)
        $sections += [PSCustomObject]@{
            Name = $name
            VirtualSize = [BitConverter]::ToUInt32($Bytes, $off + 8)
            VirtualAddress = [BitConverter]::ToUInt32($Bytes, $off + 12)
            RawSize = [BitConverter]::ToUInt32($Bytes, $off + 16)
            RawPtr = [BitConverter]::ToUInt32($Bytes, $off + 20)
        }
    }

    return [PSCustomObject]@{
        Characteristics = [BitConverter]::ToUInt16($Bytes, $peOffset + 22)
        ExportRva = [BitConverter]::ToUInt32($Bytes, $optionalHeader + 112)
        Sections = $sections
    }
}

function Get-PeExportNames {
    param(
        [byte[]]$Bytes,
        [object[]]$Sections
    )

    $peInfo = Get-PeSections $Bytes
    if ($peInfo.ExportRva -eq 0) {
        return @()
    }

    $textSection = $Sections | Where-Object { $_.Name -eq ".text" } | Select-Object -First 1
    $rvaToOffset = {
        param([uint32]$Rva)
        foreach ($section in $Sections) {
            $sectionEnd = $section.VirtualAddress + [Math]::Max($section.VirtualSize, $section.RawSize)
            if ($Rva -ge $section.VirtualAddress -and $Rva -lt $sectionEnd) {
                return [int64]$section.RawPtr + ($Rva - $section.VirtualAddress)
            }
        }
        throw "RVA 0x{0:X} not mapped" -f $Rva
    }

    $exportOffset = & $rvaToOffset $peInfo.ExportRva
    $nameCount = [BitConverter]::ToUInt32($Bytes, $exportOffset + 24)
    $namesRva = [BitConverter]::ToUInt32($Bytes, $exportOffset + 32)
    $namesOffset = & $rvaToOffset $namesRva
    $names = New-Object System.Collections.Generic.List[string]

    for ($i = 0; $i -lt $nameCount; $i++) {
        $nameRva = [BitConverter]::ToUInt32($Bytes, $namesOffset + ($i * 4))
        $nameOffset = & $rvaToOffset $nameRva
        $chars = New-Object System.Collections.Generic.List[byte]
        for ($j = $nameOffset; $Bytes[$j] -ne 0; $j++) {
            $chars.Add($Bytes[$j])
        }
        $names.Add([Text.Encoding]::ASCII.GetString($chars.ToArray()))
    }

    return ,$names.ToArray()
}

Write-Host "Verifying $DllPath"

if (-not (Test-Path $DllPath)) {
    throw "DLL not found: $DllPath"
}

$bytes = [System.IO.File]::ReadAllBytes($DllPath)
$ascii = [Text.Encoding]::ASCII.GetString($bytes)
$pe = Get-PeSections $bytes
$sections = $pe.Sections

if (($pe.Characteristics -band 0x2000) -eq 0) {
    throw "Not a DLL (IMAGE_FILE_DLL flag missing)"
}
Write-Host "[OK] PE headers indicate DLL"

$exportNames = Get-PeExportNames $bytes $sections
$requiredExports = @(
    "BF_Ping",
    "BF_Hello",
    "BF_Add",
    "BF_AutoMessage",
    "BF_HelloWorld",
    "BF_GetLastOutput",
    "BF_SetOutputCallback"
)
foreach ($symbol in $requiredExports) {
    if ($exportNames -notcontains $symbol) {
        throw "Missing export: $symbol"
    }
}
Write-Host "[OK] Required exports present"

$text = $sections | Where-Object { $_.Name -eq ".text" } | Select-Object -First 1
$rdata = $sections | Where-Object { $_.Name -eq ".rdata" } | Select-Object -First 1
$rsrc = $sections | Where-Object { $_.Name -eq ".rsrc" } | Select-Object -First 1

if (-not $text) {
    throw ".text section missing"
}
Write-Host ("[OK] .text RawSize = {0} bytes" -f $text.RawSize)

if ($rsrc -and $rsrc.RawSize -gt 512) {
    throw ".rsrc too large - possible resource embedding"
}
Write-Host "[OK] No large .rsrc section"

$coreFragments = @(
    @{ Name = "add.bf"; Pattern = ">[-<+>]" },
    @{ Name = "auto_message.bf"; Pattern = "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++.++++++++++++++++++++++++++++++++++++++++++++++++++++." },
    @{ Name = "hello.bf"; Pattern = "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++." },
    @{ Name = "hello_world.bf"; Pattern = "++++++++[>++++[>++>+++>+++>+<<<<-]" }
)

foreach ($frag in $coreFragments) {
    $offset = $ascii.IndexOf($frag.Pattern)
    if ($offset -lt 0) {
        throw ("Notepad test failed: {0} fragment not found in DLL" -f $frag.Name)
    }

    $inText = ($offset -ge $text.RawPtr) -and ($offset -lt ($text.RawPtr + $text.RawSize))
    if (-not $inText) {
        throw ("Fragment {0} at offset 0x{1:X} is outside .text" -f $frag.Name, $offset)
    }
    Write-Host ("[OK] {0} plaintext found in .text at file offset 0x{1:X}" -f $frag.Name, $offset)
}

if ($rdata) {
    $rdataBytes = $bytes[$rdata.RawPtr..($rdata.RawPtr + $rdata.RawSize - 1)]
    $rdataAscii = [Text.Encoding]::ASCII.GetString($rdataBytes)
    foreach ($frag in $coreFragments) {
        if ($rdataAscii.Contains($frag.Pattern)) {
            throw ("{0} fragment found in .rdata - disguised DLL" -f $frag.Name)
        }
    }
    Write-Host "[OK] BF program not in .rdata"
}

Write-Host "All verification checks passed."
