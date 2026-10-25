import 'dart:convert';

import '../data/avatar_catalog.dart';

/// Pure configuration. Legacy indices remain readable during the v2 upgrade.
class PlayerAvatar {
  const PlayerAvatar({
    this.skinIndex = 0,
    this.hairStyleIndex = 0,
    this.hairColorIndex = 0,
    this.outfitColorIndex = 0,
    this.accessoryIndex = 0,
    this.baseId = 'male',
    String? headwearId,
    String? glassesId,
    this.necklaceId = 'none',
    this.topId = 'tee',
    this.bottomId = 'pants',
    this.bottomColorIndex = 0,
    this.shoesId = 'sneakers',
    // Public parameter names preserve the editor API while legacy getters
    // resolve an omitted slot from accessoryIndex.
    // ignore: prefer_initializing_formals
  }) : _headwearId = headwearId,
       // ignore: prefer_initializing_formals
       _glassesId = glassesId;

  final int skinIndex, hairStyleIndex, hairColorIndex, outfitColorIndex;
  final int accessoryIndex, bottomColorIndex;
  final String baseId, necklaceId, topId, bottomId, shoesId;
  final String? _headwearId, _glassesId;
  String get headwearId =>
      _headwearId ??
      (accessoryIndex == 1
          ? 'cap'
          : accessoryIndex == 2
          ? 'flower'
          : 'none');
  String get glassesId =>
      _glassesId ?? (accessoryIndex == 3 ? 'round' : 'none');

  PlayerAvatar copyWith({
    int? skinIndex,
    int? hairStyleIndex,
    int? hairColorIndex,
    int? outfitColorIndex,
    int? accessoryIndex,
    String? baseId,
    String? headwearId,
    String? glassesId,
    String? necklaceId,
    String? topId,
    String? bottomId,
    int? bottomColorIndex,
    String? shoesId,
  }) => PlayerAvatar(
    skinIndex: skinIndex ?? this.skinIndex,
    hairStyleIndex: hairStyleIndex ?? this.hairStyleIndex,
    hairColorIndex: hairColorIndex ?? this.hairColorIndex,
    outfitColorIndex: outfitColorIndex ?? this.outfitColorIndex,
    accessoryIndex: accessoryIndex ?? this.accessoryIndex,
    baseId: baseId ?? this.baseId,
    headwearId: headwearId ?? (accessoryIndex != null ? null : this.headwearId),
    glassesId: glassesId ?? (accessoryIndex != null ? null : this.glassesId),
    necklaceId: necklaceId ?? this.necklaceId,
    topId: topId ?? this.topId,
    bottomId: bottomId ?? this.bottomId,
    bottomColorIndex: bottomColorIndex ?? this.bottomColorIndex,
    shoesId: shoesId ?? this.shoesId,
  );

  static String _id(int index, List<String> ids) =>
      ids[index.clamp(0, ids.length - 1)];
  Map<String, Object> toJson() => {
    'version': 1,
    'base': AvatarCatalog.valid(baseId, AvatarCatalog.bases),
    'skin': _id(skinIndex, AvatarCatalog.skins),
    'hair': _id(hairStyleIndex, AvatarCatalog.hairs),
    'hairColor': _id(hairColorIndex, AvatarCatalog.hairColors),
    'topColor': _id(outfitColorIndex, AvatarCatalog.colors),
    'headwear': AvatarCatalog.valid(headwearId, AvatarCatalog.headwear),
    'glasses': AvatarCatalog.valid(glassesId, AvatarCatalog.glasses),
    'necklace': AvatarCatalog.valid(necklaceId, AvatarCatalog.necklaces),
    'top': AvatarCatalog.valid(topId, AvatarCatalog.tops),
    'bottom': AvatarCatalog.valid(bottomId, AvatarCatalog.bottoms),
    'bottomColor': _id(bottomColorIndex, AvatarCatalog.colors),
    'shoes': AvatarCatalog.valid(shoesId, AvatarCatalog.shoes),
  };

  Map<String, dynamic> toMap() => {
    'avatar_skin': skinIndex,
    'avatar_hair': hairStyleIndex,
    'avatar_hair_color': hairColorIndex,
    'avatar_outfit': outfitColorIndex,
    'avatar_accessory': accessoryIndex,
    'avatar_json': jsonEncode(toJson()),
  };

  factory PlayerAvatar.fromMap(Map<String, dynamic> map) {
    final encoded = map['avatar_json'];
    if (encoded is String && encoded.isNotEmpty) {
      try {
        final json = jsonDecode(encoded);
        if (json is Map<String, dynamic> && json['version'] == 1) {
          return PlayerAvatar(
            baseId: AvatarCatalog.valid(json['base'], AvatarCatalog.bases),
            skinIndex: AvatarCatalog.index(json['skin'], AvatarCatalog.skins),
            hairStyleIndex: AvatarCatalog.index(
              json['hair'],
              AvatarCatalog.hairs,
            ),
            hairColorIndex: AvatarCatalog.index(
              json['hairColor'],
              AvatarCatalog.hairColors,
            ),
            outfitColorIndex: AvatarCatalog.index(
              json['topColor'],
              AvatarCatalog.colors,
            ),
            headwearId: AvatarCatalog.valid(
              json['headwear'],
              AvatarCatalog.headwear,
            ),
            glassesId: AvatarCatalog.valid(
              json['glasses'],
              AvatarCatalog.glasses,
            ),
            necklaceId: AvatarCatalog.valid(
              json['necklace'],
              AvatarCatalog.necklaces,
            ),
            topId: AvatarCatalog.valid(json['top'], AvatarCatalog.tops),
            bottomId: AvatarCatalog.valid(
              json['bottom'],
              AvatarCatalog.bottoms,
            ),
            bottomColorIndex: AvatarCatalog.index(
              json['bottomColor'],
              AvatarCatalog.colors,
            ),
            shoesId: AvatarCatalog.valid(json['shoes'], AvatarCatalog.shoes),
          );
        }
      } on FormatException {
        /* Read the preserved legacy fields below. */
      }
    }
    int legacy(String key, int count) =>
        ((map[key] as num?)?.toInt() ?? 0).clamp(0, count - 1);
    return PlayerAvatar(
      skinIndex: legacy('avatar_skin', 4),
      hairStyleIndex: legacy('avatar_hair', 4),
      hairColorIndex: legacy('avatar_hair_color', 4),
      outfitColorIndex: legacy('avatar_outfit', 4),
      accessoryIndex: legacy('avatar_accessory', 4),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PlayerAvatar &&
      jsonEncode(toJson()) == jsonEncode(other.toJson());
  @override
  int get hashCode => Object.hashAll(toJson().values);
}
