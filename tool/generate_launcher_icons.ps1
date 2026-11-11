param()
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$projectRoot = Split-Path -Parent $PSScriptRoot
$assetRoot = Join-Path $projectRoot 'assets/app_icon'
$resRoot = Join-Path $projectRoot 'android/app/src/main/res'

function Save-Icon([System.Drawing.Image]$source, [string]$path, [int]$size, [double]$scale) {
    $bitmap = New-Object System.Drawing.Bitmap($size, $size)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.Clear([System.Drawing.Color]::Transparent)
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $edge = [int][Math]::Round($size * $scale)
        $offset = [int][Math]::Round(($size - $edge) / 2)
        $graphics.DrawImage($source, $offset, $offset, $edge, $edge)
        $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

$legacy = [System.Drawing.Image]::FromFile((Join-Path $assetRoot 'rehiyonia-icon.png'))
$foreground = [System.Drawing.Image]::FromFile((Join-Path $assetRoot 'rehiyonia-icon-foreground.png'))
try {
    foreach ($density in @(
        @{Name='mdpi'; Size=48; Foreground=108},
        @{Name='hdpi'; Size=72; Foreground=162},
        @{Name='xhdpi'; Size=96; Foreground=216},
        @{Name='xxhdpi'; Size=144; Foreground=324},
        @{Name='xxxhdpi'; Size=192; Foreground=432}
    )) {
        $folder = Join-Path $resRoot ('mipmap-' + $density.Name)
        New-Item -ItemType Directory -Force -Path $folder | Out-Null
        Save-Icon $legacy (Join-Path $folder 'ic_launcher.png') $density.Size 1
        # Keep artwork inside the adaptive icon safe area, including mask motion.
        Save-Icon $foreground (Join-Path $folder 'ic_launcher_foreground.png') $density.Foreground (2.0 / 3.0)
    }
} finally {
    $legacy.Dispose()
    $foreground.Dispose()
}
Write-Output 'Generated five legacy and five adaptive foreground launcher icons.'
