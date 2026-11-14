import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../regions/providers/region_provider.dart';

/// Photo metadata is bundled content, independent of the player's SQLite data.
class RegionLandmark {
  const RegionLandmark({
    required this.regionId,
    required this.regionCode,
    required this.name,
    required this.location,
    required this.assetPath,
    required this.author,
    required this.license,
    required this.licenseUrl,
    required this.sourceUrl,
    required this.modifications,
    required this.width,
    required this.height,
  });
  final int regionId, width, height;
  final String regionCode, name, location, assetPath, author;
  final String license, licenseUrl, sourceUrl, modifications;

  factory RegionLandmark.fromJson(Map<String, dynamic> json) => RegionLandmark(
    regionId: json['region_id'] as int,
    regionCode: json['region_code'] as String,
    name: json['landmark'] as String,
    location: json['location'] as String,
    assetPath: json['asset_path'] as String,
    author: json['author'] as String,
    license: json['license'] as String,
    licenseUrl: json['license_url'] as String? ?? '',
    sourceUrl: json['source_url'] as String,
    modifications: json['modifications'] as String,
    width: json['width'] as int,
    height: json['height'] as int,
  );
}

Map<int, RegionLandmark> parseRegionLandmarks(String source) {
  final entries = (jsonDecode(source) as List<dynamic>)
      .map((entry) => RegionLandmark.fromJson(entry as Map<String, dynamic>))
      .toList();
  final expected = {
    for (final region in defaultPhilippineRegions) region.id: region.code,
  };
  final result = <int, RegionLandmark>{};
  for (final photo in entries) {
    if (result.containsKey(photo.regionId) ||
        expected[photo.regionId] != photo.regionCode ||
        !photo.assetPath.startsWith('assets/images/region_landmarks/') ||
        photo.width <= 0 ||
        photo.height <= 0 ||
        photo.author.isEmpty ||
        photo.license.isEmpty ||
        photo.sourceUrl.isEmpty) {
      throw const FormatException(
        'Invalid or duplicate regional landmark metadata',
      );
    }
    result[photo.regionId] = photo;
  }
  if (result.length != expected.length) {
    throw const FormatException(
      'A verified landmark photo is required for each of the 18 regions',
    );
  }
  return Map.unmodifiable(result);
}

final regionLandmarksProvider = FutureProvider<Map<int, RegionLandmark>>(
  (ref) async => parseRegionLandmarks(
    await rootBundle.loadString('assets/data/region_landmarks.json'),
  ),
);
