/// Stable storage IDs. Append items; never rename released IDs.
abstract final class AvatarCatalog {
  static const skins = ['warm_tan', 'golden_brown', 'deep_honey', 'fair_peach'];
  static const hairs = ['short', 'curly', 'ponytail', 'spiky', 'bob', 'long'];
  static const hairColors = ['black', 'chocolate', 'chestnut', 'amber'];
  static const colors = ['ocean', 'rose', 'mint', 'lavender'];
  static const bases = ['male', 'female'];
  static const headwear = ['none', 'cap', 'flower', 'bucket'];
  static const glasses = ['none', 'round', 'square', 'sunglasses'];
  static const necklaces = ['none', 'chain', 'pendant'];
  static const tops = ['tee', 'polo', 'jacket', 'hoodie', 'explorer'];
  static const bottoms = ['pants', 'shorts', 'cargo'];
  static const shoes = ['sneakers', 'sandals', 'boots'];
  static String valid(Object? id, List<String> ids) =>
      ids.contains(id) ? id as String : ids.first;
  static int index(Object? id, List<String> ids) =>
      ids.contains(id) ? ids.indexOf(id as String) : 0;
}
