import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/providers/profile_provider.dart';
import '../models/player_avatar.dart';
import '../widgets/player_avatar_widget.dart';

class AvatarStudioScreen extends ConsumerStatefulWidget {
  const AvatarStudioScreen({super.key});

  @override
  ConsumerState<AvatarStudioScreen> createState() => _AvatarStudioScreenState();
}

class _AvatarStudioScreenState extends ConsumerState<AvatarStudioScreen> {
  late PlayerAvatar _currentAvatar;
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentAvatar = ref.read(profileProvider).avatar;
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(localizationsProvider);

    final categories = [
      loc.skinTone,
      loc.hairStyle,
      loc.hairColor,
      loc.outfitColor,
      loc.accessory,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(loc.avatarStudioTitle)),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Live Preview Card
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepBlue.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(color: AppColors.babyBlue, width: 2),
                ),
                child: Column(
                  children: [
                    PlayerAvatarWidget(avatar: _currentAvatar, size: 130),
                    const SizedBox(height: 12),
                    Text(
                      ref.watch(profileProvider).name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textNavy,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Category Chips Tab Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(categories.length, (idx) {
                  final isSelected = _selectedCategoryIndex == idx;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(categories[idx]),
                      selected: isSelected,
                      selectedColor: AppColors.deepBlue,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textNavy,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.deepBlue
                              : AppColors.babyBlue,
                        ),
                      ),
                      onSelected: (_) {
                        setState(() => _selectedCategoryIndex = idx);
                      },
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 16),

            // Options Palette
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildCategoryOptions(loc),
              ),
            ),

            // Save Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: FilledButton.icon(
                key: const Key('button_save_avatar'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  backgroundColor: AppColors.deepBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: const Icon(Icons.check_rounded, size: 24),
                label: Text(
                  loc.saveAvatar,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  ref.read(profileProvider.notifier).setAvatar(_currentAvatar);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.avatarSaved),
                      duration: const Duration(seconds: 2),
                      backgroundColor: AppColors.deepBlue,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryOptions(AppLocalizations loc) {
    switch (_selectedCategoryIndex) {
      case 0: // Skin Tone
        return _buildColorGrid(
          colors: PlayerAvatar.skinColors,
          selectedIndex: _currentAvatar.skinIndex,
          onSelect: (i) => setState(
            () => _currentAvatar = _currentAvatar.copyWith(skinIndex: i),
          ),
        );
      case 1: // Hair Style
        final styles = ['Short', 'Curly', 'Ponytail', 'Spiky'];
        return _buildChoiceGrid(
          labels: styles,
          selectedIndex: _currentAvatar.hairStyleIndex,
          onSelect: (i) => setState(
            () => _currentAvatar = _currentAvatar.copyWith(hairStyleIndex: i),
          ),
        );
      case 2: // Hair Color
        return _buildColorGrid(
          colors: PlayerAvatar.hairColors,
          selectedIndex: _currentAvatar.hairColorIndex,
          onSelect: (i) => setState(
            () => _currentAvatar = _currentAvatar.copyWith(hairColorIndex: i),
          ),
        );
      case 3: // Outfit Color
        return _buildColorGrid(
          colors: PlayerAvatar.outfitColors,
          selectedIndex: _currentAvatar.outfitColorIndex,
          onSelect: (i) => setState(
            () => _currentAvatar = _currentAvatar.copyWith(outfitColorIndex: i),
          ),
        );
      case 4: // Accessory
        final accessories = [
          'None',
          'Explorer Cap',
          'Flower Ribbon',
          'Star Glasses',
        ];
        return _buildChoiceGrid(
          labels: accessories,
          selectedIndex: _currentAvatar.accessoryIndex,
          onSelect: (i) => setState(
            () => _currentAvatar = _currentAvatar.copyWith(accessoryIndex: i),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildColorGrid({
    required List<Color> colors,
    required int selectedIndex,
    required ValueChanged<int> onSelect,
  }) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: colors.length,
      itemBuilder: (context, idx) {
        final isSelected = selectedIndex == idx;
        return GestureDetector(
          onTap: () => onSelect(idx),
          child: Container(
            decoration: BoxDecoration(
              color: colors[idx],
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.deepBlue : Colors.white,
                width: isSelected ? 4 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors[idx].withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 28)
                : null,
          ),
        );
      },
    );
  }

  Widget _buildChoiceGrid({
    required List<String> labels,
    required int selectedIndex,
    required ValueChanged<int> onSelect,
  }) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.2,
      ),
      itemCount: labels.length,
      itemBuilder: (context, idx) {
        final isSelected = selectedIndex == idx;
        return GestureDetector(
          onTap: () => onSelect(idx),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.babyBlue : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? AppColors.deepBlue : AppColors.softLavender,
                width: isSelected ? 2.5 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.deepBlue.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              labels[idx],
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.deepBlue : AppColors.textNavy,
              ),
            ),
          ),
        );
      },
    );
  }
}
