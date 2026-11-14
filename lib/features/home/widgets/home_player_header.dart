import 'package:flutter/material.dart';

import '../../avatar/models/player_avatar.dart';
import '../../avatar/widgets/player_avatar_widget.dart';
import 'home_palette.dart';

/// Keeps the saved explorer prominent without compressing accessible text.
class HomePlayerHeader extends StatelessWidget {
  const HomePlayerHeader({
    super.key,
    required this.avatar,
    required this.username,
    required this.greeting,
    required this.coins,
    required this.coinsLabel,
    required this.settingsLabel,
    required this.onProfile,
    required this.onSettings,
  });

  final PlayerAvatar avatar;
  final String username, greeting, coinsLabel, settingsLabel;
  final int coins;
  final VoidCallback onProfile, onSettings;

  static const _navy = Color(0xFF233B5D);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final stackControls =
          constraints.maxWidth < 330 ||
          (constraints.maxWidth < 480 &&
              MediaQuery.textScalerOf(context).scale(17) > 23);
      final profile = _profile();
      if (stackControls) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profile,
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: _controls(vertical: false),
            ),
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Align(alignment: Alignment.centerLeft, child: profile),
          ),
          const SizedBox(width: 10),
          _controls(vertical: constraints.maxWidth < 520),
        ],
      );
    },
  );

  Widget _profile() => Container(
    key: const Key('home_profile_pill'),
    constraints: const BoxConstraints(minHeight: 80),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(1000),
      boxShadow: const [
        BoxShadow(
          color: Color(0x237F4E70),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: HomePalette.cream,
      shape: const StadiumBorder(
        side: BorderSide(color: Color(0xFFF0B8D0), width: 1.5),
      ),
      child: InkWell(
        key: const Key('button_player_profile'),
        onTap: onProfile,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                key: const Key('home_profile_avatar_frame'),
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFF0B8D0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x207F4E70),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: PlayerAvatarWidget(
                  key: const Key('home_profile_avatar'),
                  avatar: avatar,
                  size: 58,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      textWidthBasis: TextWidthBasis.longestLine,
                      key: const Key('home_profile_greeting'),
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        color: _navy,
                        fontSize: 17,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                        fontVariations: [FontVariation('wght', 600)],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      username,
                      textWidthBasis: TextWidthBasis.longestLine,
                      key: const Key('home_profile_username'),
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        color: _navy,
                        fontSize: 23,
                        height: 1.15,
                        fontWeight: FontWeight.w700,
                        fontVariations: [FontVariation('wght', 700)],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _controls({required bool vertical}) {
    final children = <Widget>[
      Tooltip(
        message: coinsLabel,
        child: Semantics(
          label: coinsLabel,
          excludeSemantics: true,
          child: Container(
            width: 86,
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: HomePalette.pink,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.stars_rounded,
                  size: 20,
                  color: Color(0xFFA26911),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$coins',
                      style: const TextStyle(
                        color: HomePalette.rose,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      SizedBox(width: vertical ? 0 : 8, height: vertical ? 8 : 0),
      IconButton(
        key: const Key('menu_settings_button'),
        tooltip: settingsLabel,
        onPressed: onSettings,
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          backgroundColor: HomePalette.blue,
          foregroundColor: _navy,
          side: const BorderSide(color: Colors.white, width: 2),
        ),
        icon: const Icon(Icons.tune_rounded, size: 23),
      ),
    ];
    return vertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: children,
          )
        : Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}
