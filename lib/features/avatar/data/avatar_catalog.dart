/// Stable storage IDs. Append items; never rename released IDs.
abstract final class AvatarCatalog {
  static const skins = ['warm_tan', 'golden_brown', 'deep_honey', 'fair_peach'];
  static const hairs = ['short', 'curly', 'ponytail', 'spiky', 'bob', 'long'];
  static const hairColors = ['black', 'chocolate', 'chestnut', 'amber'];
  static const colors = ['ocean', 'rose', 'mint', 'lavender'];
  static const bases = ['male', 'female'];
  static const headwear = [
    'none',
    'cap',
    'flower',
    'bucket',
    'sport_cap',
    'beret',
    'crown',
  ];
  static const glasses = ['none', 'round', 'square', 'sunglasses'];
  static const necklaces = [
    'none',
    'chain',
    'pendant',
    'pearls',
    'gem_pendant',
  ];
  static const earrings = ['none', 'studs', 'hoops', 'star_drops'];
  static const bracelets = ['none', 'woven', 'gold_bangle', 'gem_cuff'];
  static const tops = [
    'tee',
    'polo',
    'jacket',
    'hoodie',
    'explorer',
    'striped_tee',
    'varsity',
    'barong',
    'blouse',
    'bolero',
    'peplum',
  ];
  static const bottoms = [
    'pants',
    'shorts',
    'cargo',
    'chinos',
    'sport_shorts',
    'wide_pants',
    'pleated_shorts',
    'skirt',
  ];
  static const shoes = [
    'sneakers',
    'sandals',
    'boots',
    'flats',
    'heels',
    'loafers',
    'high_tops',
    'strappy_sandals',
  ];

  static const slots = <String, List<String>>{
    'headwear': headwear,
    'glasses': glasses,
    'necklace': necklaces,
    'earrings': earrings,
    'bracelet': bracelets,
    'top': tops,
    'bottom': bottoms,
    'shoes': shoes,
  };

  // Released starter items remain free. Shared accessories are bought once.
  static const _special = <String, WardrobeItem>{
    'headwear/beret': WardrobeItem('headwear', 'beret', price: 60),
    'headwear/crown': WardrobeItem('headwear', 'crown', price: 200),
    'necklace/pearls': WardrobeItem('necklace', 'pearls', price: 70),
    'necklace/gem_pendant': WardrobeItem('necklace', 'gem_pendant', price: 140),
    'earrings/hoops': WardrobeItem('earrings', 'hoops', price: 60),
    'earrings/star_drops': WardrobeItem('earrings', 'star_drops', price: 100),
    'bracelet/gold_bangle': WardrobeItem('bracelet', 'gold_bangle', price: 60),
    'bracelet/gem_cuff': WardrobeItem('bracelet', 'gem_cuff', price: 110),
    'top/striped_tee': WardrobeItem('top', 'striped_tee', base: 'male'),
    'top/varsity': WardrobeItem('top', 'varsity', base: 'male', price: 120),
    'top/barong': WardrobeItem('top', 'barong', base: 'male', price: 180),
    'top/blouse': WardrobeItem('top', 'blouse', base: 'female'),
    'top/bolero': WardrobeItem('top', 'bolero', base: 'female', price: 120),
    'top/peplum': WardrobeItem('top', 'peplum', base: 'female', price: 160),
    'bottom/chinos': WardrobeItem('bottom', 'chinos', base: 'male'),
    'bottom/sport_shorts': WardrobeItem(
      'bottom',
      'sport_shorts',
      base: 'male',
      price: 60,
    ),
    'bottom/wide_pants': WardrobeItem('bottom', 'wide_pants', base: 'female'),
    'bottom/pleated_shorts': WardrobeItem(
      'bottom',
      'pleated_shorts',
      base: 'female',
      price: 60,
    ),
    'bottom/skirt': WardrobeItem('bottom', 'skirt', base: 'female', price: 100),
    'shoes/flats': WardrobeItem('shoes', 'flats', base: 'female'),
    'shoes/heels': WardrobeItem('shoes', 'heels', base: 'female', price: 140),
    'shoes/loafers': WardrobeItem('shoes', 'loafers', base: 'male', price: 80),
    'shoes/high_tops': WardrobeItem('shoes', 'high_tops', price: 90),
    'shoes/strappy_sandals': WardrobeItem(
      'shoes',
      'strappy_sandals',
      price: 60,
    ),
  };

  static WardrobeItem item(String slot, String id) {
    if (!(slots[slot]?.contains(id) ?? false)) {
      throw ArgumentError('Unknown wardrobe item: $slot/$id');
    }
    return _special['$slot/$id'] ?? WardrobeItem(slot, id);
  }

  static List<String> itemsFor(String slot, String base) =>
      (slots[slot] ?? const <String>[])
          .where((id) => item(slot, id).supports(base))
          .toList();
  static String valid(Object? id, List<String> ids) =>
      ids.contains(id) ? id as String : ids.first;
  static int index(Object? id, List<String> ids) =>
      ids.contains(id) ? ids.indexOf(id as String) : 0;
}

class WardrobeItem {
  const WardrobeItem(this.slot, this.id, {this.price = 0, this.base});
  final String slot, id;
  final String? base;
  final int price;
  String get key => '$slot/$id';
  bool supports(String baseId) =>
      AvatarCatalog.bases.contains(baseId) && (base == null || base == baseId);
  bool isOwned(Set<String> owned) => price == 0 || owned.contains(key);
}
