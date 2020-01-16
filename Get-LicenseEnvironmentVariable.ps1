Set-Variable -Name 'Path' -Value $PSScriptRoot'\license.xml'
Set-Variable -Name 'OutFilePath' -Value $PSScriptRoot'\license-output.txt'

Write-Host $Path

$licenseFileBytes = [System.IO.File]::ReadAllBytes($Path)
$licenseString = $null

try {
    $memory = [System.IO.MemoryStream]::new()

    # Gzip license file content
    $gzip = [System.IO.Compression.GZipStream]::new(
        $memory,
        [System.IO.Compression.CompressionLevel]::Optimal,
        $true
    )

    $gzip.Write($licenseFileBytes, 0, $licenseFileBytes.Length);

    $gzip.Close()

    # Base64 encode the gzipped content
    $licenseString = [System.Convert]::ToBase64String($memory.ToArray())
} finally {
    # Cleanup
    if ($null -ne $gzip) {
        $gzip.Dispose()
        $gzip = $null
    }

    if ($null -ne $memory) {
        $memory.Dispose()
        $memory = $null
    }

    $licenseFileBytes = $null
}

# Sanity check
if ($licenseString.Length -le 100) {
    throw "Unknown error, the gzipped and base64 encoded string '$licenseString' is too short."
}

Set-Content -Path $OutFilePath -Value $licenseString

Write-Host 'Encoded license string has been output to '$OutFilePath
