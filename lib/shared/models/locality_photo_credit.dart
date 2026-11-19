import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Reviewed exceptions to the Commons catalog. Keep the source tied to its
// locality so an unrelated photograph cannot silently replace a local asset.
const _reviewedPhotoSources = {
  '17:WAO': 'https://betterbarmm.com/directory',
  '13:DONCARLOS': 'https://bukidnononline.com/lake-pinamaloy-in-don-carlos-bukidnon-reopens/',
  '14:MONKAYO': 'https://dost.gov.ph/knowledge-resources/news/86-2025-news/3996-dost-davoro-establishes-phl-s-1st-tesda-accredited-jewelry-training-center.html',
  '14:SANTAMARIA':
      'https://hvcdp.da.gov.ph/2022/05/19/'
      '%F0%9D%97%A6%F0%9D%97%A7%F0%9D%97%A5%F0%9D%97%98%F0%9D%97%A1%F0%9D%97%9A'
      '%F0%9D%97%A7%F0%9D%97%9B%F0%9D%97%98%F0%9D%97%A1%F0%9D%97%9C%F0%9D%97%A1'
      '%F0%9D%97%9A-%F0%9D%97%A7%F0%9D%97%9B%F0%9D%97%98/',
  '16:LINGIG': 'https://caraga.bfar.da.gov.ph/2025/09/02/da-bfar-opens-legislated-multi-species-marine-hatchery-in-surigao-del-sur/news/',
};

class LocalityPhotoCredit {
  const LocalityPhotoCredit({
    required this.regionId,
    required this.word,
    required this.assetPath,
    required this.locality,
    required this.province,
    required this.author,
    required this.license,
    required this.sourceUrl,
    required this.licenseUrl,
    required this.modifications,
    required this.title,
    this.captionEn,
    this.captionFil,
    this.originalSourceUrl,
  });
  final int regionId;
  final String word, assetPath, locality, province, author, license;
  final String sourceUrl, licenseUrl, modifications;
  final String title;
  final String? captionEn, captionFil, originalSourceUrl;
  String get key => '$regionId:$word';
  String get caption =>
      captionEn ??
      (locality.contains(province) ? locality : '$locality · $province');
  Map<String, dynamic> get credit => {
    'author': author,
    'license': license,
    'source_url': sourceUrl,
    'license_url': licenseUrl,
    'modifications': modifications,
    'title': title,
    if (originalSourceUrl != null) 'original_source_url': originalSourceUrl,
  };
  factory LocalityPhotoCredit.fromJson(Map<String, dynamic> json) =>
      LocalityPhotoCredit(
        regionId: json['region_id'] as int,
        word: json['word'] as String,
        assetPath: json['asset_path'] as String,
        locality: json['locality_title'] as String,
        province: json['province'] as String,
        author: json['author'] as String,
        license: json['license'] as String,
        sourceUrl: json['source_url'] as String,
        licenseUrl: json['license_url'] as String? ?? '',
        modifications: json['modifications'] as String,
        title: json['file_title'] as String,
        captionEn: json['caption_en'] as String?,
        captionFil: json['caption_fil'] as String?,
        originalSourceUrl: json['original_source_url'] as String?,
      );
}

Map<String, LocalityPhotoCredit> parseLocalityPhotoCredits(String source) {
  final result = <String, LocalityPhotoCredit>{};
  for (final row in (jsonDecode(source) as List).cast<Map<String, dynamic>>()) {
    final photo = LocalityPhotoCredit.fromJson(row);
    if (photo.regionId < 1 ||
        photo.regionId > 18 ||
        result.containsKey(photo.key) ||
        photo.assetPath !=
            'assets/images/localities/region_${photo.regionId}_${photo.word.toLowerCase()}.jpg' ||
        photo.author.isEmpty ||
        photo.license.isEmpty ||
        !(photo.sourceUrl.startsWith('https://commons.wikimedia.org/wiki/') ||
            _reviewedPhotoSources[photo.key] == photo.sourceUrl)) {
      throw const FormatException('Invalid or duplicate locality photo credit');
    }
    result[photo.key] = photo;
  }
  return Map.unmodifiable(result);
}

final localityPhotoCreditsProvider = FutureProvider(
  (ref) async => parseLocalityPhotoCredits(
    await rootBundle.loadString('assets/data/locality_photo_credits.json'),
  ),
);
