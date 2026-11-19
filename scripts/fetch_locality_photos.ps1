# Downloads only the versioned, reviewed source records. No search result is
# automatically promoted to an installed photo. Run register_locality_photos.dart
# afterwards to update bundled paths, captions and the attribution report.
param([switch]$Refresh, [string]$SourceCache)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$candidates = Get-Content "$root/tool/locality_photo_candidates.json" -Raw -Encoding UTF8 | ConvertFrom-Json
$creditsPath = Join-Path $root 'assets/data/locality_photo_credits.json'
$credits = @()
if (Test-Path $creditsPath) { $credits = Get-Content $creditsPath -Raw -Encoding UTF8 | ConvertFrom-Json }
$headers = @{ 'User-Agent' = 'RehiyoniaEducationalAssets/1.0 (https://github.com/KMForge/rehiyonia; offline photo attribution retained)' }
$utf8 = [Text.UTF8Encoding]::new($false)
Add-Type -AssemblyName System.Drawing
foreach ($candidate in $candidates) {
    if (!$candidate.download_url) { Write-Output "Photo pending: $($candidate.region_id):$($candidate.word)"; continue }
    if ($candidate.region_id -lt 1 -or $candidate.region_id -gt 18 -or $candidate.word -cnotmatch '^[A-Z]+$' -or
        !$candidate.author -or $candidate.license -notmatch '^(CC BY|CC0|Public domain)') {
        throw 'Invalid reviewed photograph metadata'
    }
    $asset = 'assets/images/localities/region_{0}_{1}.jpg' -f $candidate.region_id, $candidate.word.ToLowerInvariant()
    $destination = Join-Path $root $asset
    $existing = $credits | Where-Object { $_.region_id -eq $candidate.region_id -and $_.word -eq $candidate.word } | Select-Object -First 1
    if (!$Refresh -and $existing -and (Test-Path $destination) -and $existing.source_url -eq $candidate.source_url -and
        (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash.ToLowerInvariant() -eq $existing.asset_sha256) { continue }
    $temporaryPhoto = [IO.Path]::GetTempFileName()
    $extractedPhoto = $null
    try {
        $downloaded = $false
        if ($SourceCache -and $candidate.source_sha256) {
            $cached = Join-Path $SourceCache ('region_{0}_{1}.source' -f $candidate.region_id, $candidate.word.ToLowerInvariant())
            if (Test-Path -LiteralPath $cached) {
                if ((Get-FileHash -LiteralPath $cached -Algorithm SHA256).Hash.ToLowerInvariant() -ne $candidate.source_sha256) {
                    throw "Reviewed source cache hash mismatch: $($candidate.word)"
                }
                Copy-Item -LiteralPath $cached -Destination $temporaryPhoto
                $downloaded = $true
            }
        }
        foreach ($url in @($candidate.download_url, $candidate.original_url) | Select-Object -Unique) {
            if ($downloaded) { break }
            try {
                $timeout = if ($candidate.pdf_image_object) { 240 } else { 45 }
                Invoke-WebRequest $url -Headers $headers -OutFile $temporaryPhoto -UseBasicParsing -TimeoutSec $timeout
                $downloaded = $true; break
            } catch {
                Write-Output "Source unavailable for $($candidate.word): $($_.Exception.Message)"
                if ($_.Exception.Response -and [int]$_.Exception.Response.StatusCode -eq 429) {
                    # Stop this asset's requests when the source asks us to slow down.
                    break
                }
            }
        }
        if (!$downloaded) { continue }
        if ($candidate.source_sha256 -and
            (Get-FileHash -LiteralPath $temporaryPhoto -Algorithm SHA256).Hash.ToLowerInvariant() -ne $candidate.source_sha256) {
            throw "Downloaded source changed; review it before installing: $($candidate.word)"
        }
        $imageSource = $temporaryPhoto
        if ($candidate.pdf_image_object) {
            $extractedPhoto = [IO.Path]::GetTempFileName()
            & dart "$root/scripts/extract_pdf_photo.dart" $temporaryPhoto $candidate.pdf_image_object $extractedPhoto
            if ($LASTEXITCODE -ne 0) { throw 'PDF photograph extraction failed' }
            $imageSource = $extractedPhoto
        }
        $photo = [Drawing.Image]::FromFile($imageSource)
        $scale = [Math]::Min(1.0, 960.0 / [Math]::Max($photo.Width, $photo.Height))
        $width = [Math]::Max(1, [int][Math]::Round($photo.Width * $scale))
        $height = [Math]::Max(1, [int][Math]::Round($photo.Height * $scale))
        $bitmap = [Drawing.Bitmap]::new($width, $height)
        $graphics = [Drawing.Graphics]::FromImage($bitmap)
        try {
            $graphics.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.DrawImage($photo, 0, 0, $width, $height)
            $encoder = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object MimeType -EQ 'image/jpeg'
            $parameters = [Drawing.Imaging.EncoderParameters]::new(1)
            $parameters.Param[0] = [Drawing.Imaging.EncoderParameter]::new([Drawing.Imaging.Encoder]::Quality, [long]85)
            try { $bitmap.Save($destination, $encoder, $parameters) } finally { $parameters.Dispose() }
        } finally { $graphics.Dispose(); $bitmap.Dispose(); $photo.Dispose() }
        $record = [ordered]@{}
        foreach ($property in $candidate.PSObject.Properties) { $record[$property.Name] = $property.Value }
        $record.asset_path = $asset; $record.width = $width; $record.height = $height
        $record.asset_sha256 = (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash.ToLowerInvariant()
        $record.modifications = 'Resized without enlargement to fit within 960 x 960 pixels and JPEG-encoded at quality 85. Adapted photographs retain their original source license.'
        if ($candidate.pdf_image_object) {
            $record.modifications = "Original JPEG extracted losslessly from PDF image object $($candidate.pdf_image_object); " + $record.modifications
        }
        $credits = @($credits | Where-Object { !($_.region_id -eq $candidate.region_id -and $_.word -eq $candidate.word) }) + [PSCustomObject]$record
        [IO.File]::WriteAllText($creditsPath,(ConvertTo-Json -InputObject @($credits) -Depth 15),$utf8)
        Write-Output "Downloaded $($candidate.region_id):$($candidate.word) -> $asset"
    } finally {
        Remove-Item -LiteralPath $temporaryPhoto
        if ($extractedPhoto) { Remove-Item -LiteralPath $extractedPhoto }
    }
}
Write-Output "Downloaded locality photo records: $($credits.Count) / $($candidates.Count)"
