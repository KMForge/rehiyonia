# Rehiyonia

### Offline locality photographs

All 270 locality image paths now resolve to bundled photographs. The 50-photo
addition set includes the last four missing localities: Don Carlos (Lake
Pinamaloy lakeside park), Monkayo (jewelry training center opening), Santa Maria
in Davao Occidental (Basiawan cacao solar dryer), and Lingig (Palo Alto marine
hatchery). These facilities and park views are labelled accurately; they are
not presented as beach or waterfall photographs.

Photo authors, source URLs, licenses, bilingual captions, source checksums and
image dimensions are stored in `assets/data/locality_photo_credits.json`.
See `assets/images/localities/ADDITIONAL_PHOTO_SOURCES.md` for the photo list.
Run `powershell -ExecutionPolicy Bypass -File scripts/fetch_locality_photos.ps1`
and `dart tool/register_locality_photos.dart` to download and register reviewed
additions. Runtime photo overrides also work for old saved locality image paths.
The startup refresh updates those paths without resetting saved player data.

### Regional word discoveries

All 18 regional word-search screens share the same compact discovery dialog.
Finding a word opens its name, bundled locality photograph, and localized fact.
The word list remains visible, and a found word can reopen its photo. The last
photo closes before the level-completion dialog appears. Missing locality assets
use a verified photo from that region with an explicit regional-landmark label;
they are not presented as photographs of the named locality. No photographs are
downloaded during gameplay, and discoveries keep the existing reward rules.

### Final Mixed-Region Challenge

Completing all 18 existing regions unlocks a separate final challenge from Home,
Explore Regions, and the last regional completion dialog. It is not a 19th
region or badge. Each new round selects 15 distinct words
from the 18-region catalog, always including NIR and all three island groups.
The existing word-search engine mixes 8 landmark/place words with 7 vocabulary
words from existing regional trivia, such as SINULOG, MASSKARA, VINTA and INABEL.
All 15 boxes show plain word names, without questions or category labels. The
same 15 words are placed in one grid. Finding a word automatically opens its
matching landmark or cultural photograph, travel fact, and photo credits. The 15th
discovery shows its photograph before the final completion dialog. Found words
can be tapped to reopen their photos; unfound words do not reveal photos.

The final round, deterministic puzzle seed, found words, hints, completion, and
best stars are stored under `final_mixed_challenge_v1` in the existing SQLite
`user_progress` table. Discoveries and coin updates share a transaction, so a
repeated discovery cannot pay twice. The existing 5-coin discovery, 20-coin final
discovery, 10-coin hint, and hint-based star rules are reused. Regional records,
badges, and avatar customization are not changed by the final challenge.
Replaying creates a new round while retaining the best final-challenge stars.

The 18 regional landmark photos and 18 cultural trivia photos are reused offline
from `assets/images/region_landmarks/` and `assets/images/trivia/`. No manual
downloads are required. Photo source and license records remain in the existing
landmark README and `assets/data/culture_image_credits.json`.
`scripts/prepare_final_trivia_words.ps1` prepares the final trivia-word catalog
from the existing bilingual culture questions, explanations, and photo captions.
An in-progress older final round keeps its original words and discoveries;
new rounds include the trivia vocabulary.

The home illustration uses Philippine coastline geometry from the public-domain
Natural Earth 1:50m dataset. It depicts the archipelago and a decorative journey
through Luzon, Visayas, and Mindanao, rather than administrative boundaries.
The generated vector data is included for offline use. To regenerate it, run
`powershell -NoProfile -File scripts/generate_philippine_map.ps1`.

### Regional culture trivia

Each of the 18 regions now has its original question plus two questions about
local culture and traditions (54 questions in total). The new content is in
`assets/data/regional_culture.json`, including reference URLs. Photos appear
with the answer explanations and are bundled for offline use.

Photo authors, licenses, license links, and original Wikimedia Commons file
pages are recorded in `assets/data/culture_image_credits.json`. Each photo
retains its stated license, including CC BY-SA where applicable.
Run `powershell -NoProfile -File scripts/fetch_culture_images.ps1` to fetch
missing photos automatically; add `-Refresh` to download them again.
The downloader uses pinned file titles to preserve the reviewed selections.

Existing installations migrate the trivia tables and refresh both question
collections without clearing player profiles, coins, stars, or region progress.
Fully stop and restart the app after updating; hot reload does not run the
startup content migration.

### Temporary testing in Edge

Run `flutter run -d web-server --web-hostname localhost --web-port 8080`, then
open <http://localhost:8080> in Edge. In VS Code, select **Edge preview (open
localhost:8080)** under Run and Debug and press F5, then open the same URL.
This bypasses Flutter's automatic Edge debugger launch.

The web build uses SQLite WebAssembly with IndexedDB storage; Android and iOS
continue using native SQLite. Browser saves are separate from phone saves.
Keep the same browser and URL (including port) to reuse browser progress;
clearing site data removes it.

The required `web/sqlite3.wasm` and `web/sqflite_sw.js` files are included.
After upgrading the web SQLite dependencies, regenerate them with
`dart run sqflite_common_ffi_web:setup --force` before running or building web.

**Rehiyonia: An Offline Educational Word Search Game for Philippine Regions**  
*Araling Panlipunan • Grade 5 Curriculum Aligned*

Rehiyonia is an interactive, fully offline educational word search game for Android designed specifically for Grade 5 pupils in the Philippines. It teaches Philippine geography, culture, historical landmarks, provincial capitals, and regional trivia aligned with the official DepEd Araling Panlipunan curriculum.

