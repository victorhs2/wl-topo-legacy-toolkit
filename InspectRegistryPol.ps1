param(
    [Parameter(Mandatory=$true)]
    [string]$Path,

    [Parameter(Mandatory=$true)]
    [string]$Needle,

    [int]$BytesAfter = 80
)

# Read-only helper for old Windows / PowerShell environments.
# It does not modify Registry.pol or the Windows Registry.

if (-not (Test-Path -LiteralPath $Path)) {
    Write-Host "File not found: $Path"
    exit 1
}

$bytes = [System.IO.File]::ReadAllBytes($Path)
$unicode = [System.Text.Encoding]::Unicode.GetString($bytes)

Write-Host "File: $Path"
Write-Host "Size: $($bytes.Length) bytes"
Write-Host "Needle: $Needle"
Write-Host "Unicode string present: $($unicode.Contains($Needle))"

$needleBytes = [System.Text.Encoding]::Unicode.GetBytes($Needle)
$pos = -1

for ($n = 0; $n -le $bytes.Length - $needleBytes.Length; $n++) {
    $ok = $true

    for ($j = 0; $j -lt $needleBytes.Length; $j++) {
        if ($bytes[$n + $j] -ne $needleBytes[$j]) {
            $ok = $false
            break
        }
    }

    if ($ok) {
        $pos = $n
        break
    }
}

if ($pos -lt 0) {
    Write-Host "Byte sequence not found."
    exit 0
}

Write-Host "Byte position: $pos"
Write-Host ""
Write-Host "Hex dump:"

$end = [Math]::Min($pos + $BytesAfter, $bytes.Length - 1)

for ($i = $pos; $i -le $end; $i += 16) {
    $lineEnd = [Math]::Min($i + 15, $end)
    $line = $bytes[$i..$lineEnd]
    $hex = (($line | ForEach-Object { $_.ToString("X2") }) -join " ")
    "{0:X8}  {1}" -f $i, $hex
}
