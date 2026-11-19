# Local-only optimization; does not re-download or alter original subject matter.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$root = Split-Path -Parent $PSScriptRoot
$manifest = Join-Path $root 'assets/data/locality_photo_credits.json'
$rows = Get-Content $manifest -Raw -Encoding UTF8 | ConvertFrom-Json
foreach($row in $rows) {
 if($row.width -le 960 -and $row.height -le 960) { continue }
 $path = Join-Path $root $row.asset_path
 $image = [Drawing.Image]::FromFile($path)
 $scale = 960 / [Math]::Max($image.Width,$image.Height)
 $width=[int][Math]::Round($image.Width*$scale); $height=[int][Math]::Round($image.Height*$scale)
 $bitmap=[Drawing.Bitmap]::new($width,$height)
 $graphics=[Drawing.Graphics]::FromImage($bitmap)
 $temp = $path + '.optimized.jpg'
 try {
  $graphics.InterpolationMode=[Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $graphics.DrawImage($image,0,0,$width,$height)
  $encoder=[Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object MimeType -eq 'image/jpeg'
  $parameters=[Drawing.Imaging.EncoderParameters]::new(1)
  $parameters.Param[0]=[Drawing.Imaging.EncoderParameter]::new([Drawing.Imaging.Encoder]::Quality,[long]85)
  try { $bitmap.Save($temp,$encoder,$parameters) } finally { $parameters.Dispose() }
 } finally { $graphics.Dispose(); $bitmap.Dispose(); $image.Dispose() }
 Move-Item -LiteralPath $temp -Destination $path -Force
 $row.width=$width; $row.height=$height
 $row.asset_sha256=(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
 $row.modifications='Resized without enlargement to fit within 960 x 960 pixels and JPEG-encoded at quality 85. Adapted photographs retain their original source license.'
 Write-Output "Optimized $($row.region_id):$($row.word): ${width}x${height}"
}
[IO.File]::WriteAllText($manifest,(ConvertTo-Json -InputObject @($rows) -Depth 15),[Text.UTF8Encoding]::new($false))