---

## 🌟 Key Features

- **100% Offline Capability**: Complete zero-network architecture. All datasets, audio files, and database schemas are bundled locally on-device.
- **All 18 Philippine Regions**: Covers Luzon (NCR, CAR, Region I-V), Visayas (Region VI-VIII, and NIR - Negros Island Region), and Mindanao (Region IX-XIII, BARMM).
- **Curated Educational Words & Trivia**:
  - 108 regional terms across all 18 regions categorized by Province, Capital, Landmark, and Delicacy.
  - Grade 5 Araling Panlipunan trivia questions and cultural fun facts revealed upon level completion.
- **Smart Word Search Engine**:
  - High-performance algorithm generating 10x10 grids in <2ms.
  - 8-directional placement (horizontal, vertical, diagonal, and reverse).
  - Multi-touch gesture drag selection with color-coded completed word lines.
- **Engaging Game Economy & Hint Mechanics**:
  - Earn coins and stars for finding words and completing regions.
  - Use coins for smart hints highlighting the starting letter coordinate of unfound words.
  - Clue sheet popups displaying educational context and explanations.
- **Offline Audio Experience**:
  - Ambient background music and authentic sound effects (button clicks, word found, puzzle complete) bundled as lightweight PCM audio.

---

## 📐 Architecture & Layer Boundaries

Rehiyonia follows a strict **Feature-First Architecture** with decoupled layers:

```
lib/
├── app/                                 # Application shell
│   ├── app.dart                         # Root RehiyoniaApp widget
│   ├── app_router.dart                  # Central route map
│   └── app_theme.dart                   # Visual theme tokens & typography
├── core/                                # Non-visual shared core infrastructure
│   ├── constants/                       # App, database, and asset constants
│   ├── database/                        # SQLite AppDatabase & AssetSeedLoader
│   └── services/                        # AudioService & sound manager
├── features/                            # Feature-specific modules
│   ├── home/                            # Main menu and navigation
│   ├── regions/                         # Region selection & unlock progression
│   ├── trivia/                          # Regional AP trivia repository & models
│   └── word_search/                     # Core word search game
│       ├── data/                        # WordRepository & SQLite data access
│       ├── engine/                      # Pure Dart WordSearchEngine & generator
│       ├── models/                      # PuzzleCoordinate, PlacedWord, Puzzle
│       ├── providers/                   # Riverpod GameplayNotifier & state
│       ├── screens/                     # WordSearchScreen
│       └── widgets/                     # WordSearchGridWidget & WordListBar
└── shared/                              # Cross-feature reusable components
    ├── models/                          # Shared domain models
    ├── providers/                       # AppInitializationProvider
    └── widgets/                         # Reusable UI widgets
```

---

## 📂 Bundled Offline Assets

All media and educational datasets are stored locally in `assets/`:

- **Data**:
  - `assets/data/regions.json`: Canonical metadata for all 17 regions.
  - `assets/data/regional_words.json`: 102 verified Grade 5 regional terms.
  - `assets/data/trivia.json`: Araling Panlipunan trivia questions and explanations.
- **Audio**:
  - `assets/audio/music/main_theme.wav`: Offline menu & ambient soundtrack.
  - `assets/audio/sound_effects/button_click.wav`: Tactile UI interaction sound.
  - `assets/audio/sound_effects/word_found.wav`: Word discovery chime.
  - `assets/audio/sound_effects/puzzle_complete.wav`: Regional victory fanfare.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev) (v3.13+ or latest stable)
- [Android Studio](https://developer.android.com/studio) with Android SDK & NDK installed
- Android Emulator or physical device running Android 7.0+ (API 24+)

### Installation & Run

1. Clone the repository:
   ```bash
   git clone https://github.com/KMForge/rehiyonia.git
   cd rehiyonia
   ```

2. Fetch dependencies:
   ```bash
   flutter pub get
   ```

3. Launch on connected device or emulator:
   ```bash
   flutter run
   ```

---

## 🧪 Testing & Quality Gates

Rehiyonia maintains an extensive automated test suite covering pure Dart engines, database migrations, Riverpod state notifiers, UI widgets, and integration flows.

### Run All Unit & Widget Tests
```bash
flutter test
```
*Executes all 31+ unit, widget, and micro-benchmark tests.*

### Run Static Analysis
```bash
flutter analyze
```

### Code Formatting Check
```bash
dart format . --output=none --set-exit-if-changed
```

### Run Integration Tests on Emulator / Device
```bash
flutter test integration_test/app_launch_test.dart -d <device-id>
```

---

## ✈️ Offline Verification

To verify complete offline operation without internet connectivity:
1. Connect to Android device or emulator via ADB:
   ```bash
   adb shell cmd connectivity airplane-mode enable
   ```
2. Launch the app and play through any region puzzle.
3. Observe seamless audio playback, puzzle generation, hint mechanics, and SQLite persistence.
4. Disable airplane mode after testing:
   ```bash
   adb shell cmd connectivity airplane-mode disable
   ```

---

## 📦 Building Android APK

```bash
# Debug APK
flutter build apk --debug

# Production Release APK
flutter build apk --release
```
Output APK is located at: `build/app/outputs/flutter-apk/`

---

## 📄 License & Attribution

Designed and developed for Philippine educational advancement in Grade 5 Araling Panlipunan.
Curriculum data aligned with the Department of Education (DepEd) Philippines regional standards.
