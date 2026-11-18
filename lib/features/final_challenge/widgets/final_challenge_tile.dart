import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/rehiyonia_adventure_background.dart';
import '../../regions/providers/region_provider.dart';
import '../final_challenge_provider.dart';

class FinalChallengeTile extends ConsumerWidget {
  const FinalChallengeTile({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final english = ref.watch(localizationsProvider).isEnglish;
    final unlocked = ref.watch(finalChallengeUnlockedProvider);
    final regions = ref.watch(regionsProvider).asData?.value ?? [];
    final completed = defaultPhilippineRegions
        .where(
          (expected) => regions.any(
            (region) =>
                region.id == expected.id &&
                region.code == expected.code &&
                region.isUnlocked &&
                region.starsEarned > 0,
          ),
        )
        .length;
    return Card(
      color: RehiyoniaAdventureBackground.cream,
      child: ListTile(
        key: const Key('final_challenge_entry'),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          unlocked ? Icons.emoji_events_rounded : Icons.lock_outline,
          color: RehiyoniaAdventureBackground.mauve,
        ),
        title: Text(
          english
              ? 'Final Mixed-Region Challenge'
              : 'Panghuling Hamon ng mga Rehiyon',
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          unlocked
              ? english
                    ? '15 mixed words · Places, festivals, crafts and traditions'
                    : '15 halong salita · Lugar, pista, likhang-sining at tradisyon'
              : english
              ? 'Locked · Completed: $completed / 18 regions.\nFinish all 18 to unlock.'
              : 'Naka-lock · Tapos na: $completed / 18 rehiyon.\nTapusin ang 18 upang mabuksan.',
        ),
        trailing: unlocked ? const Icon(Icons.chevron_right) : null,
        onTap: unlocked
            ? () => Navigator.pushNamed(context, AppRouter.finalChallenge)
            : null,
      ),
    );
  }
}
