import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rehiyonia/core/constants/app_constants.dart';
import 'package:rehiyonia/core/constants/database_constants.dart';
import 'package:rehiyonia/core/database/app_database.dart';
import 'package:rehiyonia/core/services/audio_service.dart';
import 'package:rehiyonia/features/settings/models/app_language.dart';
import 'package:rehiyonia/features/settings/providers/settings_provider.dart';
import 'package:rehiyonia/features/settings/screens/settings_screen.dart';
import 'package:rehiyonia/shared/providers/app_initialization_provider.dart';

import '../../core/services/audio_service_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(sqfliteFfiInit);

  test(
    'music gain adjusts the current loop while preserving sound effects',
    () async {
      final music = MockAudioPlayer();
      final sfx = MockAudioPlayer();
      final audio = AudioService(musicPlayer: music, sfxPlayer: sfx);
      addTearDown(audio.dispose);
      audio.updatePreferences(
        musicEnabled: true,
        soundEffectsEnabled: true,
        volume: .8,
        musicVolume: .25,
      );
      await audio.setBackgroundMusic('loop.ogg', active: true);
      await audio.playSoundEffect('sparkle.wav');
      expect(music.volume, closeTo(.2, .0001));
      expect(sfx.volume, .8);
      audio.updatePreferences(
        musicEnabled: true,
        soundEffectsEnabled: true,
        musicVolume: .5,
      );
      expect(music.volume, closeTo(.4, .0001));
      expect(sfx.volume, .8);
      audio.updatePreferences(
        musicEnabled: true,
        soundEffectsEnabled: true,
        musicVolume: 0,
      );
      await audio.setBackgroundMusic('loop.ogg', active: true);
      expect(music.volume, 0);
      expect(sfx.volume, .8);
      expect(music.plays, 1);
      expect(music.pauses, 0);
    },
  );

  test(
    'music volume survives a SQLite reopen and leaves existing progress intact',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'rehiyonia_music_',
      );
      final path = '${directory.path}/settings.db';
      var database = AppDatabase(databaseFactory: databaseFactoryFfi);
      ProviderContainer? session;
      final audio = AudioService(
        musicPlayer: MockAudioPlayer(),
        sfxPlayer: MockAudioPlayer(),
      );
      try {
        await database.initialize(databasePath: path);
        await database.database.insert(DatabaseConstants.tableUserProgress, {
          DatabaseConstants.columnKey: AppConstants.keyCoins,
          DatabaseConstants.columnValue: '77',
        });
        session = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            audioServiceProvider.overrideWithValue(audio),
          ],
        );
        await session.read(settingsProvider.notifier).setMusicVolume(.35);
        session.dispose();
        session = null;
        await database.close();
        database = AppDatabase(databaseFactory: databaseFactoryFfi);
        await database.initialize(databasePath: path);
        session = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            audioServiceProvider.overrideWithValue(audio),
          ],
        );
        await session.read(settingsProvider.notifier).loadSavedPreferences();
        expect(session.read(settingsProvider).musicVolume, .35);
        expect(audio.musicVolume, .35);
        final rows = await database.database.query(
          DatabaseConstants.tableUserProgress,
        );
        expect(
          rows.singleWhere(
            (r) => r[DatabaseConstants.columnKey] == AppConstants.keyCoins,
          )[DatabaseConstants.columnValue],
          '77',
        );
        expect(
          rows.where(
            (r) =>
                r[DatabaseConstants.columnKey] == AppConstants.keyMusicVolume,
          ),
          hasLength(1),
        );
      } finally {
        session?.dispose();
        await database.close();
        await audio.dispose();
        for (final suffix in ['', '-wal', '-shm', '-journal']) {
          final file = File('$path$suffix');
          if (await file.exists()) await file.delete();
        }
        await directory.delete();
      }
    },
  );

  testWidgets(
    'small-phone slider adjusts music immediately and supports Tagalog',
    (tester) async {
      tester.view.physicalSize = const Size(320, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final music = MockAudioPlayer();
      final sfx = MockAudioPlayer();
      final audio = AudioService(musicPlayer: music, sfxPlayer: sfx);
      final session = ProviderContainer(
        overrides: [audioServiceProvider.overrideWithValue(audio)],
      );
      addTearDown(session.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: session,
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.5)),
              child: child!,
            ),
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('100%'), findsOneWidget);
      final slider = find.byKey(const Key('music_volume_slider'));
      await tester.drag(slider, const Offset(-1000, 0));
      await tester.pumpAndSettle();
      expect(session.read(settingsProvider).musicVolume, 0);
      expect(find.text('0%'), findsOneWidget);
      expect(music.volume, 0);
      expect(sfx.volume, 1);
      await tester.drag(slider, const Offset(1000, 0));
      await tester.pumpAndSettle();
      expect(session.read(settingsProvider).musicVolume, 1);
      expect(find.text('100%'), findsOneWidget);
      session.read(settingsProvider.notifier).setLanguage(AppLanguage.tagalog);
      await tester.pumpAndSettle();
      expect(find.text('Lakas ng musika'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
