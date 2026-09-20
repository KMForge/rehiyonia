# Rehiyonia

**Rehiyonia: An Offline Educational Word Search Game for Philippine Regions**
is an Android game for Grade 5 pupils, built with Flutter and Dart.

## Current status

Phase 1 establishes the feature-first application structure. The Flutter
counter remains temporarily as a regression check and will be removed when the
real Rehiyonia home or main-menu screen is implemented.

## Source structure

```text
lib/
|-- main.dart                  # Minimal application entry point
|-- app/                       # Root widget, router, and theme
+-- features/                  # Feature-owned screens and behavior
```

Future non-visual shared infrastructure belongs in `core/`. Reusable
presentation components, shared models, and shared providers belong in
`shared/`. Directories are added only when they contain real implementation.

See [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) for the phased architecture,
safety gates, and verification requirements.

## Development checks

```bash
dart format .
flutter analyze
flutter test
flutter build apk --debug
```
