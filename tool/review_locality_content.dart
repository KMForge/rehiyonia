import 'dart:convert';
import 'dart:io';

String normalized(String value) => value
    .toUpperCase()
    .replaceAll('Ñ', 'N')
    .replaceAll(RegExp(r'[^A-Z0-9]'), '')
    .replaceFirst('CITYOF', '')
    .replaceFirst(RegExp(r'CITY$'), '');

void main() {
  final words = (jsonDecode(
    File('assets/data/regional_words.json').readAsStringSync(),
  ) as List).cast<Map<String, dynamic>>();
  final reference = jsonDecode(
    File('tool/locality_psgc_reference.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final records = (reference['records'] as List).cast<Map<String, dynamic>>();
  const regionCodes = {
    1: '13',
    2: '14',
    3: '01',
    4: '02',
    5: '03',
    6: '04',
    7: '17',
    8: '05',
    9: '06',
    10: '07',
    11: '08',
    12: '09',
    13: '10',
    14: '11',
    15: '12',
    16: '16',
    17: '19',
    18: '18',
  };
  const aliases = {
    '9:WASHINGTON': 'New Washington',
    '14:GENEROSO': 'Governor Generoso',
    '15:GENSAN': 'General Santos',
    '17:DATUODIN': 'Datu Odin Sinsuat',
    '17:SHARIFAGUAK': 'Shariff Aguak',
    '17:PANGLIMA': 'Panglima Sugala',
    '14:SAMAL': 'Island Garden City of Samal',
    '10:LAPULAPU': 'Lapu-Lapu',
    '15:PIGCAWAYAN': 'Pigkawayan',
  };
  const disambiguation = {
    '7:SANJOSE': '17051',
    '7:ROXAS': '17053',
    '9:SANJOSE': '06006',
    '10:DANAO': '07022',
  };
  final selected = <Map<String, dynamic>>[];
  final reviewedKeys = {
    for (final r in records)
      if (r['word'] != null) '${r['region_id']}:${r['word']}',
  };
  for (final w in words.where(
    (w) =>
        reviewedKeys.contains('${w['region_id']}:${w['word']}') ||
        (w['description_en'] as String).contains('prominent'),
  )) {
    final key = '${w['region_id']}:${w['word']}';
    final name = aliases[key] ?? w['word'] as String;
    final matches = records
        .where(
          (r) =>
              (r['code'] as String).startsWith(
                disambiguation[key] ?? regionCodes[w['region_id']]!,
              ) &&
              normalized(r['name'] as String) == normalized(name),
        )
        .toList();
    if (matches.length != 1) {
      stderr.writeln('$key $name -> ${matches.map((m) => m['name'])}');
      continue;
    }
    selected.add({
      ...matches.single,
      'region_id': w['region_id'],
      'word': w['word'],
    });
  }
  if (selected.length != 234) {
    throw StateError('Expected 234 reviewed records, got ${selected.length}');
  }
  File('tool/locality_psgc_reference.json').writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert({...reference, 'records': selected})}\n',
  );
  stdout.writeln(
    'Matched ${selected.length} localities to official PSA names and codes.',
  );
}
