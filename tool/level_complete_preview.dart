import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehiyonia/app/app_theme.dart';
import 'package:rehiyonia/features/word_search/screens/word_search_screen.dart';

/// Standalone UI preview: no startup, database access, or earned rewards.
void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Rehiyonia — Level Complete Preview',
        theme: AppTheme.light,
        home: const WordSearchScreen(regionId: 1, previewCompletion: true),
      ),
    ),
  );
}
