import 'package:flutter/material.dart';

/// Rehiyonia Design System - Soft Pastel Palette
/// Tailored for Grade 5 pupils with high readability, gentle warmth, and no harsh neon tones.
abstract final class AppColors {
  // Brand Primaries
  static const babyBlue = Color(
    0xFFA9D6F5,
  ); // Main brand surface & hero elements
  static const deepBlue = Color(0xFF4F8FC0); // Primary action buttons & headers

  // Brand Accents
  static const pastelPink = Color(
    0xFFF7B7C8,
  ); // Secondary badges, highlights, mascot scarf
  static const softLavender = Color(
    0xFFDCC6F0,
  ); // Card surfaces, tag containers

  // Neutrals & Backgrounds
  static const lightCream = Color(
    0xFFFFF9F2,
  ); // Game canvas & scaffold background
  static const surfaceWhite = Color(0xFFFFFFFF); // Layered card surfaces
  static const textNavy = Color(
    0xFF264653,
  ); // High-contrast readable body & titles
  static const mutedSlate = Color(0xFF64748B); // Subtitles, counters, borders

  // Feedback Tokens
  static const successMint = Color(
    0xFFA7E8BD,
  ); // Correct trivia, found word highlight
  static const warningPeach = Color(
    0xFFFFD6A5,
  ); // Hint highlight, warning states
}
