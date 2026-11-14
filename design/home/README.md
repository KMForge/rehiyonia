# Home screen implementation

The Home screen follows the supplied written design specification. A separate reference screenshot was not attached, so pixel-perfect correspondence has not been verified. The existing `rehiyonia-logo-pink-v2.png` supplies the pink-and-gold branding, sun/compass ornament, and waves. A Flutter ribbon supplies the localized subtitle. No replacement logo or new avatar system was created.

## Runtime UI

- `lib/features/home/screens/home_screen.dart`: existing destinations, live identity and rewards, region completion indicator, and existing help dialog. Selects the profile fields actually displayed to avoid rebuilding for unrelated wardrobe metadata.
- `lib/features/home/widgets/home_palette.dart`: requested Home palette.
- `rehiyonia_wordmark.dart`: existing logo asset and responsive subtitle ribbon.
- `home_player_header.dart`: saved-player profile, reduced slightly after review to a 60 px portrait frame, 17 px greeting, 23 px username, and an 80 px minimum-height cream pill with pink border and shadow. The pill fits the longer of the greeting or username instead of filling the row; short names leave only the normal right padding, while longer names wrap within the available width. Coins and settings stay anchored to the right edge, or move to a right-aligned row below the profile on narrow screens or with enlarged text.
- `pastel_adventure_background.dart`: independently positioned, proportionally sized sky, footer, and foliage assets; decode-size limits, decorative semantics exclusion, ignored pointer events, and a repaint boundary. Also contains the existing glossy button and menu surface components.
- `playful_explorer_stage.dart`: stitched cream card with the existing static full-body `PlayerAvatarWidget`, landscape, and interactive map. No additional avatar animation system.
- `adventure_menu.dart`, `philippine_journey_map.dart`, and `home_discovery_cards.dart`: matching palette, illustrated tiles, and existing geographic coastline geometry.

All widget paths above are relative to `lib/features/home/widgets/` unless a full project-relative path is shown.

## Assets

`home-travel-background.png` is retained here as the original artwork source, outside the Flutter asset bundle. The existing picture was split and JPEG-encoded at quality 88; the four runtime layers in `assets/images/branding/` total 182,825 bytes (approximately 179 KiB). Their artwork includes the jeepney and flag, mountain, historical bell tower, plants, camera, postcards, backpack, lantern, and compass. The UI, logo, avatar, map, and text remain separate functional layers.

Regenerate with:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/prepare_home_artwork.ps1
```

No additional artwork or package is required to run this version. The enlarged profile uses the locally bundled Fredoka variable font and accompanying SIL Open Font License in `assets/fonts/`; other Home typography remains unchanged. Exact reference-specific artwork would require the missing reference screenshot and any corresponding original assets.

## Saved data and behavior

The existing Riverpod providers and SQLite repositories remain authoritative. `ProfileRepository` loads player name, coins, stars, and serialized avatar customization; the avatar editor saves through `ProfileNotifier.setAvatar`. Home uses that same avatar model and renderer. Startup restores the profile before exposing Home. Existing gameplay invalidates the region provider and updates the profile after rewards.

Home retains the existing completion rule: a region counts only when `starsEarned > 0`; an unlocked region with no completion stars does not count. No database schema, saved data, reward calculation, unlocking rule, word-search behavior, or trivia behavior was changed for this refinement.

## Verification

Project-wide `flutter analyze --no-pub` completed with no issues. Forty-three regression tests passed across Home, avatar editing and database reopen persistence, profile state, learning navigation, gameplay, word-search generation, and trivia. Home layout coverage includes 320 px and 390 px portrait widths with enlarged text and a wider viewport. A separate rendered 430 x 1100 portrait preview was visually inspected. Android hardware performance has not been measured.

The subsequent enlarged-profile refinement passed project-wide analysis and 31 Home, avatar, persistence, and profile tests. This includes six checks at 320, 390, and 430 px widths with normal and 1.6x text, long saved names, large coin balances, safe-area insets, 72 px portrait frames, and profile/settings/logo separation. Header and main-card avatar equality is checked after saving and after restoring a fresh session. A separate 390 x 844 portrait preview was inspected with the real bundled Fredoka font loaded.
