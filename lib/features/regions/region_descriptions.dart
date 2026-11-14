import 'models/region.dart';

/// English display copy for the existing region catalog. Saved descriptions
/// remain intact and are displayed when Filipino is selected.
const regionDescriptionsEnglish = <String, String>{
  'NCR': 'The center of government, the economy, and education in the Philippines.',
  'CAR': 'Home to the Cordillera mountains and the Banaue Rice Terraces.',
  'REGION_I':
      'The northwestern coast, known for historic Vigan and Paoay Church.',
  'REGION_II':
      'A broad valley between the Sierra Madre and Cordillera mountain ranges.',
  'REGION_III': 'Known as the Rice Granary of the Philippines.',
  'REGION_IV_A': 'Cavite, Laguna, Batangas, Rizal, and Quezon.',
  'REGION_IV_B':
      'Mindoro, Marinduque, Romblon, and Palawan, known as the Last Frontier.',
  'REGION_V':
      'Home to Mayon Volcano and dishes made with coconut milk and chili.',
  'REGION_VI': 'Aklan, Antique, Capiz, Guimaras, and Iloilo, known for Boracay and the Dinagyang Festival.',
  'REGION_VII': 'Cebu and Bohol, home to the Chocolate Hills, the Sinulog Festival, and Mactan.',
  'REGION_VIII': 'Leyte, Samar, Biliran, and the San Juanico Bridge.',
  'REGION_IX':
      "Zamboanga City, known as Asia's Latin City, and colorful vinta boats.",
  'REGION_X': 'Bukidnon, Camiguin, Lanao del Norte, and the Misamis provinces.',
  'REGION_XI': 'Home to Mount Apo and the Philippine eagle.',
  'REGION_XII': 'South Cotabato, Cotabato, Sultan Kudarat, Sarangani, and General Santos.',
  'REGION_XIII':
      'Known for Siargao, the Surfing Capital, and the Enchanted River.',
  'BARMM': 'Rich in Islamic culture, the heritage of Lake Lanao, and history.',
  'NIR': 'Negros Occidental, Negros Oriental, and Siquijor (Republic Act No. 12000).',
};

String regionDescription(Region region, {required bool english}) => english
    ? regionDescriptionsEnglish[region.code] ?? region.description
    : region.description;
