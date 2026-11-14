param(
    [ValidateSet('Discover', 'Download')][string]$Mode = 'Download',
    [int[]]$RegionIds = (1..18),
    [switch]$Refresh
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path $projectRoot 'tool/region_landmark_sources.json'
$manifestPath = Join-Path $projectRoot 'assets/data/region_landmarks.json'
$candidatePath = Join-Path $projectRoot 'build/region_landmark_candidates.json'
$imageDirectory = Join-Path $projectRoot 'assets/images/region_landmarks'
$headers = @{ 'User-Agent' = 'Rehiyonia/1.0 (https://github.com/KMForge/rehiyonia; offline educational photo assets)' }
$utf8 = [System.Text.UTF8Encoding]::new($false)
$config = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
$allCandidates = @()
if (Test-Path -LiteralPath $candidatePath) {
    $allCandidates = Get-Content -LiteralPath $candidatePath -Raw -Encoding UTF8 | ConvertFrom-Json
}
$manifest = @()
if (Test-Path -LiteralPath $manifestPath) {
    $manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
}
New-Item -ItemType Directory -Path $imageDirectory -Force | Out-Null
New-Item -ItemType Directory -Path (Split-Path $candidatePath) -Force | Out-Null

function Plain([string]$html) {
    return [System.Net.WebUtility]::HtmlDecode(($html -replace '<[^>]+>', '')).Trim()
}
function Get-PhotoMetadata([string]$queryPart) {
    $uri = 'https://commons.wikimedia.org/w/api.php?action=query&format=json&' + $queryPart +
        '&prop=imageinfo&iiprop=url%7Cextmetadata%7Csize%7Ctimestamp%7Csha1&iiurlwidth=960'
    for ($attempt = 1; $attempt -le 5; $attempt++) {
        Start-Sleep -Seconds 7
        try {
            $response = Invoke-RestMethod -Uri $uri -Headers $headers -TimeoutSec 45
            break
        } catch {
            if ($attempt -eq 5) { throw }
            Write-Host 'Commons request paused; retrying after 45 seconds.'
            Start-Sleep -Seconds 45
        }
    }
    return @($response.query.pages.PSObject.Properties.Value | Where-Object { $_.imageinfo } | Sort-Object index)
}

foreach ($region in $config) {
    if ($region.region_id -notin $RegionIds) { continue }
    if ($Mode -eq 'Discover') {
        if (!$Refresh -and ($allCandidates | Where-Object region_id -EQ $region.region_id)) { continue }
        $search = [uri]::EscapeDataString($region.query + ' filetype:bitmap')
        $pages = Get-PhotoMetadata ('generator=search&gsrnamespace=6&gsrlimit=8&gsrsearch=' + $search)
    } else {
        if (!$region.file_title) { throw "No reviewed file title pinned for $($region.landmark)" }
        $cachedSelection = @()
        foreach ($cachedRegion in $allCandidates) {
            if ($cachedRegion.region_id -ne $region.region_id) { continue }
            foreach ($cachedPhoto in $cachedRegion.candidates) {
                if ($cachedPhoto.file_title -eq $region.file_title) { $cachedSelection += $cachedPhoto }
            }
        }
        if ($region.provider -eq 'Pexels') {
            $cachedSelection = @([PSCustomObject]@{
                file_title = $region.file_title; author = $region.author
                license = $region.license; license_url = $region.license_url
                source_url = $region.source_url; description = $region.description
                download_url = $region.download_url; original_url = $region.download_url
                original_sha1 = $null; original_timestamp = $null
            })
        }
        $pages = if (($cachedSelection.Count -and !$Refresh) -or $region.provider -eq 'Pexels') { @() } else {
            Get-PhotoMetadata ('titles=' + [uri]::EscapeDataString($region.file_title))
        }
    }
    $candidates = @()
    if ($Mode -eq 'Download' -and $cachedSelection.Count -and (!$Refresh -or $region.provider -eq 'Pexels')) { $candidates = @($cachedSelection) }
    foreach ($page in $pages) {
        $info = $page.imageinfo[0]
        $metadata = $info.extmetadata
        $license = Plain $metadata.LicenseShortName.value
        $description = Plain $metadata.ImageDescription.value
        $author = Plain $metadata.Artist.value
        if ($license -notmatch '^(CC BY|CC0|Public domain)') { continue }
        if (!$author -and $license -match '^CC BY') { continue }
        if ($info.mime -and $info.mime -notmatch '^image/(jpeg|png)$') { continue }
        if ($info.url -notmatch '(?i)\.(jpe?g|png)(\?|$)') { continue }
        if ($info.width -lt 640) { continue }
        if (($page.title + ' ' + $description) -match '(?i)(AI.generated|artificial intelligence|Midjourney|Stable.Diffusion|DALL.E|illustration|painting|engraving|coat.of.arms|^File:(Flag|Seal|Map) |satellite image)') { continue }
        $candidates += [PSCustomObject][ordered]@{
            file_title = $page.title
            author = $author
            license = $license
            license_url = $metadata.LicenseUrl.value
            source_url = $info.descriptionurl
            description = $description
            original_url = $info.url
            download_url = if ($info.thumburl) { $info.thumburl } else { $info.url }
            original_width = $info.width
            original_height = $info.height
            original_sha1 = $info.sha1
            original_timestamp = $info.timestamp
        }
    }
    if (!$candidates.Count) { throw "No licensed photograph found for region $($region.region_id)" }
    if ($Mode -eq 'Discover') {
        $allCandidates = @($allCandidates | Where-Object region_id -NE $region.region_id) + [PSCustomObject]@{ region_id = $region.region_id; landmark = $region.landmark; candidates = $candidates }
        Write-Output ("{0}: {1}" -f $region.region_id, $region.landmark)
        $candidates | Select-Object -First 3 | ForEach-Object {
            Write-Output ("  {0} [{1}] {2}" -f $_.file_title, $_.license, $_.description.Substring(0, [Math]::Min(190, $_.description.Length)))
        }
        [System.IO.File]::WriteAllText($candidatePath, (ConvertTo-Json -InputObject $allCandidates -Depth 8), $utf8)
        continue
    }

    $selected = $candidates[0]
    $assetPath = 'assets/images/region_landmarks/' + $region.filename
    $destination = Join-Path $projectRoot $assetPath
    $existing = $manifest | Where-Object region_id -EQ $region.region_id | Select-Object -First 1
    if ($existing -and !$Refresh -and (Test-Path -LiteralPath $destination) -and $existing.file_title -eq $selected.file_title) {
        Write-Output "Keeping $($region.filename)"
        continue
    }
    $downloadPath = Join-Path $projectRoot ('build/landmark-download-' + $region.region_id + '.image')
    for ($downloadAttempt = 1; $downloadAttempt -le 4; $downloadAttempt++) {
        Start-Sleep -Seconds 6
        try {
            # Originals avoid relying on the thumbnail-generation service. Resize locally.
            $photoUri = ($selected.original_url -split '\?')[0]
            if ($region.provider -eq 'Pexels') { $photoUri = $selected.download_url }
            Invoke-WebRequest -Uri $photoUri -Headers $headers -OutFile $downloadPath -UseBasicParsing -TimeoutSec 45
            break
        } catch {
            if ($downloadAttempt -eq 4) { throw "Photo download failed for region $($region.region_id); retry the script later." }
            Write-Host "Download paused for region $($region.region_id) (HTTP $([int]$_.Exception.Response.StatusCode)); waiting before retry."
            Start-Sleep -Seconds 60
        }
    }
    Add-Type -AssemblyName System.Drawing
    $photo = [System.Drawing.Image]::FromFile($downloadPath)
    try {
        if ($photo.PropertyIdList -contains 274) {
            $orientation = [BitConverter]::ToUInt16($photo.GetPropertyItem(274).Value, 0)
            switch ($orientation) {
                3 { $photo.RotateFlip([System.Drawing.RotateFlipType]::Rotate180FlipNone) }
                6 { $photo.RotateFlip([System.Drawing.RotateFlipType]::Rotate90FlipNone) }
                8 { $photo.RotateFlip([System.Drawing.RotateFlipType]::Rotate270FlipNone) }
            }
        }
        $width = [Math]::Min(960, $photo.Width)
        $height = [int][Math]::Round($photo.Height * $width / $photo.Width)
        $bitmap = [System.Drawing.Bitmap]::new($width, $height)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object MimeType -EQ 'image/jpeg'
        $parameters = [System.Drawing.Imaging.EncoderParameters]::new(1)
        $parameters.Param[0] = [System.Drawing.Imaging.EncoderParameter]::new([System.Drawing.Imaging.Encoder]::Quality, [long]85)
        try {
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.DrawImage($photo, 0, 0, $width, $height)
            $bitmap.Save($destination, $codec, $parameters)
        } finally { $graphics.Dispose(); $bitmap.Dispose(); $parameters.Dispose() }
    } finally { $photo.Dispose() }
    $credit = [ordered]@{
        region_id = $region.region_id; region_code = $region.region_code
        landmark = $region.landmark; location = $region.location; asset_path = $assetPath
        file_title = $selected.file_title; author = $selected.author
        license = $selected.license; license_url = $selected.license_url; source_url = $selected.source_url
        source_description = $selected.description; download_url = $selected.download_url
        original_url = $selected.original_url; original_sha1 = $selected.original_sha1
        original_timestamp = $selected.original_timestamp
        width = $width; height = $height
        asset_sha256 = (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash.ToLowerInvariant()
        modifications = 'Resized to at most 960px wide, EXIF orientation normalized when present, and JPEG-encoded at quality 85. UI crops with BoxFit.cover and uses muted/faded treatments for locked and background views. Adapted photographs retain the source license.'
    }
    $manifest = @($manifest | Where-Object region_id -NE $region.region_id) + [PSCustomObject]$credit
    [System.IO.File]::WriteAllText($manifestPath, (ConvertTo-Json -InputObject @($manifest | Sort-Object region_id) -Depth 8) + "`n", $utf8)
    Write-Output ("Downloaded {0}: {1} [{2}]" -f $region.region_id, $region.filename, $selected.license)
}

if ($Mode -eq 'Download' -and $manifest.Count -eq 18) {
    $complete = $true
    foreach ($pin in $config) {
        $record = $manifest | Where-Object region_id -EQ $pin.region_id
        if ($record.file_title -ne $pin.file_title) { $complete = $false }
    }
    if ($complete) {
        $lines = @(
            '# Regional landmark photographs',
            '',
            'All 18 JPEG photographs are bundled for offline use. No AI-generated or placeholder landmark images are used.',
            '',
            'Photos are attributed below and in each in-game badge detail sheet. The source license applies to each photographic adaptation independently of the application code. CC BY-SA adaptations remain under the indicated CC BY-SA version. Source pages contain the original publication and licensing records.',
            '',
            'Modifications: resized to at most 960px wide, EXIF orientation normalized when present, and JPEG-encoded at quality 85. The UI also crops with BoxFit.cover and applies muted/faded treatments to locked and background views. No landmark content is composited or generated.',
            '',
            'The manifest assets/data/region_landmarks.json retains region IDs/codes, creator names, source descriptions, source/license URLs, original revision details where supplied, dimensions, and local SHA-256 hashes.',
            '',
            'Regenerate using scripts/fetch_region_landmarks.ps1 -Mode Download. Reviewed source selections are pinned in tool/region_landmark_sources.json. Downloads occur during asset preparation only.',
            '',
            '| ID / region | Landmark and location | Local asset | Creator | License | Source |',
            '|---|---|---|---|---|---|'
        )
        foreach ($photo in ($manifest | Sort-Object region_id)) {
            $filename = Split-Path -Leaf $photo.asset_path
            $author = $photo.author -replace '\|', '\|'
            $license = $photo.license
            if ($photo.license_url) { $license = "[$license]($($photo.license_url))" }
            $lines += "| $($photo.region_id) / $($photo.region_code) | $($photo.landmark), $($photo.location) | [$filename]($filename) | $author | $license | [Original photograph]($($photo.source_url)) |"
        }
        [System.IO.File]::WriteAllText((Join-Path $imageDirectory 'README.md'), ($lines -join "`n") + "`n", $utf8)
    }
}
