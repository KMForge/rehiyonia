import '../regions/models/region.dart';
import '../regions/providers/region_provider.dart';

/// One badge per existing canonical region ID; badge state is never stored twice.
List<Region> regionalBadgeRegions(Iterable<Region> savedRegions) {
  final supportedIds = defaultPhilippineRegions
      .map((region) => region.id)
      .toSet();
  final byId = <int, Region>{};
  for (final region in savedRegions) {
    if (supportedIds.contains(region.id)) {
      byId.putIfAbsent(region.id, () => region);
    }
  }
  return byId.values.toList()..sort((a, b) => a.id.compareTo(b.id));
}

int get regionalBadgeTotal => defaultPhilippineRegions.length;

String regionalBadgeTitle(Region region, {required bool english}) {
  if (!english) return region.name;
  final name = switch (region.code) {
    'REGION_I' => 'Ilocos Region',
    'REGION_II' => 'Cagayan Valley',
    'REGION_III' => 'Central Luzon',
    'REGION_IV_A' => 'CALABARZON',
    'REGION_IV_B' => 'MIMAROPA',
    'REGION_V' => 'Bicol Region',
    'REGION_VI' => 'Western Visayas',
    'REGION_VII' => 'Central Visayas',
    'REGION_VIII' => 'Eastern Visayas',
    'REGION_IX' => 'Zamboanga Peninsula',
    'REGION_X' => 'Northern Mindanao',
    'REGION_XI' => 'Davao Region',
    'REGION_XII' => 'SOCCSKSARGEN',
    'REGION_XIII' => 'Caraga',
    _ => null,
  };
  if (name != null) return '${region.designation} – $name';
  if (region.code == 'BARMM') {
    return 'Bangsamoro Autonomous Region in Muslim Mindanao (BARMM)';
  }
  return '${region.designation} (${region.code})';
}
