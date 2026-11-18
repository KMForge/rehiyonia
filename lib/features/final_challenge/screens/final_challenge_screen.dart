import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/rehiyonia_adventure_background.dart';
import '../../avatar/widgets/player_avatar_widget.dart';
import '../../profile/providers/profile_provider.dart';
import '../../regions/providers/region_provider.dart';
import '../final_challenge_provider.dart';

class FinalChallengeScreen extends ConsumerWidget {
  const FinalChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final english = ref.watch(localizationsProvider).isEnglish;
    final unlocked = ref.watch(finalChallengeUnlockedProvider);
    final title = english
        ? 'Final Mixed-Region Challenge'
        : 'Panghuling Hamon ng mga Rehiyon';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: RehiyoniaAdventureBackground.sky,
        foregroundColor: RehiyoniaAdventureBackground.ink,
        title: Text(
          title,
          maxLines: 2,
          style: const TextStyle(fontFamily: 'Fredoka', fontSize: 19),
        ),
      ),
      body: RehiyoniaAdventureBackground(
        child: SizedBox.expand(
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      PlayerAvatarWidget(
                        avatar: ref.watch(profileProvider).avatar,
                        size: 120,
                        fullBody: true,
                        showBorder: false,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 25,
                          color: RehiyoniaAdventureBackground.ink,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        color: RehiyoniaAdventureBackground.cream,
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Text(
                            english
                                ? 'Find all 15 words in the list. Places and landmarks are mixed with words from regional trivia, such as festivals, crafts, and traditions. Every box contains a word name. Each discovery automatically opens its matching real photograph and travel fact. Close the photo to continue searching. Words with several parts have no spaces in the grid.\n\nEvery round mixes Luzon, Visayas, and Mindanao, including the Negros Island Region. Your progress is saved automatically.'
                                : 'Hanapin ang 15 salita sa listahan. Halo ang mga lugar at salitang mula sa trivia tungkol sa mga pista, likhang-sining, at tradisyon. Pangalan ng salita ang nasa bawat kahon. Awtomatikong lalabas ang tamang larawan at kaalaman kapag nahanap ang salita. Isara ang larawan upang magpatuloy. Walang pagitan ang mga salita sa palaisipan.\n\nHalo ang Luzon, Visayas, at Mindanao, kasama ang Negros Island Region. Awtomatikong naka-save ang progreso.',
                            style: const TextStyle(fontSize: 15, height: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!unlocked)
                        Text(
                          ref.watch(regionsProvider).isLoading
                              ? english
                                    ? 'Loading your journey…'
                                    : 'Binabasa ang iyong paglalakbay…'
                              : english
                              ? 'Complete all 18 regions to unlock this challenge.'
                              : 'Tapusin ang lahat ng 18 rehiyon upang mabuksan ang hamon.',
                          key: const Key('final_challenge_locked'),
                          textAlign: TextAlign.center,
                        )
                      else
                        ref
                            .watch(finalChallengeProgressProvider)
                            .when(
                              loading: () => const CircularProgressIndicator(),
                              error: (_, _) => TextButton(
                                onPressed: () => ref.invalidate(
                                  finalChallengeProgressProvider,
                                ),
                                child: Text(english ? 'Retry' : 'Subukan muli'),
                              ),
                              data: (progress) => Column(
                                children: [
                                  if (progress != null) ...[
                                    Text(
                                      progress.completed
                                          ? english
                                                ? 'Challenge complete! Best: ${progress.bestStars} / 3 stars'
                                                : 'Tapos na ang hamon! Pinakamahusay: ${progress.bestStars} / 3 bituin'
                                          : english
                                          ? 'Found: ${progress.found.length} / 15'
                                          : 'Nahanap: ${progress.found.length} / 15',
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  FilledButton.icon(
                                    key: const Key('start_final_challenge'),
                                    style:
                                        FilledButton.styleFrom(
                                          backgroundColor:
                                              RehiyoniaAdventureBackground
                                                  .mauve,
                                          foregroundColor:
                                              RehiyoniaAdventureBackground.ink,
                                          minimumSize: const Size(0, 48),
                                        ).copyWith(
                                          backgroundBuilder:
                                              RehiyoniaAdventureBackground
                                                  .glossyMauve,
                                        ),
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      AppRouter.finalGame,
                                      arguments: progress?.completed ?? false,
                                    ),
                                    icon: const Icon(Icons.play_arrow_rounded),
                                    label: Text(
                                      progress?.completed == true
                                          ? english
                                                ? 'Play again'
                                                : 'Maglaro muli'
                                          : progress != null &&
                                                progress.found.isNotEmpty
                                          ? english
                                                ? 'Resume challenge'
                                                : 'Ipagpatuloy ang hamon'
                                          : english
                                          ? 'Start final challenge'
                                          : 'Simulan ang panghuling hamon',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
