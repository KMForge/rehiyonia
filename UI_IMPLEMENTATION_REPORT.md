# UI implementation report

Updated: 2026-10-25

## Version 1.0.1: cinematic startup and wardrobe refresh

- Added bundled temporary Philippine-inspired loading artwork and transparent Rehiyonia logo. The imagegen skill's built-in generator produced the assets; exact prompts and paths are recorded in `assets/images/branding/README.md`.
- Replaced the spinner with a progress bar tied to four completed startup tasks: storage/content initialization, profile load, preference restoration, and identity check. Percentages represent startup milestones, not download bytes.
- Added a finite 900 ms logo reveal; the bar can show 100% while the reveal finishes. Reduce Motion bypasses this animation. There is no simulated download or repeating loading delay.
- First launch automatically opens a nickname-creation dialog before Home. Validation, saving state and retry are supported. Name plus onboarding flag are committed together in SQLite. Previously saved custom names bypass onboarding; an unnamed existing installation will be prompted once.
- Expanded the wardrobe with trail hoodies, explorer vests, cargo pants, boots, bucket hats and sunglasses. Added shaded fabrics, seams, pockets, face highlights and a dark character-display stage. Existing item IDs and saved outfits remain compatible.
- Added a rendered avatar golden baseline and inspected the two-base preview. The automated baseline is not a substitute for real-device review.
- Latest full unit/widget/golden suite: **66 tests passed**. New coverage includes automatic first-launch prompting, small-screen/reduced-motion splash, name validation/save failure/retry, and new wardrobe ID serialization.
- Android integration scripts now create an explorer on fresh storage and check the onboarding flag after reopening storage. They have **not been rerun for 1.0.1**, because the available emulator is offline. The three-test Android result below belongs to the earlier implementation.
- Version incremented to `1.0.1+2`. Release signing remains the existing debug key, suitable for sideload testing only.
- Final `flutter analyze` and `git diff --check`: passed. `flutter build apk --release`: passed on a sequential retry (the concurrent test/build attempt hit generated integration-plugin registration). APK: `build/app/outputs/flutter-apk/app-release.apk`, approximately 96.2 MB. This replaces the previous test APK with the new version.

## Delivered

- Shared Material 3 explorer theme: warm backgrounds, ocean accents, consistent cards, buttons and typography.
- Native Android launch styling and a Flutter splash driven by actual initialization, including failure/retry handling.
- Redesigned home, island/region selection, region introduction and badge passport; refreshed learning/trivia cards.
- Full-body male/female avatar bases with hair, skin/color choices, headwear, glasses, necklaces, tops, pants/shorts and shoes. Accessories occupy independent slots.
- Avatar draft editing with explicit Save, reset, unsaved-change confirmation and retryable save failures.
- Version-3 SQLite migration retaining legacy avatar fields and existing progress; stable avatar item IDs stored in JSON.
- Continuous word-selection paths, aligned grid hit testing, clearer word states, progress and completion feedback.
- English/Filipino UI labels and a persisted Reduce Motion preference honoring system animation settings.

Game rules, unlock rules, hint cost and rewards were not intentionally changed. No new packages, online services or paid cosmetic mechanics were added.

## Changed-file guide

| Area | Main files |
| --- | --- |
| Theme/startup | `lib/app/app_theme.dart`, `explorer_theme.dart`, `app_startup_provider.dart`, `app.dart`; `lib/features/splash/screens/splash_screen.dart`; Android launch drawables/styles |
| Shared visuals/copy | `lib/shared/widgets/explorer_card.dart`, `journey_landscape.dart`; `lib/shared/localization/explorer_strings.dart` |
| Avatar | `lib/features/avatar/data/avatar_catalog.dart`, `models/player_avatar.dart`, `providers/avatar_editor_provider.dart`, `screens/avatar_studio_screen.dart`, `widgets/player_avatar_widget.dart` |
| Storage/profile | `lib/core/database/app_database.dart`, `database_tables.dart`; `lib/core/constants/database_constants.dart`; `lib/features/profile/data/repositories/profile_repository.dart`, `providers/profile_provider.dart`, `models/user_profile.dart` |
| Screens | Home, regions, badges, learning, trivia and word-search screen/widget files under `lib/features/` |
| Motion/settings | `lib/features/settings/models/audio_preferences.dart`, `providers/settings_provider.dart`, `screens/settings_screen.dart`; mascot widget |
| Automated coverage | Avatar, home, settings, splash, migration and grid tests; `test/support/explorer_fakes.dart`; all three `integration_test/*_test.dart` files and isolated-storage helper |

## Verification

- `flutter analyze`: passed, no issues.
- `flutter test --reporter expanded`: all 60 tests passed.
- `flutter build apk --debug`: passed.
- `flutter test integration_test -d emulator-5554 --reporter expanded`: all 3 tests passed on the Pixel 7 Pro AVD (`sdk_gphone16k_x86_64`), debug mode.
- Integration coverage follows startup/navigation, region → learning → trivia → puzzle/hint, and actual database close/reopen for avatar and region progress.
- Integration storage is in-memory or a unique temporary database, not the normal player save.
- `git diff --check`: passed (Git emitted line-ending conversion warnings only).

## Remaining validation / limitations

- Android screenshot review is blocked: captures show a black surface with both the default renderer and a diagnostic `--no-enable-impeller` run, although the emulator integration tests pass. The app is foregrounded and the emulator is awake. The cause is not yet established; do not treat this as visual sign-off. No persistent renderer override was added.
- Physical low/mid-range Android frame-time profiling has not been performed. Debug emulator results do not establish production frame rate.
- Full TalkBack review, airplane-mode launch, pupil usability sessions and an avatar golden-image matrix remain pending.
- Artwork is code-drawn vector scenery and starter characters. Scenery is decorative, not a geographic map. Expanded outfits, elaborate character rigs and a shop are outside this pass.

The implementation covers the first playable visual upgrade in `UI_IMPROVEMENT_PLAN.md`; Phase E's device/user studies are not claimed complete.
