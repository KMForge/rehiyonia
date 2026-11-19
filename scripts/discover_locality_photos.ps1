param([switch]$Refresh)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$pins = Get-Content (Join-Path $projectRoot 'tool/locality_photo_sources.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$cache = Join-Path $projectRoot 'tool/.locality-photo-cache'
New-Item -ItemType Directory -Path $cache -Force | Out-Null
$utf8 = [System.Text.UTF8Encoding]::new($false)
$headers = @{ 'User-Agent' = 'RehiyoniaEducationalAssets/1.0 (https://github.com/KMForge/rehiyonia; offline educational photo attribution)' }
function Json-Request([string]$Uri, [string]$CacheName) {
    $path = Join-Path $cache $CacheName
    if ((Test-Path -LiteralPath $path) -and !$Refresh) {
        return Get-Content $path -Raw -Encoding UTF8 | ConvertFrom-Json
    }
    for ($attempt = 0; $attempt -lt 5; $attempt++) {
        try {
            $response = Invoke-RestMethod -Uri $Uri -Headers $headers -TimeoutSec 45
            [System.IO.File]::WriteAllText($path, (ConvertTo-Json -InputObject $response -Depth 35), $utf8)
            return $response
        } catch {
            if ($attempt -eq 4) { throw }
            $delay = 30
            if ($_.Exception.Response -and $_.Exception.Response.Headers['Retry-After']) {
                $parsedDelay = 0
                if ([int]::TryParse($_.Exception.Response.Headers['Retry-After'], [ref]$parsedDelay)) {
                    $delay = [Math]::Max(10, $parsedDelay)
                }
            }
            Write-Output "Waiting $delay seconds for Wikimedia API retry policy..." | Out-Host
            Start-Sleep -Seconds $delay
        }
    }
}
function Plain([string]$Html) { [System.Net.WebUtility]::HtmlDecode(($Html -replace '<[^>]+>', '')).Trim() }
function Is-PhotoName([string]$Title) {
    return $Title -match '(?i)\.(jpg|jpeg|png)$' -and
        $Title -notmatch '(?i)(seal|flag|logo|coat.of.arms|locator|\bmap\b|ph cordillera|pushpin|wikimedia|commons-logo|icon|blason|escudo)'
}
function Is-ReusablePhoto($Info) {
    if (!$Info -or !$Info.extmetadata.Artist.value -or
        (Plain $Info.extmetadata.LicenseShortName.value) -notmatch '^(CC BY|CC0|Public domain)' -or
        $Info.url -notmatch '(?i)\.(jpg|jpeg|png)(\?|$)') { return $false }
    $description = Plain $Info.extmetadata.ImageDescription.value
    return $description -notmatch '(?i)((political|barangay|locator|administrative) map|official logo|coat of arms|location of .*region|sunset seen from kanlaon)'
}
$titles = [Uri]::EscapeDataString((@($pins | ForEach-Object { $_[2] }) -join '|'))
$wiki = Json-Request "https://en.wikipedia.org/w/api.php?action=query&format=json&redirects=1&titles=$titles&prop=pageimages%7Ccoordinates%7Cextracts%7Cimages&piprop=name&pilicense=free&colimit=max&coprimary=primary&exintro=1&explaintext=1&exsentences=2&exlimit=max&imlimit=500" 'wikipedia_v2.json'
$pages = @($wiki.query.pages.PSObject.Properties.Value)
$imageContinuation = $wiki.continue.imcontinue
$imageBatch = 0
while ($imageContinuation) {
    $imageBatch++
    $next = [Uri]::EscapeDataString($imageContinuation)
    $extraImages = Json-Request "https://en.wikipedia.org/w/api.php?action=query&format=json&redirects=1&titles=$titles&prop=images&imlimit=500&imcontinue=$next&continue=%7C%7C" "wikipedia_images_$imageBatch.json"
    foreach ($extraPage in $extraImages.query.pages.PSObject.Properties.Value) {
        $page = $pages | Where-Object { $_.title -eq $extraPage.title } | Select-Object -First 1
        if ($page -and $extraPage.images) {
            $combined = @($page.images) + @($extraPage.images)
            $page | Add-Member -NotePropertyName images -NotePropertyValue $combined -Force
        }
    }
    $imageContinuation = $extraImages.continue.imcontinue
}
$aliases = @{}
foreach ($entry in @($wiki.query.normalized) + @($wiki.query.redirects)) {
    if ($entry.from) { $aliases[$entry.from] = $entry.to }
}
$localities = @()
$fileNames = [System.Collections.Generic.HashSet[string]]::new()
foreach ($pin in $pins) {
    $title = [string]$pin[2]
    for ($i = 0; $i -lt 5 -and $aliases.ContainsKey($title); $i++) { $title = $aliases[$title] }
    $page = $pages | Where-Object { $_.title -eq $title } | Select-Object -First 1
    if (!$page -or !$page.coordinates) {
        $single = [Uri]::EscapeDataString([string]$pin[2])
        $extra = Json-Request "https://en.wikipedia.org/w/api.php?action=query&format=json&redirects=1&titles=$single&prop=pageimages%7Ccoordinates%7Cextracts%7Cimages&piprop=name&pilicense=free&colimit=max&coprimary=primary&exintro=1&explaintext=1&exsentences=2&imlimit=50" "locality_$($pin[0])_$($pin[1]).json"
        $page = $extra.query.pages.PSObject.Properties.Value | Select-Object -First 1
    }
    if (!$page -or $null -ne $page.missing -or !$page.coordinates) { throw "Unresolved locality: $($pin[2])" }
    $position = $page.coordinates[0]
    if ($position.lat -lt 4 -or $position.lat -gt 22 -or $position.lon -lt 116 -or $position.lon -gt 128) {
        throw "Locality outside Philippine bounds: $($pin[2])"
    }
    $choices = [System.Collections.Generic.List[string]]::new()
    if ($page.pageimage) {
        $primary = 'File:' + $page.pageimage.Replace('_', ' ')
        if (Is-PhotoName $primary) { $choices.Add($primary) }
    }
    $town = ($page.title -split ',')[0] -replace '(?i) City$', ''
    $images = @($page.images | Where-Object { Is-PhotoName $_.title } |
        Sort-Object @{ Expression = { if ($_.title -match [regex]::Escape($town)) { 0 } else { 1 } } })
    foreach ($image in $images | Select-Object -First 5) {
        if (!$choices.Contains($image.title)) { $choices.Add($image.title) }
    }
    foreach ($choice in $choices) { [void]$fileNames.Add($choice) }
    $localities += [PSCustomObject]@{ pin = $pin; page = $page; choices = @($choices) }
}
$files = @($fileNames | Sort-Object)
$infoByTitle = @{}
for ($offset = 0; $offset -lt $files.Count; $offset += 40) {
    $last = [Math]::Min($offset + 39, $files.Count - 1)
    $encoded = [Uri]::EscapeDataString(($files[$offset..$last] -join '|'))
    $batchHash = [System.BitConverter]::ToString([System.Security.Cryptography.SHA256]::Create().ComputeHash([System.Text.Encoding]::UTF8.GetBytes(($files[$offset..$last] -join '|')))).Replace('-', '').Substring(0, 12)
    $response = Json-Request "https://commons.wikimedia.org/w/api.php?action=query&format=json&redirects=1&titles=$encoded&prop=imageinfo&iiprop=url%7Csize%7Cextmetadata&iiurlwidth=960" "commons_$batchHash.json"
    foreach ($page in $response.query.pages.PSObject.Properties.Value) {
        if ($page.imageinfo) { $infoByTitle[$page.title] = $page.imageinfo[0] }
    }
    foreach ($alias in @($response.query.normalized) + @($response.query.redirects)) {
        if ($alias.from -and $infoByTitle.ContainsKey($alias.to)) { $infoByTitle[$alias.from] = $infoByTitle[$alias.to] }
    }
    Write-Output "Reviewed Commons metadata $offset to $last of $($files.Count) files"
}
$result = @()
foreach ($locality in $localities) {
    $pin = $locality.pin; $page = $locality.page
    $selected = $null; $file = ''
    foreach ($choice in $locality.choices) {
        $candidate = $infoByTitle[$choice]
        if (Is-ReusablePhoto $candidate) {
            $selected = $candidate; $file = $choice; break
        }
    }
    if (!$selected) {
        $town = ($page.title -split ',')[0]
        $query = [Uri]::EscapeDataString(('"{0}" "{1}" filetype:bitmap -intitle:map -intitle:seal -intitle:flag' -f $town, $pin[3]))
        $search = Json-Request "https://commons.wikimedia.org/w/api.php?action=query&format=json&generator=search&gsrsearch=$query&gsrnamespace=6&gsrlimit=8&prop=imageinfo&iiprop=url%7Cextmetadata&iiurlwidth=960" "search_$($pin[0])_$($pin[1]).json"
        foreach ($candidatePage in $search.query.pages.PSObject.Properties.Value | Sort-Object index) {
            if ((Is-PhotoName $candidatePage.title) -and (Is-ReusablePhoto $candidatePage.imageinfo[0])) {
                $selected = $candidatePage.imageinfo[0]; $file = $candidatePage.title; break
            }
        }
    }
    $record = [PSCustomObject][ordered]@{
        region_id = [int]$pin[0]; word = [string]$pin[1]; locality_title = $page.title
        province = [string]$pin[3]; wikipedia_title = [string]$pin[2]
        locality_url = 'https://en.wikipedia.org/wiki/' + [Uri]::EscapeDataString($page.title.Replace(' ', '_'))
        latitude = $page.coordinates[0].lat; longitude = $page.coordinates[0].lon; locality_description = $page.extract
        file_title = $file; photo_description = if ($selected) { Plain $selected.extmetadata.ImageDescription.value } else { '' }
        author = if ($selected) { Plain $selected.extmetadata.Artist.value } else { '' }
        license = if ($selected) { Plain $selected.extmetadata.LicenseShortName.value } else { '' }
        license_url = if ($selected) { $selected.extmetadata.LicenseUrl.value } else { '' }
        source_url = if ($selected) { $selected.descriptionurl } else { '' }
        download_url = if ($selected) { if ($selected.thumburl) { $selected.thumburl } else { $selected.url } } else { '' }
        original_url = if ($selected) { $selected.url } else { '' }
    }
    $result += $record
    Write-Output ('{0}:{1} | {2} | {3}' -f $record.region_id, $record.word, $file, $record.license)
}
[System.IO.File]::WriteAllText((Join-Path $cache 'unreviewed_candidates.json'),
    (ConvertTo-Json -InputObject @($result) -Depth 12), $utf8)
