import 'dart:convert';
import 'dart:io';

// Run after the reviewed downloads. Never writes a player's database.
void main() {
  final creditsFile = File('assets/data/locality_photo_credits.json');
  final credits = (jsonDecode(creditsFile.readAsStringSync()) as List)
      .cast<Map<String, dynamic>>();
  final wordsFile = File('assets/data/regional_words.json');
  final words = (jsonDecode(wordsFile.readAsStringSync()) as List)
      .cast<Map<String, dynamic>>();
  const captions = {
    '1:LASPINAS': [
      'St. Joseph Parish surroundings, Las Piñas',
      'Paligid ng Parokya ng San Jose, Las Piñas',
    ],
    '7:BROOKESPOINT': [
      "School construction in Brooke’s Point, Palawan (2025)",
      'Pagtatayo ng paaralan sa Brooke’s Point, Palawan (2025)',
    ],
    '7:TORRIJOS': [
      'Battle of Pulang Lupa historical marker, Torrijos',
      'Panandang pangkasaysayan ng Labanan sa Pulang Lupa, Torrijos',
    ],
    '17:MALABANG': [
      'Historical aerial photograph of Malabang and its airfield (NARA archive)',
      'Makasaysayang larawang panghimpapawid ng Malabang at paliparan nito (arkibo ng NARA)',
    ],
    '17:WAO': [
      'Barangay Buot housing and farmland, Wao',
      'Mga tahanan at sakahan sa Barangay Buot, Wao',
    ],
  };
  for (final photo in credits) {
    final key = '${photo['region_id']}:${photo['word']}';
    if (!File(photo['asset_path'] as String).existsSync()) {
      throw StateError('Missing downloaded asset: $key');
    }
    if (captions.containsKey(key)) {
      photo['caption_en'] = captions[key]![0];
      photo['caption_fil'] = captions[key]![1];
    }
    final word = words.singleWhere(
      (w) => w['region_id'] == photo['region_id'] && w['word'] == photo['word'],
    );
    word['image_path'] = photo['asset_path'];
  }
  // Correct copied information for identically named cities in other regions.
  final pampanga = words.singleWhere(
    (w) => w['region_id'] == 5 && w['word'] == 'SANFERNANDO',
  );
  pampanga.addAll({
    'province_en': 'Pampanga',
    'province_fil': 'Pampanga',
    'description_en':
        'San Fernando is the capital city of Pampanga in Central Luzon.',
    'description_fil':
        'Ang San Fernando ay kabisera ng Pampanga sa Gitnang Luzon.',
    'fact_en':
        'San Fernando, Pampanga is known for its Giant Lantern Festival.',
    'fact_fil':
        'Kilala ang San Fernando, Pampanga sa Giant Lantern Festival nito.',
  });
  final negros = words.singleWhere(
    (w) => w['region_id'] == 18 && w['word'] == 'SANCARLOS',
  );
  negros.addAll({
    'province_en': 'Negros Occidental',
    'province_fil': 'Negros Occidental',
    'description_en': 'San Carlos is a coastal city in Negros Occidental in the Negros Island Region.',
    'description_fil': 'Ang San Carlos ay lungsod sa baybayin ng Negros Occidental sa Negros Island Region.',
    'fact_en': 'The Port of San Carlos connects Negros with nearby islands.',
    'fact_fil':
        'Iniuugnay ng Daungan ng San Carlos ang Negros sa mga kalapit na isla.',
  });
  const encoder = JsonEncoder.withIndent('  ');
  creditsFile.writeAsStringSync('${encoder.convert(credits)}\n');
  wordsFile.writeAsStringSync('${encoder.convert(words)}\n');
  final report = StringBuffer('''# Additional locality photographs

Real photographs downloaded automatically with PowerShell, resized locally and bundled for offline use. No AI imagery. Each adapted photo retains its stated source license. Author, source title, license, URLs, modifications and SHA-256 are stored in `assets/data/locality_photo_credits.json`; credits are available in learning cards and discovery dialogs.

Some source images are only 250 pixels wide; they were not enlarged. Malabang is explicitly labelled as an archival aerial photograph. Brooke’s Point shows a documented local school construction project rather than a scenic landmark.

## Downloaded photographs

| Region ID / word | Source / title | Author | License |
|---|---|---|---|
''');
  for (final photo in credits) {
    String clean(Object? s) => '$s'.replaceAll('|', '/').replaceAll('\n', ' ');
    report.writeln(
      '| ${photo['region_id']} / ${photo['word']} | [${clean(photo['file_title'])}](${photo['source_url']}) | ${clean(photo['author'])} | ${clean(photo['license'])} |',
    );
  }
  final missing = words
      .where((w) => !File(w['image_path'] as String).existsSync())
      .toList();
  report.writeln('''
## Coverage

${credits.length} of 50 reviewed additions are installed. ${words.length - missing.length} of ${words.length} locality image paths resolve to bundled assets; ${missing.length} remain missing. No progress or reward changes are associated with these photos.

The four final additions show Lake Pinamaloy's lakeside park (Don Carlos), the jewelry training center opening (Monkayo), a cacao solar dryer in Basiawan (Santa Maria, Davao Occidental), and the marine hatchery in Palo Alto (Lingig). These are actual local places and facilities, not generic regional stand-ins. The Monkayo photograph is extracted from DOST's S&T Post PDF, not a screenshot of a magazine page. Government-work provenance and named photographers are recorded in each record's `license_note`; agency markings are retained.

The search pins and reviewed records are in `tool/locality_photo_sources.json` and `tool/locality_photo_candidates.json`. `scripts/fetch_locality_photos.ps1` downloads only those reviewed records. The four final source downloads have pinned SHA-256 checksums; a changed source must be reviewed again. For the newsletter, `scripts/extract_pdf_photo.dart` extracts the reviewed JPEG object before resizing. A previously downloaded source cache can be supplied with `-SourceCache <directory>` using filenames `region_<id>_<word>.source`.

`scripts/discover_locality_photos.ps1` produces unreviewed candidates for future review; it does not install photos.
''');
  if (missing.isNotEmpty) {
    report.writeln('\n## Missing assets\n');
    for (final word in missing) {
      report.writeln(
        '- ${word['region_id']}:${word['word']}: ${word['image_path']}',
      );
    }
  }
  File('assets/images/localities/ADDITIONAL_PHOTO_SOURCES.md')
      .writeAsStringSync('${report.toString().trimRight()}\n');
  stdout.writeln(
    'Registered ${credits.length} downloaded photos; ${words.where((w) => !File(w['image_path'] as String).existsSync()).length} of ${words.length} locality references still need their own photo.',
  );
}
