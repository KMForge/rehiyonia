# Rehiyonia UI and Avatar Improvement Plan

Planning date: October 13, 2026

## 1. Outcome and scope

Make Rehiyonia feel like a Philippine exploration adventure with a word-search activity at its center. The player should have a recognizable explorer, a clear next destination, satisfying discoveries, and a visible record of what they have learned.

This document plans improvements to the splash, navigation, home, regional exploration, gameplay presentation, trivia, achievements, settings, animation, and avatar customization. It does not implement them. Existing puzzle rules, hints, coins, stars, unlocking, educational content, localization, and saved progress must survive the redesign.

Visual improvements alone cannot guarantee that the game is enjoyable. Prototype the core journey with Grade 5 pupils and use observed task completion, readability, and engagement to guide revisions.

## 2. Current repository findings

These facts were verified from source files during this planning session:

| Area | Existing implementation | Implication |
|---|---|---|
| App | Minimal main, Riverpod, Material 3 theme, localized app | Extend the current foundation |
| Home | Profile chip, coin/star information, Play, avatar, badges, settings, mascot | Improve hierarchy and the next-action experience |
| Splash | Mascot, gradient, scale/fade animation, 1.8-second minimum display | Refine branding and startup behavior |
| Initialization | Async provider with retry; splash catches failures and then navigates | Show a recoverable failure instead of advancing after failure |
| Avatar | CustomPainter portrait with skin, hair style/color, outfit color, one accessory index | Full-body customization needs a new composition model |
| Avatar studio | Category chips, color palettes, text-based choices, preview and Save | Add visual item thumbnails, separate slots, and explicit save states |
| Persistence | SQLite version 2; avatar fields in player_profile; profile notifier performs persistence | Add backward-compatible migration and feature-owned repository |
| Gameplay | Grid gestures, found-word colors, word list, clues, completion dialog | Preserve selection geometry while improving presentation |
| Content | Locality images, JSON content, bundled music and sound effects | Reuse assets after checking quality and rights |
| Language | English/Filipino localization files and language tests | Localize new labels and support longer text |
| Tests | Avatar, mascot, home, gameplay, repositories, migrations and integration tests exist | Extend relevant suites and preserve regression coverage |

The earlier IMPLEMENTATION_PLAN.md has historical audit statements that no longer describe the current code. This plan uses the files present today rather than assuming the application is still a counter scaffold.

No device screenshots, user studies, benchmark results, or successful test/build results were obtained in this session. Actual appearance, startup route behavior, device performance, and asset licensing require verification during implementation.

## 3. Visual direction: My Philippine Explorer

Use a coherent illustrated travel-journal style: warm paper surfaces, ocean-blue actions, teal discovery accents, restrained sun-yellow rewards, rounded explorer characters, and passport stamps. Keep the existing Bayanito mascot recognizable while refining its consistency with the avatar artwork.

The game should feel youthful without making Grade 5 pupils feel that it is designed for toddlers. Avoid placing heavy gradients, thick borders, large shadows, badges, and bouncing decoration on every element.

### Design system

- One primary action per screen; secondary actions stay visually quieter.
- Proposed spacing scale: 4, 8, 12, 16, 24, 32 logical pixels.
- Proposed corner scale: 12 for compact controls, 20 for cards, 28 for major sheets.
- Provisional colors: ink #16324F, ocean #1465C0, teal #087F8C, paper #FFF9EF, white #FFFFFF, and sun #F4B942. Validate every actual foreground/background pair before shipping.
- Yellow is an accent with dark text, not a default text color on white.
- Prefer solid surfaces and one subtle elevation treatment over layered decoration.
- Body text usually 16 logical pixels; key titles 24–32; labels 14–16, with text scaling support.
- Start with the platform font. Consider one licensed, locally bundled rounded font only after confirming English/Filipino glyph coverage and readability.
- Minimum 48-by-48 logical-pixel targets for controls. Dense grid cells need a separate interaction strategy; do not pretend each small letter cell meets that target.
- Shared widgets use ThemeData/ThemeExtension tokens. New visual tokens belong in app theme files; avoid adding further presentation responsibilities to core.

## 4. Player journey and screen improvements

### Splash and startup

Match the native Android launch background to the Flutter splash to avoid a flash. Show the title, a restrained island silhouette, and a short Bayanito greeting. Avoid unsupported institutional seals or endorsement claims.

Animate the logo in about 300–500 ms and a small mascot greeting in about 600–900 ms. These are animation budgets, not a compulsory wait. Navigate as soon as initialization and any necessary transition are ready. Repeated launches should not force the current 1.8-second delay.

Loading text must describe actual work without fabricated percentages. On failure, show a friendly message and Retry; do not silently continue. Verify that startup routes cannot bypass initialization. Slow startup must still leave controls and status understandable.

