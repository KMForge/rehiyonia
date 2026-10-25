import 'package:flutter/material.dart';

import '../../app/explorer_theme.dart';

class ExplorerCard extends StatelessWidget {
  const ExplorerCard({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(20),
  });
  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: ExplorerTheme.line),
    ),
    child: child,
  );
}
