param([switch]$Refresh, [int[]]$RegionIds = (1..18))

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$dataPath = Join-Path $projectRoot 'assets/data/regional_culture.json'
$creditsPath = Join-Path $projectRoot 'assets/data/culture_image_credits.json'
$imageDirectory = Join-Path $projectRoot 'assets/images/trivia'
$headers = @{ 'User-Agent' = 'RehiyoniaEducationalAssets/1.0 (offline educational game; Wikimedia Commons attribution retained)' }
$utf8 = New-Object System.Text.UTF8Encoding($false)
Add-Type -AssemblyName System.Drawing
$regions = Get-Content -LiteralPath $dataPath -Raw -Encoding UTF8 | ConvertFrom-Json
$credits = @()
$fallbackSearches = @{
    1 = 'Chinese New Year Binondo'; 2 = 'Panagbenga'; 3 = 'Inabel';
    4 = 'Vakul'; 5 = 'Giant Lantern Festival'; 6 = 'Pahiyas';
    7 = 'Moriones'; 8 = 'Penafrancia procession'; 9 = 'Ati-Atihan';
    10 = 'Sinulog'; 11 = 'Pintados'; 12 = 'Regatta Zamboanga';
    13 = 'Kaamulan'; 14 = 'Kadayawan'; 15 = 'Tnalak';
    16 = 'Bonok-Bonok'; 17 = 'Torogan'; 18 = 'MassKara'
}
if (Test-Path -LiteralPath $creditsPath) {
    $credits = Get-Content -LiteralPath $creditsPath -Raw -Encoding UTF8 | ConvertFrom-Json
}
New-Item -ItemType Directory -Path $imageDirectory -Force | Out-Null

function Get-PlainText([string]$html) {
    return [System.Net.WebUtility]::HtmlDecode(($html -replace '<[^>]+>', '')).Trim()
}

foreach ($region in $regions) {
    if ($region.region_id -notin $RegionIds) { continue }
    if ($null -eq $region.region_id -or $region.region_id -lt 1 -or $region.region_id -gt 18) {
        throw 'Invalid culture content: expected one entry per region (1 through 18).'
    }
    $existing = $credits | Where-Object region_id -EQ $region.region_id | Select-Object -First 1
    if ($existing -and !$Refresh -and (Test-Path (Join-Path $projectRoot $existing.asset_path))) {
        Write-Output "Keeping region $($region.region_id): $($existing.file_title)"
        continue
    }
    $candidates = @()
    foreach ($search in @($region.image_search, $fallbackSearches[[int]$region.region_id])) {
        $query = [Uri]::EscapeDataString("$search filetype:bitmap")
        $uri = "https://commons.wikimedia.org/w/api.php?action=query&format=json&generator=search&gsrsearch=$query&gsrnamespace=6&gsrlimit=8&prop=imageinfo&iiprop=url%7Cextmetadata&iiurlwidth=800"
        if ($region.image_file_title) {
            $title = [Uri]::EscapeDataString($region.image_file_title)
            $uri = "https://commons.wikimedia.org/w/api.php?action=query&format=json&titles=$title&prop=imageinfo&iiprop=url%7Cextmetadata&iiurlwidth=800"
        }
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -TimeoutSec 45
        $candidates = @($response.query.pages.PSObject.Properties.Value |
            Where-Object { $_.imageinfo -and $_.title -notmatch '(?i)(stamp|coin|logo|seal|map|flag)' } |
            Sort-Object index)
        $candidates = @($candidates | Where-Object {
            $_.imageinfo[0].extmetadata.LicenseShortName.value -match '^(CC BY|CC0|Public domain)' -and
            $_.imageinfo[0].thumburl -match '\.(jpg|jpeg|png)(\?|$)'
        })
        if ($candidates.Count -gt 0) { break }
    }
    if (!$candidates.Count) { throw "No reusable photo found for region $($region.region_id): $($region.topic)" }
    $selected = $candidates[0]
    $info = $selected.imageinfo[0]
    $assetPath = "assets/images/trivia/region_$($region.region_id).jpg"
    $destination = Join-Path $projectRoot $assetPath
    for ($attempt = 1; $attempt -le 3; $attempt++) {
        try {
            $downloadUrl = if ($attempt -eq 1) { $info.thumburl } else { $info.url }
            Invoke-WebRequest -Uri $downloadUrl -Headers $headers -OutFile $destination -UseBasicParsing -TimeoutSec 45
            break
        } catch {
            if ($attempt -eq 3) { throw }
            Write-Output "Waiting before retrying region $($region.region_id) download..."
            Start-Sleep -Seconds 20
        }
    }
    $stream = New-Object System.IO.MemoryStream(,[System.IO.File]::ReadAllBytes($destination))
    $photo = [System.Drawing.Image]::FromStream($stream)
    $width = [Math]::Min(960, $photo.Width)
    $height = [int][Math]::Round($photo.Height * $width / $photo.Width)
    $bitmap = New-Object System.Drawing.Bitmap($width, $height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.DrawImage($photo, 0, 0, $width, $height)
        $bitmap.Save($destination, [System.Drawing.Imaging.ImageFormat]::Jpeg)
    } finally {
        $graphics.Dispose(); $bitmap.Dispose(); $photo.Dispose(); $stream.Dispose()
    }
    $author = Get-PlainText $info.extmetadata.Artist.value
    $license = Get-PlainText $info.extmetadata.LicenseShortName.value
    if (!$author) { $author = 'Wikimedia Commons contributor (see source)' }
    $credit = [ordered]@{
        region_id = $region.region_id
        asset_path = $assetPath
        file_title = $selected.title
        author = $author
        license = $license
        license_url = $info.extmetadata.LicenseUrl.value
        source_url = $info.descriptionurl
        download_url = $info.thumburl
        modifications = 'Resized to at most 960px wide and encoded as JPEG; original proportions preserved.'
    }
    $credits = @($credits | Where-Object region_id -NE $region.region_id) + [PSCustomObject]$credit
    $region | Add-Member -NotePropertyName image_path -NotePropertyValue $assetPath -Force
    $region | Add-Member -NotePropertyName image_credit -NotePropertyValue "$author / $license / Wikimedia Commons" -Force
    [System.IO.File]::WriteAllText($creditsPath, (ConvertTo-Json -InputObject @($credits | Sort-Object region_id) -Depth 8) + "`n", $utf8)
    [System.IO.File]::WriteAllText($dataPath, ($regions | ConvertTo-Json -Depth 8) + "`n", $utf8)
    Write-Output "Region $($region.region_id): $($selected.title) [$license]"
    Start-Sleep -Seconds 2
}
