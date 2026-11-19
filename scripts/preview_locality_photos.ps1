$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$root = Split-Path -Parent $PSScriptRoot
$rows = Get-Content "$root/assets/data/locality_photo_credits.json" -Raw -Encoding UTF8 | ConvertFrom-Json
for($offset=0; $offset -lt $rows.Count; $offset+=16) {
 $sheet = [Drawing.Bitmap]::new(960,720)
 $g = [Drawing.Graphics]::FromImage($sheet)
 $g.Clear([Drawing.Color]::White)
 $font = [Drawing.Font]::new('Arial',10)
 for($i=$offset; $i -lt [Math]::Min($offset+16,$rows.Count); $i++) {
  $item=$rows[$i]; $slot=$i-$offset; $x=($slot%4)*240; $y=[int][Math]::Floor($slot/4)*180
  $photo=[Drawing.Image]::FromFile((Join-Path $root $item.asset_path))
  $ratio=[Math]::Min(230/$photo.Width,145/$photo.Height)
  $w=[int]($photo.Width*$ratio); $h=[int]($photo.Height*$ratio)
  $g.DrawImage($photo,$x+5,$y+5,$w,$h)
  $g.DrawString("$($item.region_id):$($item.word)",$font,[Drawing.Brushes]::Black,$x+5,$y+152)
  $photo.Dispose()
 }
 $sheet.Save((Join-Path $root "tool/.locality-photo-cache/contact_$offset.jpg"),[Drawing.Imaging.ImageFormat]::Jpeg)
 $font.Dispose(); $g.Dispose(); $sheet.Dispose()
}
