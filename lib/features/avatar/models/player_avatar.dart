import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PlayerAvatar {
  const PlayerAvatar({
    this.skinIndex = 0,
    this.hairStyleIndex = 0,
    this.hairColorIndex = 0,
    this.outfitColorIndex = 0,
    this.accessoryIndex = 0,
  });

  final int skinIndex;
  final int hairStyleIndex;
  final int hairColorIndex;
  final int outfitColorIndex;
  final int accessoryIndex;

  static const List<Color> skinColors = [
    Color(0xFFF5D0A9), // Warm Tan
    Color(0xFFD2A078), // Golden Brown
    Color(0xFFB87B4C), // Deep Honey
    Color(0xFFFFE0BD), // Fair Peach
  ];

  static const List<Color> hairColors = [
    Color(0xFF212121), // Jet Black
    Color(0xFF3E2723), // Dark Chocolate
    Color(0xFF5D4037), // Chestnut
    Color(0xFF8D6E63), // Amber
  ];

  static const List<Color> outfitColors = [
    AppColors.deepBlue,
    AppColors.pastelPink,
    AppColors.successMint,
    AppColors.softLavender,
  ];

  Color get skinColor => skinColors[skinIndex.clamp(0, skinColors.length - 1)];
  Color get hairColor =>
      hairColors[hairColorIndex.clamp(0, hairColors.length - 1)];
  Color get outfitColor =>
      outfitColors[outfitColorIndex.clamp(0, outfitColors.length - 1)];

  PlayerAvatar copyWith({
    int? skinIndex,
    int? hairStyleIndex,
    int? hairColorIndex,
    int? outfitColorIndex,
    int? accessoryIndex,
  }) {
    return PlayerAvatar(
      skinIndex: skinIndex ?? this.skinIndex,
      hairStyleIndex: hairStyleIndex ?? this.hairStyleIndex,
      hairColorIndex: hairColorIndex ?? this.hairColorIndex,
      outfitColorIndex: outfitColorIndex ?? this.outfitColorIndex,
      accessoryIndex: accessoryIndex ?? this.accessoryIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'avatar_skin': skinIndex,
      'avatar_hair': hairStyleIndex,
      'avatar_hair_color': hairColorIndex,
      'avatar_outfit': outfitColorIndex,
      'avatar_accessory': accessoryIndex,
    };
  }

  factory PlayerAvatar.fromMap(Map<String, dynamic> map) {
    return PlayerAvatar(
      skinIndex: (map['avatar_skin'] as int?) ?? 0,
      hairStyleIndex: (map['avatar_hair'] as int?) ?? 0,
      hairColorIndex: (map['avatar_hair_color'] as int?) ?? 0,
      outfitColorIndex: (map['avatar_outfit'] as int?) ?? 0,
      accessoryIndex: (map['avatar_accessory'] as int?) ?? 0,
    );
  }
}
