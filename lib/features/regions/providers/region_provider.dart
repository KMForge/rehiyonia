import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_initialization_provider.dart';
import '../data/repositories/region_repository.dart';
import '../models/region.dart';

final regionRepositoryProvider = Provider<RegionRepository>((ref) {
  final appDb = ref.watch(appDatabaseProvider);
  return RegionRepository(appDatabase: appDb);
});

final defaultPhilippineRegions = <Region>[
  const Region(
    id: 1,
    code: 'NCR',
    name: 'Pambansang Punong Rehiyon',
    designation: 'National Capital Region',
    islandGroup: 'Luzon',
    description: 'Sentro ng pamahalaan, ekonomiya, at edukasyon sa Pilipinas.',
    isUnlocked: true,
  ),
  const Region(
    id: 2,
    code: 'CAR',
    name: 'Rehiyong Pampangasiwaan ng Cordillera',
    designation: 'Cordillera Administrative Region',
    islandGroup: 'Luzon',
    description: 'Kabundukan ng Cordillera at tahanan ng Banaue Rice Terraces.',
  ),
  const Region(
    id: 3,
    code: 'REGION_I',
    name: 'Rehiyon ng Ilocos',
    designation: 'Region I',
    islandGroup: 'Luzon',
    description:
        'Hilagang-kanlurang baybayin, makasaysayang Vigan at Paoay Church.',
  ),
  const Region(
    id: 4,
    code: 'REGION_II',
    name: 'Lambak ng Cagayan',
    designation: 'Region II',
    islandGroup: 'Luzon',
    description: 'Malawak na lambak sa pagitan ng Sierra Madre at Cordillera.',
  ),
  const Region(
    id: 5,
    code: 'REGION_III',
    name: 'Gitnang Luzon',
    designation: 'Region III',
    islandGroup: 'Luzon',
    description: 'Bangan ng Palay ng Pilipinas (Rice Granary).',
  ),
  const Region(
    id: 6,
    code: 'REGION_IV_A',
    name: 'CALABARZON',
    designation: 'Region IV-A',
    islandGroup: 'Luzon',
    description: 'Cavite, Laguna, Batangas, Rizal, at Quezon.',
  ),
  const Region(
    id: 7,
    code: 'REGION_IV_B',
    name: 'MIMAROPA',
    designation: 'Region IV-B',
    islandGroup: 'Luzon',
    description:
        'Mindoro, Marinduque, Romblon, at Palawan (The Last Frontier).',
  ),
  const Region(
    id: 8,
    code: 'REGION_V',
    name: 'Rehiyon ng Bicol',
    designation: 'Region V',
    islandGroup: 'Luzon',
    description:
        'Lupain ng Bulkang Mayon at masasarap na pagkaing may gata at sili.',
  ),
  const Region(
    id: 9,
    code: 'REGION_VI',
    name: 'Kanlurang Visayas',
    designation: 'Region VI',
    islandGroup: 'Visayas',
    description:
        'Kilala sa Pista ng Dinagyang, Ati-Atihan, at Isla ng Boracay.',
  ),
  const Region(
    id: 10,
    code: 'REGION_VII',
    name: 'Gitnang Visayas',
    designation: 'Region VII',
    islandGroup: 'Visayas',
    description: 'Cebu, Bohol (Chocolate Hills), Siquijor, at Negros Oriental.',
  ),
  const Region(
    id: 11,
    code: 'REGION_VIII',
    name: 'Silangang Visayas',
    designation: 'Region VIII',
    islandGroup: 'Visayas',
    description: 'Leyte, Samar, Biliran, at ang Tulay ng San Juanico.',
  ),
  const Region(
    id: 12,
    code: 'REGION_IX',
    name: 'Tangway ng Zamboanga',
    designation: 'Region IX',
    islandGroup: 'Mindanao',
    description:
        'Lungsod ng Zamboanga (Asia\'s Latin City) at makukulay na Vinta.',
  ),
  const Region(
    id: 13,
    code: 'REGION_X',
    name: 'Hilagang Mindanao',
    designation: 'Region X',
    islandGroup: 'Mindanao',
    description: 'Bukidnon, Camiguin, Lanao del Norte, at Misamis.',
  ),
  const Region(
    id: 14,
    code: 'REGION_XI',
    name: 'Rehiyon ng Davao',
    designation: 'Region XI',
    islandGroup: 'Mindanao',
    description: 'Tahanan ng Bundok Apo at Haribon (Philippine Eagle).',
  ),
  const Region(
    id: 15,
    code: 'REGION_XII',
    name: 'SOCCSKSARGEN',
    designation: 'Region XII',
    islandGroup: 'Mindanao',
    description:
        'South Cotabato, Cotabato, Sultan Kudarat, Sarangani, General Santos.',
  ),
  const Region(
    id: 16,
    code: 'REGION_XIII',
    name: 'Caraga',
    designation: 'Region XIII',
    islandGroup: 'Mindanao',
    description: 'Kilala sa Siargao (Surfing Capital) at Enchanted River.',
  ),
  const Region(
    id: 17,
    code: 'BARMM',
    name: 'Rehiyong Awtonomo ng Bangsamoro',
    designation: 'BARMM',
    islandGroup: 'Mindanao',
    description: 'Mayaman sa kulturang Islamiko, Lawa ng Lanao, at kasaysayan.',
  ),
];

class RegionsNotifier extends AsyncNotifier<List<Region>> {
  @override
  Future<List<Region>> build() async {
    final repo = ref.watch(regionRepositoryProvider);
    var regions = await repo.getAllRegions();

    if (regions.isEmpty) {
      await repo.insertRegions(defaultPhilippineRegions);
      regions = await repo.getAllRegions();
    }

    return regions;
  }

  Future<void> unlockRegion(int id) async {
    final repo = ref.read(regionRepositoryProvider);
    await repo.unlockRegion(id);
    ref.invalidateSelf();
  }
}

final regionsProvider = AsyncNotifierProvider<RegionsNotifier, List<Region>>(
  RegionsNotifier.new,
);
