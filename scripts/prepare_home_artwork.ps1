param([string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot))

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$artDirectory = Join-Path $ProjectRoot 'assets/images/branding'
$sourceImage = [System.Drawing.Bitmap]::FromFile((Join-Path $ProjectRoot 'design/home/home-travel-background.png'))
$jpegEncoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
    Where-Object { $_.MimeType -eq 'image/jpeg' }
$encoderParameters = [System.Drawing.Imaging.EncoderParameters]::new(1)
$encoderParameters.Param[0] = [System.Drawing.Imaging.EncoderParameter]::new(
    [System.Drawing.Imaging.Encoder]::Quality, [long]88)
try {
    # Preserve proportions; Flutter positions and fades each crop separately.
    $layers = @(
        @{ Name = 'home-sky-scene-v1.jpg'; X = 0; Y = 0; Width = 1024; Height = 400 },
        @{ Name = 'home-travel-footer-v1.jpg'; X = 0; Y = 1120; Width = 1024; Height = 416 },
        @{ Name = 'home-foliage-left-v1.jpg'; X = 0; Y = 360; Width = 96; Height = 760 },
        @{ Name = 'home-foliage-right-v1.jpg'; X = 928; Y = 360; Width = 96; Height = 760 }
    )
    foreach ($layer in $layers) {
        $rectangle = [System.Drawing.Rectangle]::new($layer.X, $layer.Y, $layer.Width, $layer.Height)
        $crop = $sourceImage.Clone($rectangle, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
        try {
            $destination = Join-Path $artDirectory $layer.Name
            $crop.Save($destination, $jpegEncoder, $encoderParameters)
            Get-Item -LiteralPath $destination | Select-Object Name, Length
        } finally { $crop.Dispose() }
    }
} finally {
    $sourceImage.Dispose()
    $encoderParameters.Dispose()
}
