import 'dart:convert';
import 'dart:io';

// Rebuild only the 234 audited placeholder entries from pinned official records.
// Puzzle words, ordering, images and IDs are deliberately kept unchanged.
void main() {
  final file = File('assets/data/regional_words.json');
  final words = (jsonDecode(file.readAsStringSync()) as List)
      .cast<Map<String, dynamic>>();
  final reference = jsonDecode(
    File('tool/locality_psgc_reference.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final records = {
    for (final r in (reference['records'] as List).cast<Map<String, dynamic>>())
      '${r['region_id']}:${r['word']}': r,
  };
  final highlightRows = <Map<String, dynamic>>[
    for (final path in [
      'assets/data/locality_content_highlights.json',
      'assets/data/locality_content_additions.json',
    ])
      ...(jsonDecode(File(path).readAsStringSync()) as List)
          .cast<Map<String, dynamic>>(),
  ];
  final highlights = {for (final h in highlightRows) h['key'] as String: h};
  if (highlights.length != 234 || highlightRows.length != 234) {
    throw StateError(
      'Expected 234 unique sourced highlights; census fallback is not allowed.',
    );
  }
  const provinces = <String, String>{
    '14001': 'Abra',
    '14011': 'Benguet',
    '14027': 'Ifugao',
    '14032': 'Kalinga',
    '14044': 'Mountain Province',
    '14081': 'Apayao',
    '02009': 'Batanes',
    '02015': 'Cagayan',
    '02031': 'Isabela',
    '02050': 'Nueva Vizcaya',
    '02057': 'Quirino',
    '03008': 'Bataan',
    '03014': 'Bulacan',
    '03049': 'Nueva Ecija',
    '03054': 'Pampanga',
    '03069': 'Tarlac',
    '03071': 'Zambales',
    '03077': 'Aurora',
    '04010': 'Batangas',
    '04021': 'Cavite',
    '04034': 'Laguna',
    '04056': 'Quezon',
    '04058': 'Rizal',
    '17040': 'Marinduque',
    '17051': 'Occidental Mindoro',
    '17052': 'Oriental Mindoro',
    '17053': 'Palawan',
    '17059': 'Romblon',
    '05005': 'Albay',
    '05016': 'Camarines Norte',
    '05017': 'Camarines Sur',
    '05020': 'Catanduanes',
    '05041': 'Masbate',
    '05062': 'Sorsogon',
    '06004': 'Aklan',
    '06006': 'Antique',
    '06019': 'Capiz',
    '06030': 'Iloilo',
    '06079': 'Guimaras',
    '07012': 'Bohol',
    '07022': 'Cebu',
    '08026': 'Eastern Samar',
    '08037': 'Leyte',
    '08048': 'Northern Samar',
    '08060': 'Samar',
    '08064': 'Southern Leyte',
    '08078': 'Biliran',
    '09066': 'Sulu',
    '09901': 'Basilan',
    '09072': 'Zamboanga del Norte',
    '09073': 'Zamboanga del Sur',
    '09083': 'Zamboanga Sibugay',
    '10013': 'Bukidnon',
    '10018': 'Camiguin',
    '10042': 'Misamis Occidental',
    '10043': 'Misamis Oriental',
    '11023': 'Davao del Norte',
    '11024': 'Davao del Sur',
    '11025': 'Davao Oriental',
    '11082': 'Davao de Oro',
    '11086': 'Davao Occidental',
    '12047': 'Cotabato',
    '12063': 'South Cotabato',
    '12065': 'Sultan Kudarat',
    '12080': 'Sarangani',
    '16002': 'Agusan del Norte',
    '16003': 'Agusan del Sur',
    '16067': 'Surigao del Norte',
    '16068': 'Surigao del Sur',
    '16085': 'Dinagat Islands',
    '19007': 'Basilan',
    '19036': 'Lanao del Sur',
    '19070': 'Tawi-Tawi',
    '19087': 'Maguindanao del Norte',
    '19088': 'Maguindanao del Sur',
    '18045': 'Negros Occidental',
    '18046': 'Negros Oriental',
    '18061': 'Siquijor',
  };
  const regions = {
    2: 'the Cordillera Administrative Region',
    4: 'Cagayan Valley',
    5: 'Central Luzon',
    6: 'CALABARZON',
    7: 'MIMAROPA',
    8: 'Bicol',
    9: 'Western Visayas',
    10: 'Central Visayas',
    11: 'Eastern Visayas',
    12: 'the Zamboanga Peninsula region',
    13: 'Northern Mindanao',
    14: 'the Davao Region',
    15: 'SOCCSKSARGEN',
    16: 'Caraga',
    17: 'BARMM',
    18: 'the Negros Island Region',
  };
  const regionFil = {
    2: 'Cordillera Administrative Region',
    4: 'Lambak ng Cagayan',
    5: 'Gitnang Luzon',
    6: 'CALABARZON',
    7: 'MIMAROPA',
    8: 'Bicol',
    9: 'Kanlurang Visayas',
    10: 'Gitnang Visayas',
    11: 'Silangang Visayas',
    12: 'Rehiyon ng Tangway ng Zamboanga',
    13: 'Hilagang Mindanao',
    14: 'Rehiyon ng Davao',
    15: 'SOCCSKSARGEN',
    16: 'Caraga',
    17: 'BARMM',
    18: 'Rehiyon ng Pulo ng Negros',
  };
  const independentPrefixes = {
    '03301',
    '03314',
    '04312',
    '17315',
    '06310',
    '07306',
    '07311',
    '07313',
    '08316',
    '09317',
    '10305',
    '10309',
    '11307',
    '12308',
    '16304',
    '18302',
  };
  final review = <Map<String, dynamic>>[];
  for (final w in words) {
    final key = '${w['region_id']}:${w['word']}';
    final r = records[key];
    if (r == null) continue;
    final id = w['region_id'] as int;
    final code = r['code'] as String;
    final prefix = code.substring(0, 5);
    final city = r['type'] == 'City';
    var name = r['name'] as String;
    // Proper spelling on labels does not alter the normalized puzzle target.
    if (key == '9:SANJOSE') name = 'San Jose de Buenavista';
    if (key == '15:TBOLI') name = "T'boli";
    if (key == '17:COTABATO') name = 'Cotabato City';
    final province = provinces[prefix];
    if (province == null && !independentPrefixes.contains(prefix)) {
      throw StateError('Missing province mapping: $key $code');
    }
    final place = province == null
        ? regions[id]!
        : '$province, ${regions[id]!}';
    final placeFil = province == null
        ? regionFil[id]!
        : '$province, ${regionFil[id]!}';
    final kind = city ? 'city' : 'municipality';
    final kindFil = city ? 'lungsod' : 'bayan';
    final desc = '$name is a $kind in $place.';
    final descFil = 'Ang $name ay isang $kindFil sa $placeFil.';
    final highlight = highlights[key];
    if (highlight == null) throw StateError('Missing researched content: $key');
    final fact = highlight['en'] as String;
    final factFil = highlight['fil'] as String;
    final source =
        'https://psa.gov.ph/classification/psgc/${city ? 'cities' : 'municipalities'}';
    w.addAll({
      'name_en': name,
      'name_fil': name,
      'province_en': province ?? regions[id]!.replaceFirst('the ', ''),
      'province_fil': province ?? regionFil[id]!,
      'description_en': desc,
      'description_fil': descFil,
      'clue': descFil,
      'fact_en': fact,
      'fact_fil': factFil,
      'content_revision': 'locality_learning_2026_11_v2',
      'source_urls': [source, highlight['url']],
    });
    review.add({
      'region_id': id,
      'word': w['word'],
      'name': name,
      'psgc_code': code,
      'description_sources': [source],
      'fact_sources': [highlight['url']],
      'fact_topic': 'local_history_culture_nature_or_livelihood',
      'reviewed_on': '2026-11-20',
      'review_status': 'source_checked',
      if (highlight['source_note'] != null)
        'source_note': highlight['source_note'],
    });
  }
  if (review.length != 234) {
    throw StateError('Expected 234 revisions, got ${review.length}');
  }
  if (highlights.keys.any((k) => !records.containsKey(k))) {
    throw StateError('Highlight not in audited scope');
  }
  const encoder = JsonEncoder.withIndent('  ');
  file.writeAsStringSync('${encoder.convert(words)}\n');
  File('assets/data/locality_content_sources.json')
      .writeAsStringSync('${encoder.convert(review)}\n');
  stdout.writeln(
    'Updated ${review.length} sourced local highlights; no census-only facts remain.',
  );
}