### Home and profile

Make the player's explorer and current destination the main focus. Use a concise greeting, a prominent Continue Journey/Explore Regions action, and a compact passport summary showing completed destinations and existing stars.

Proposed hierarchy:

```text
Greeting + avatar                     Coins
Current destination illustration / journey card
             [Continue Journey]
Passport progress                     View passport
Explore regions     Dress explorer     Badges
Settings and Help as quieter actions
```

Continue Journey must be derived from saved progress; new players see Start Exploring. Do not invent a separate progression system to support this card.

Profile should open a meaningful profile view with name, full-body explorer, saved appearance, and progress. Keep quick name editing accessible. Avoid adding a bottom navigation bar until enough real destinations justify one.

### Island groups and regions

Use illustrated Luzon, Visayas, and Mindanao cards, then a region collection/journey view with clear completed, available, and locked states. Give every item its name, star state, and an understandable lock explanation.

Use a simplified map as optional context; retain a readable list/cards as the main navigation so small shapes are not the only tap targets. Educational boundaries and labels must be checked against approved project data. Do not change region counts or unlock rules during this visual work.

Region introduction becomes a destination card: hero image, region name, short description, learning preview, and Start. Learning cards retain accurate local images and use progressive disclosure instead of long walls of text.

### Word Search

Prioritize the board and touch accuracy. Show a compact region header, words-found count, readable board, word list, and a clear Hint control with the existing cost.

- Maintain letter positions and board dimensions during dragging.
- Use a continuous rounded selection path plus readable letters.
- Show found words with a check/strike treatment as well as color.
- Briefly acknowledge a found word; queue educational detail until it cannot interrupt an active drag.
- Keep mascot reactions small or pause them during selection.
- Provide a discoverable tutorial for drag selection and supported directions.
- Consider tap-start/tap-end selection as an accessibility enhancement, implemented through the existing validator and separately tested.
- Preserve grid geometry for diagonal selection and overlapping words.
- Do not add timed pressure, lives, penalties, or combos as part of a visual refresh.

### Trivia and results

Use discovery cards with an image where available, a short fact, and clear feedback. Existing pre-game and word-found trivia remain in their current learning sequence unless a flow change is explicitly approved.

Completion becomes a clear result sheet: region title, actual earned stars and coins, learned-item summary, and Continue/Replay. Animate existing rewards only after their persistence succeeds; an animation must never award coins a second time.

### Badges, passport, gallery, and settings

Present earned badges as a travel collection with locked silhouettes and clear existing conditions. The passport is a visual summary of actual progress, not another completion database. Keep cultural imagery respectful and accurately described.

Gallery uses organized image cards and loading/error fallbacks. Settings groups language, music, sound, motion, and help with explicit labels and immediate feedback. Add a persisted Reduce Motion option when motion infrastructure is implemented; respect the OS setting as well.

## 5. Avatar system: male and female explorer characters

Provide distinct male and female starting character designs with child-appropriate illustrated proportions, faces, poses, and silhouettes. These are appearance presets, not restrictions on the child's identity or wardrobe. Allow either character to use any compatible hairstyle and clothing item.

Use a full-body preview in the studio and a head/shoulder crop of the same character for compact profile chips. Support these independent customization categories:

| Slot | Starter examples | Rule |
|---|---|---|
| Character/base | Male, female | Changing base preserves compatible items |
| Skin | Inclusive natural tones | Keep a separate skin palette |
| Hair | Short, curly, bob, ponytail, braids, long | Style and color independent |
| Headwear | None, cap, explorer hat | Apply defined hair visibility rules |
| Glasses | None, round, rectangular | Can coexist with necklace and hat |
| Necklace/chain | None, simple chain, small pendant | Age-appropriate, non-branded designs |
| Top | T-shirt, polo, light jacket | Style and color separate |
| Bottom | Pants, shorts, optional skirt | Compatible with either base |
| Shoes | Sneakers, sandals | Visible in full-body preview |

Start with a small, polished wardrobe: two bases, four hairstyles, two glasses, two necklace options, three tops, two bottoms, and two shoe designs, plus a None option for removable accessories. Expand only after checking every combination. Additional hair and clothing categories can follow.

### Studio interaction

Use a large full-body preview, a male/female base selector, scrollable category tabs with icons and labels, visual item thumbnails, and a visible Save action. Selected items need a check and outline, not just color.

Keep edits in a draft provider. Support Reset, discard-on-exit confirmation for unsaved changes, and a saved/failed state. Save must await persistence before showing success. Preview changes must not overwrite the profile before Save. Undo is a later enhancement, not required for the first wardrobe release.

Small idle breathing, blinking, and a save wave can make the explorer feel alive. Stop idle animation offscreen and provide static poses when reduced motion is enabled.

### Rendering and artwork pipeline

