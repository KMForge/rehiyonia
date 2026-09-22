import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

abstract final class AppTheme {
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.lightCream,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.deepBlue,
      onPrimary: Colors.white,
      primaryContainer: AppColors.babyBlue,
      onPrimaryContainer: AppColors.textNavy,
      secondary: AppColors.pastelPink,
      onSecondary: AppColors.textNavy,
      secondaryContainer: AppColors.softLavender,
      onSecondaryContainer: AppColors.textNavy,
      error: Color(0xFFE57373),
      onError: Colors.white,
      surface: AppColors.surfaceWhite,
      onSurface: AppColors.textNavy,
      outline: AppColors.mutedSlate,
      surfaceContainerHighest: AppColors.babyBlue,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightCream,
      foregroundColor: AppColors.textNavy,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.textNavy,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: AppColors.textNavy, size: 24),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceWhite,
      elevation: 2,
      shadowColor: AppColors.deepBlue.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.deepBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.deepBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size(48, 48),
        elevation: 2,
        shadowColor: AppColors.deepBlue.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.deepBlue,
        minimumSize: const Size(48, 48),
        side: const BorderSide(color: AppColors.deepBlue, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceWhite,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: const TextStyle(
        color: AppColors.textNavy,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: const TextStyle(
        color: AppColors.textNavy,
        fontSize: 15,
        height: 1.4,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textNavy,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textNavy,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textNavy,
      ),
      titleSmall: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textNavy,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textNavy,
        height: 1.4,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textNavy,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textNavy,
      ),
    ),
  );
}
