import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/features/badges/region_landmark.dart';
import 'package:rehiyonia/features/badges/widgets/regional_badge_stamp.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final source = File('assets/data/region_landmarks.json').readAsStringSync();
  final records = (jsonDecode(source) as List).cast<Map<String, dynamic>>();
  final photos = parseRegionLandmarks(source);

  test(
    '18 distinct licensed JPEGs match the pinned regional sources',
    () async {
      final pins = (jsonDecode(
        File('tool/region_landmark_sources.json').readAsStringSync(),
      ) as List).cast<Map<String, dynamic>>();
      expect(photos.keys, orderedEquals(List.generate(18, (i) => i + 1)));
      expect(records.map((r) => r['asset_sha256']).toSet(), hasLength(18));
      expect(photos.values.map((p) => p.assetPath).toSet(), hasLength(18));
      final contents = <String>{};
      for (final record in records) {
        final photo = photos[record['region_id']]!;
        final pin = pins.singleWhere((p) => p['region_id'] == photo.regionId);
        expect(record['file_title'], pin['file_title']);
        expect(photo.sourceUrl, startsWith('https://'));
        expect(photo.author, isNotEmpty);
        expect(
          photo.license,
          matches(RegExp(r'^(CC BY|CC0|Public domain|Pexels)')),
        );
        final bytes = File(photo.assetPath).readAsBytesSync();
      final bundled = await rootBundle.load(photo.assetPath);
      expect(bundled.buffer.asUint8List(), orderedEquals(bytes));
        expect(bytes.take(2), orderedEquals([0xff, 0xd8]));
        contents.add(base64Encode(bytes));
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        expect(frame.image.width, photo.width);
        expect(frame.image.height, photo.height);
        expect(frame.image.width, lessThanOrEqualTo(960));
        frame.image.dispose();
        codec.dispose();
      }
      expect(
        contents,
        hasLength(18),
        reason: 'Every region needs its own photo',
      );
    },
  );

  test('missing, duplicate, and mismatched regional metadata is rejected', () {
    expect(
      () => parseRegionLandmarks(jsonEncode(records.skip(1).toList())),
      throwsFormatException,
    );
    expect(
      () => parseRegionLandmarks(jsonEncode([...records, records.first])),
      throwsFormatException,
    );
    final invalid = [
      for (final record in records) {...record},
    ];
    invalid.last['region_code'] = 'EXTRA';
    expect(
      () => parseRegionLandmarks(jsonEncode(invalid)),
      throwsFormatException,
    );
  });

  testWidgets('locked photo stays visible and earned photo removes its lock', (
    tester,
  ) async {
    Future<void> show(bool earned) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegionalBadgeStamp(landmark: photos[18]!, earned: earned),
        ),
      ),
    );
    await show(false);
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    expect(find.byType(ColorFiltered), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.fit, BoxFit.cover);
    expect(
      ((image.image as ResizeImage).imageProvider as AssetImage).assetName,
      photos[18]!.assetPath,
    );
    await show(true);
    expect(find.byIcon(Icons.lock_rounded), findsNothing);
    expect(find.byType(ColorFiltered), findsNothing);
    expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