Recommended first implementation: extend the existing vector/CustomPainter approach using reusable paths and a single canonical coordinate system. It fits the current offline setup and avoids a new renderer dependency. Prototype both bases and several clothing combinations before committing to a large art library.

Define normalized anchors for eyes, head, neck, waist, feet, and accessories. Compose back hair, body, bottoms, footwear, tops, face, front hair, headwear, necklace, and glasses in an explicitly tested order. Layer placement can vary by approved item metadata; do not rely on accidental painter order.

If professional illustrated raster assets are later preferred, bundle aligned transparent layers with consistent canvas sizes and anchors. That requires a separate asset-production step. Avoid mixing styles or generating every combination as a separate image. No image generation is needed to create this plan.

### Data and migration

Replace index-only configuration gradually with stable catalog IDs such as hair_short_01 and bottoms_shorts_01. Do not use display labels or list positions as persistent identity.

Proposed PlayerAvatar fields: baseId, skinToneId, hairStyleId, hairColorId, headwearId, glassesId, necklaceId, topId, topColorId, bottomId, bottomColorId, shoesId, and avatarSchemaVersion. Keep this model pure Dart; move Flutter colors into renderer/catalog presentation mapping. Update copyWith, serialization, equality, and UserProfile equality/hash together.

Store catalog compatibility and display metadata in one place. Missing or retired IDs resolve to safe defaults. Do not store complete rendered avatar images in SQLite.

Add an additive migration from the verified version-2 profile schema to the next approved database version. A versioned avatar JSON column is a practical candidate; settle the exact schema before implementation. Map current skin/hair/outfit indices and each existing accessory to the new slots, preserve legacy values during migration, and assign safe defaults for new fields. Do not infer a user's gender from an old hairstyle; let the player choose a preset.

Move profile queries into profile_repository.dart as part of this work. Avoid silently swallowing save errors. Preserve name, coins, stars, achievements, and region progress. Test both newly created and upgraded databases, with fixtures for every existing accessory value.

Starter customization should be free. Cosmetic purchases, ownership tables, region-unlocked clothing, and prices are optional later game-design decisions. They must not be silently added to the existing hint economy.

## 6. Animation and feedback specification

| Event | Proposed feedback | Budget/behavior |
|---|---|---|
| Button press | Small compression and ink response | 80–120 ms |
| Route transition | Short fade/slide | 180–250 ms |
| Studio item change | Short crossfade | 120–180 ms |
| Avatar idle | Subtle blink/breath | Studio/home only; pause offscreen |
| Found word | Highlight settle, check, optional sound/haptic | 200–350 ms; preserve drag geometry |
| Badge earned | Stamp/pop | 350–500 ms; one event |
| Results | Stars revealed in sequence | Total about 700–1000 ms; controls immediately usable |
| Celebration | Small bounded particles | Under one second; optional and never over active grid |

These are proposed budgets requiring device validation. Use Flutter animation primitives first. Add Rive/Lottie or another dependency only if a specific approved animation cannot be maintained with existing code and its runtime cost is justified.

Sound playback stays in AudioService. Motion widgets react to state events; business rules determine rewards. Stable event IDs prevent repeated celebration/audio after rebuilds or navigation. Haptics are optional feedback, not the only indication of success.

Reduced motion removes repeating movement, spring overshoot, large spatial transitions, and particles while preserving instant state changes and readable confirmations. Respect both OS preferences and in-app settings.

## 7. Proposed code changes

Reuse existing routes and feature ownership. Create only files with real implementation.

| Existing file/area | Planned change |
|---|---|
| lib/app/app_theme.dart | Central text, spacing, component and motion tokens |
| lib/core/theme/app_colors.dart | Preserve during adoption; assess moving visual tokens to app/theme after references are updated |
| lib/features/splash/screens/splash_screen.dart | Branding, real initialization states, retry, route-on-success |
| lib/features/home/screens/home_screen.dart | Journey hierarchy and explorer preview |
| lib/features/profile/models/user_profile.dart | Correct expanded avatar equality/hash |
| lib/features/profile/providers/profile_provider.dart | Repository-backed saves and visible errors |
| lib/features/profile/data/repositories/profile_repository.dart | New feature-owned persistence boundary |
| lib/features/avatar/models/player_avatar.dart | Stable-ID, versioned configuration |
| lib/features/avatar/models/avatar_item.dart | New catalog item/compatibility model |
| lib/features/avatar/data/avatar_catalog.dart | New starter catalog and legacy mappings |
| lib/features/avatar/providers/avatar_editor_provider.dart | New draft/save/discard state |
| lib/features/avatar/widgets/player_avatar_widget.dart | Full-body/portrait rendering modes |
| lib/features/avatar/widgets/avatar_item_tile.dart | New visual wardrobe choices |
| lib/features/avatar/screens/avatar_studio_screen.dart | Full-body editor and independent slots |
| lib/features/mascot/widgets/bayanito_mascot_widget.dart | Consistent, motion-aware reactions |
| lib/features/regions/screens/ | Destination/journey presentation |
| lib/features/learning/screens/ and lib/features/trivia/screens/ | Readable discovery cards |
| lib/features/word_search/screens/ and widgets/ | Board hierarchy, feedback, result presentation |
| lib/features/badges/screens/badge_gallery_screen.dart | Passport/collection presentation |
| lib/features/settings/ | Motion settings and clearer controls |
| lib/shared/widgets/ | Reusable button/card/progress components only after actual reuse |
| lib/core/database/ | Approved additive avatar migration |
| lib/l10n/app_en.arb and app_fil.arb | New translated labels; regenerate localization outputs |
| pubspec.yaml | Only approved real local assets/fonts or justified packages |

