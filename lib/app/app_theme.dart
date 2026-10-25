import 'package:flutter/material.dart';

import 'explorer_theme.dart';

abstract final class AppTheme {
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: ExplorerTheme.paper,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ExplorerTheme.ocean,
      primary: ExplorerTheme.ocean,
      secondary: ExplorerTheme.teal,
      surface: ExplorerTheme.paper,
      onSurface: ExplorerTheme.ink,
      error: const Color(0xFFB3261E),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ExplorerTheme.paper,
      foregroundColor: ExplorerTheme.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: ExplorerTheme.ink,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: ExplorerTheme.line),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    chipTheme: ChipThemeData(
      side: const BorderSide(color: ExplorerTheme.line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.all(8),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: ExplorerTheme.paper,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: ExplorerTheme.ink,
        letterSpacing: -1,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: ExplorerTheme.ink,
        letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: ExplorerTheme.ink,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: ExplorerTheme.ink,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: ExplorerTheme.ink),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.4,
        color: ExplorerTheme.ink,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        height: 1.4,
        color: ExplorerTheme.muted,
      ),
    ),
  );
}
