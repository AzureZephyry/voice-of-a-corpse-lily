$ErrorActionPreference = 'Stop'
# Extract Krita's own saved projection without modifying or resaving Wayne's KRA.
$classroomProject = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../..'))
$classroomSource = Join-Path $PSScriptRoot 'classroom.kra'
$classroomOutput = Join-Path $classroomProject 'assets/environments/classroom/classroom_normal.png'
$classroomBefore = (Get-FileHash -LiteralPath $classroomSource -Algorithm SHA256).Hash
Add-Type -AssemblyName System.IO.Compression.FileSystem
$classroomArchive = [IO.Compression.ZipFile]::OpenRead($classroomSource)
try {
    $classroomEntry = $classroomArchive.GetEntry('mergedimage.png')
    if ($null -eq $classroomEntry) { throw 'KRA has no saved merged projection.' }
    $classroomStream = $classroomEntry.Open()
    $classroomBytes = [IO.MemoryStream]::new()
    try { $classroomStream.CopyTo($classroomBytes); $classroomPng = $classroomBytes.ToArray() }
    finally { $classroomStream.Dispose(); $classroomBytes.Dispose() }
} finally { $classroomArchive.Dispose() }
$classroomSignature = [Convert]::ToHexString($classroomPng[0..7])
if ($classroomSignature -ne '89504E470D0A1A0A') { throw 'Projection is not a PNG.' }
$classroomWidth = ([int]$classroomPng[16] -shl 24) -bor ([int]$classroomPng[17] -shl 16) -bor ([int]$classroomPng[18] -shl 8) -bor [int]$classroomPng[19]
$classroomHeight = ([int]$classroomPng[20] -shl 24) -bor ([int]$classroomPng[21] -shl 16) -bor ([int]$classroomPng[22] -shl 8) -bor [int]$classroomPng[23]
if ($classroomWidth -ne 1280 -or $classroomHeight -ne 960) { throw "Artwork dimensions changed to ${classroomWidth}x${classroomHeight}; review framing before exporting." }
[IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($classroomOutput)) | Out-Null
[IO.File]::WriteAllBytes($classroomOutput, $classroomPng)
$classroomExpected = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($classroomPng))
if ((Get-FileHash -LiteralPath $classroomOutput).Hash -ne $classroomExpected) { throw 'PNG bytes do not match the saved projection.' }
if ((Get-FileHash -LiteralPath $classroomSource).Hash -ne $classroomBefore) { throw 'KRA source hash changed.' }
Write-Output "Lossless export verified: ${classroomWidth}x${classroomHeight}; source KRA unchanged."