## 8. Implementation sequence and acceptance gates

### Phase A: Baseline and visual prototype

Capture current screenshots and navigation on Android. Record startup, grid responsiveness, and existing save behavior. Prepare home, gameplay, and studio wireframes, two character designs, and a small component board.

Acceptance: the design has one coherent style, both character presets, a readable small-phone layout, and agreement on the starter wardrobe. No release-wide restyle before this checkpoint.

### Phase B: Shared theme, splash, and home

Implement theme tokens, reusable controls, startup recovery, and home hierarchy. Keep existing navigation/test keys where practical. Add motion preference support before introducing repeating animations.

Acceptance: cold/warm launch succeeds, failures offer Retry, the home has a clear primary action, English/Filipino labels fit, and enlarged text does not hide controls.

### Phase C: Avatar model, migration, and studio

Implement catalog/compatibility, repository, migration, draft provider, full-body composition, portrait crop, and the starter wardrobe. Migrate profiles before switching renderers.

Acceptance: male/female bases can be switched; hair, glasses, chain, top, bottoms, and shoes can coexist; saved selections survive restart; Save failure does not report success; Cancel discards only draft edits; existing progress is preserved.

### Phase D: Journey, learning, gameplay, and collections

Refresh region selection/introduction, learning/trivia cards, grid feedback, results, and badges. Use passport presentation to connect existing discoveries to progress.

Acceptance: existing puzzles, unlocking, hint costs, coin rewards, and star rules remain correct; active drag is uninterrupted; result animation cannot duplicate rewards; all region states remain understandable.

### Phase E: Polish and pupil validation

Profile animations on a representative low/mid-range Android phone, test offline, check small screens and large text, and run usability sessions with appropriate school/guardian arrangements.

Acceptance: no regression in persistence or gesture accuracy, no missing offline assets, motion can be reduced, pupils can find Play and customize/save without coaching, and repeated errors or confusion are addressed.

Deliver a changed-file list and verification results after each phase. Any wardrobe monetization, new reward mechanics, or gameplay modes needs a separate design decision.

## 9. Testing and performance

- Unit-test catalog IDs, compatibility, defaults, legacy mapping, serialization, and equality.
- Test migration using version-2 profiles and confirm unchanged coins/stars/region progress.
- Test draft isolation, base switching, independent accessory slots, Save failure, retry, Reset, and unsaved navigation.
- Add representative visual/golden tests for both bases, overlapping hair/headwear, necklaces over tops, pants/shorts, and portrait cropping; supplement with device review.
- Test splash loading/error/retry and successful navigation without duplicate routes.
- Test gestures across board sizes and overlapping words after the visual changes.
- Test both languages, text scaling, TalkBack labels, color-independent selected/found states, and Reduce Motion.
- Test close/reopen and offline launch with Wi-Fi/mobile data disabled.
- Measure frame timing in profile mode on physical Android hardware. Target smooth 60-Hz rendering where supported; report observed results rather than guaranteeing frame rate.
- Avoid per-cell controllers, large blur effects, unlimited particles, and continuously ticking offscreen characters. Cache painter geometry and isolate animated areas where profiling justifies it.

After each implementation phase run:

```bash
dart format .
flutter analyze
flutter test
flutter build apk --debug
```

Run relevant integration tests on a selected Android target. Record device, build mode, actual command outcomes, and skipped checks. This planning-only change does not establish test/build health.

## 10. Delivery scope

First playable visual upgrade: shared theme, startup recovery, clearer home, two full-body bases, starter clothing/accessories, safe avatar saves, and modest gameplay feedback.

Later optional additions: more hairstyles/outfits, region-themed cosmetics, elaborate character rigs, additional map animation, and a cosmetic shop. Prioritize coherent art, fast controls, and readable learning content before expanding effects or inventory.

This plan is ready for a UI implementation pass. No app source, assets, dependencies, or database data were changed while writing it.
