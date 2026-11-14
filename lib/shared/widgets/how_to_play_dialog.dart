import 'package:flutter/material.dart';

class HowToPlayDialog extends StatelessWidget {
  const HowToPlayDialog({
    super.key,
    required this.title,
    required this.instructions,
    required this.closeLabel,
  });

  final String title;
  final String instructions;
  final String closeLabel;

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    contentPadding: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28),
      side: const BorderSide(color: Color(0xFFF0BDD5)),
    ),
    content: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -.3),
          radius: 1.1,
          colors: [Color(0xFFFFF8ED), Color(0xFFDDF3FF), Color(0xFFFFDDEB)],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            Text(instructions, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(closeLabel),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
