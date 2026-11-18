param([string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot))
$ErrorActionPreference = 'Stop'
$culture = Get-Content (Join-Path $ProjectRoot 'assets/data/regional_culture.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$english = Get-Content (Join-Path $ProjectRoot 'assets/data/trivia_en.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$tokens = @('BINONDO', 'PANAGBENGA', 'INABEL', 'VAKUL', 'PAROL', 'KIPING', 'MORIONES', 'PENAFRANCIA', 'ATIATIHAN', 'SINULOG', 'PINTADOS', 'VINTA', 'KAAMULAN', 'KADAYAWAN', 'TNALAK', 'BONOKBONOK', 'TOROGAN', 'MASSKARA')
function DartString([string]$Value) {
    # JSON quoted strings are also valid Dart strings after escaping interpolation.
    return (ConvertTo-Json -InputObject $Value -Compress).Replace('$', '\$')
}
$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add("part of 'final_challenge_catalog.dart';")
$lines.Add('')
$lines.Add('// Generated from the existing bilingual regional culture trivia.')
$lines.Add('// Regenerate: powershell -File scripts/prepare_final_trivia_words.ps1')
$lines.Add('const finalTriviaWords = [')
foreach ($region in $culture) {
    $id = [int]$region.region_id
    $translation = $english | Where-Object { $_.region_id -eq $id } | Select-Object -First 1
    $index = if ($id -in @(5, 6, 12)) { 1 } else { 0 }
    $question = $region.questions[$index]
    $questionEn = $translation.culture[$index]
    if (-not (Test-Path -LiteralPath (Join-Path $ProjectRoot $region.image_path))) {
        throw "Missing existing trivia photograph: $($region.image_path)"
    }
    $lines.Add('  FinalChallengeClue(')
    $lines.Add("    $id,")
    $lines.Add(('    {0},' -f (DartString $tokens[$id - 1])))
    $lines.Add(('    {0},' -f (DartString $questionEn.question)))
    $lines.Add(('    {0},' -f (DartString $question.question)))
    $lines.Add('    isTriviaWord: true,')
    $lines.Add(('    imagePath: {0},' -f (DartString $region.image_path)))
    $lines.Add(('    captionEn: {0},' -f (DartString $translation.image_caption)))
    $lines.Add(('    captionFil: {0},' -f (DartString $region.image_caption)))
    $lines.Add(('    factEn: {0},' -f (DartString $questionEn.explanation)))
    $lines.Add(('    factFil: {0},' -f (DartString $question.explanation)))
    $lines.Add('  ),')
}
$lines.Add('];')
$destination = Join-Path $ProjectRoot 'lib/features/final_challenge/final_trivia_words.dart'
[System.IO.File]::WriteAllText($destination, ($lines -join "`n") + "`n", [System.Text.UTF8Encoding]::new($false))
Write-Output 'Prepared 18 trivia-word entries and verified their existing offline photographs.'
