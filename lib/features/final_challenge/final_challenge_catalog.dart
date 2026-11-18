import 'dart:math';

import '../regions/models/region.dart';
import '../regions/providers/region_provider.dart';
import '../word_search/models/regional_word.dart';

part 'final_trivia_words.dart';

/// Each clue uses its existing region ID and the passport's verified photograph.
class FinalChallengeClue {
  const FinalChallengeClue(
    this.regionId,
    this.word,
    this.english,
    this.filipino, {
    this.isTriviaWord = false,
    this.imagePath,
    this.captionEn,
    this.captionFil,
    this.factEn,
    this.factFil,
  });
  final int regionId;
  final String word, english, filipino;
  final bool isTriviaWord;
  final String? imagePath, captionEn, captionFil, factEn, factFil;

  RegionalWord get target => RegionalWord(
    regionId: regionId,
    word: word,
    category: isTriviaWord ? 'Trivia' : 'Landmark',
    clue: filipino,
    clueEn: english,
    imagePath: imagePath,
    factEn: factEn,
    factFil: factFil,
  );
}

const finalChallengeCatalog = [
  FinalChallengeClue(
    1,
    'RIZAL',
    'Which national hero is honored by the monument in Luneta, Manila?',
    'Sinong pambansang bayani ang pinararangalan ng monumento sa Luneta, Maynila?',
  ),
  FinalChallengeClue(
    2,
    'BANAUE',
    'Which Ifugao town is famous for rice terraces carved into its mountains?',
    'Aling bayan sa Ifugao ang tanyag sa hagdan-hagdang palayan sa kabundukan?',
  ),
  FinalChallengeClue(
    3,
    'PAOAY',
    'Which Ilocos Norte town is home to a historic church with massive side buttresses?',
    'Aling bayan sa Ilocos Norte ang may makasaysayang simbahan na may malalaking tukod sa gilid?',
  ),
  FinalChallengeClue(
    4,
    'CALLAO',
    'What is the name of the Cagayan cave with a chapel inside one of its chambers?',
    'Ano ang pangalan ng kuweba sa Cagayan na may kapilya sa isang silid nito?',
  ),
  FinalChallengeClue(
    5,
    'PINATUBO',
    'Which Central Luzon volcano has a crater lake and erupted in 1991?',
    'Aling bulkan sa Gitnang Luzon ang may lawa sa bunganga at pumutok noong 1991?',
  ),
  FinalChallengeClue(
    6,
    'TAAL',
    'Which Batangas volcano stands on an island within a lake?',
    'Aling bulkan sa Batangas ang nasa isang pulo sa loob ng lawa?',
  ),
  FinalChallengeClue(
    7,
    'PALAWAN',
    'Which island province is home to the Puerto Princesa Underground River?',
    'Saang lalawigang pulo matatagpuan ang Puerto Princesa Underground River?',
  ),
  FinalChallengeClue(
    8,
    'MAYON',
    'Which Albay volcano is famous for its nearly perfect cone?',
    'Aling bulkan sa Albay ang tanyag sa halos perpektong hugis-kono nito?',
  ),
  FinalChallengeClue(
    9,
    'MIAGAO',
    'Which Iloilo town has a historic church with a carved coconut tree on its facade?',
    'Aling bayan sa Iloilo ang may makasaysayang simbahan na may nakaukit na puno ng niyog sa harapan?',
  ),
  FinalChallengeClue(
    10,
    'BOHOL',
    'Which Visayan province is home to the Chocolate Hills?',
    'Saang lalawigan sa Visayas matatagpuan ang Chocolate Hills?',
  ),
  FinalChallengeClue(
    11,
    'SANJUANICO',
    'Which bridge connects the islands of Leyte and Samar? Write its name without spaces.',
    'Aling tulay ang nag-uugnay sa Leyte at Samar? Isulat ang pangalan nang walang pagitan.',
  ),
  FinalChallengeClue(
    12,
    'SANTACRUZ',
    'Which Great island near Zamboanga City is known for pink sand? Write its name without spaces.',
    'Aling Great island malapit sa Zamboanga City ang kilala sa kulay-rosas na buhangin? Isulat ang pangalan nang walang pagitan.',
  ),
  FinalChallengeClue(
    13,
    'MARIACRISTINA',
    'Which famous waterfall is found in Iligan City? Write its name without spaces.',
    'Aling tanyag na talon ang matatagpuan sa Iligan City? Isulat ang pangalan nang walang pagitan.',
  ),
  FinalChallengeClue(
    14,
    'APO',
    'What is the name of the highest mountain in the Philippines, shared by Davao and Cotabato?',
    'Ano ang pangalan ng pinakamataas na bundok sa Pilipinas na sakop ng Davao at Cotabato?',
  ),
  FinalChallengeClue(
    15,
    'LAKESEBU',
    'Which South Cotabato destination is known for its lakes and Tboli culture? Write its name without spaces.',
    'Aling lugar sa South Cotabato ang kilala sa mga lawa at kultura ng Tboli? Isulat ang pangalan nang walang pagitan.',
  ),
  FinalChallengeClue(
    16,
    'SIARGAO',
    'Which island in Surigao del Norte is famous for surfing at Cloud 9?',
    'Aling pulo sa Surigao del Norte ang tanyag sa surfing sa Cloud 9?',
  ),
  FinalChallengeClue(
    17,
    'COTABATO',
    'In which city can you visit the Sultan Haji Hassanal Bolkiah Grand Mosque?',
    'Saang lungsod matatagpuan ang Sultan Haji Hassanal Bolkiah Grand Mosque?',
  ),
  FinalChallengeClue(
    18,
    'THERUINS',
    'What is the name of the famous mansion remains in Talisay, Negros Occidental? Write its name without spaces.',
    'Ano ang pangalan ng tanyag na labi ng mansiyon sa Talisay, Negros Occidental? Isulat ang pangalan nang walang pagitan.',
  ),
];

bool finalChallengeUnlocked(Iterable<Region> regions) {
  final saved = {for (final region in regions) region.id: region};
  return defaultPhilippineRegions.every((expected) {
    final region = saved[expected.id];
    return region != null &&
        region.code == expected.code &&
        region.isUnlocked &&
        region.starsEarned > 0;
  });
}

/// Fifteen different regions per round, always including NIR and all island groups.
List<int> selectFinalRegions(int seed) {
  final random = Random(seed);
  final selected = <int>{18};
  for (final group in ['Luzon', 'Mindanao']) {
    final candidates =
        defaultPhilippineRegions
            .where((region) => region.islandGroup == group)
            .toList()
          ..shuffle(random);
    selected.add(candidates.first.id);
  }
  final remaining =
      finalChallengeCatalog
          .map((clue) => clue.regionId)
          .where((id) => !selected.contains(id))
          .toList()
        ..shuffle(random);
  selected.addAll(remaining.take(15 - selected.length));
  return selected.toList()..shuffle(random);
}
