import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehiyonia/core/constants/app_constants.dart';
import 'package:rehiyonia/features/profile/providers/profile_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProfileNotifier Unit Tests', () {
    test('initializes with default player name and starting coins', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final profile = container.read(profileProvider);
      expect(profile.name, equals(AppConstants.defaultPlayerName));
      expect(profile.coins, equals(AppConstants.startingCoins));
      expect(profile.totalStars, equals(0));
    });

    test('updates player name properly', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(profileProvider.notifier);
      await notifier.setPlayerName('Lapu-Lapu');

      final profile = container.read(profileProvider);
      expect(profile.name, equals('Lapu-Lapu'));
    });

    test('ignores empty or whitespace player name', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(profileProvider.notifier);
      await notifier.setPlayerName('   ');

      final profile = container.read(profileProvider);
      expect(profile.name, equals(AppConstants.defaultPlayerName));
    });

    test('adds and sets coins properly', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(profileProvider.notifier);
      await notifier.addCoins(20);
      expect(container.read(profileProvider).coins, equals(70));

      await notifier.addCoins(-30);
      expect(container.read(profileProvider).coins, equals(40));

      await notifier.setCoins(100);
      expect(container.read(profileProvider).coins, equals(100));

      // Cannot be negative
      await notifier.addCoins(-150);
      expect(container.read(profileProvider).coins, equals(0));
    });

    test('adds stars correctly', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(profileProvider.notifier);
      await notifier.addStars(3);
      expect(container.read(profileProvider).totalStars, equals(3));

      await notifier.addStars(2);
      expect(container.read(profileProvider).totalStars, equals(5));
    });
  });
}
