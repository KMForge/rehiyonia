# Rehiyonia

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
