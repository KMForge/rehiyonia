import 'package:flutter/material.dart';

import '../../home/screens/home_screen.dart';
import 'create_explorer_dialog.dart';

/// First paint Home and finish its route transition before requesting a name.
class FirstLaunchHome extends StatefulWidget {
  const FirstLaunchHome({super.key});
  @override
  State<FirstLaunchHome> createState() => _FirstLaunchHomeState();
}

class _FirstLaunchHomeState extends State<FirstLaunchHome> {
  Animation<double>? _transition;
  bool _scheduled = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scheduled || _transition != null) return;
    _transition = ModalRoute.of(context)?.animation;
    if (_transition == null || _transition!.isCompleted) {
      _showAfterFrame();
    } else {
      _transition!.addStatusListener(_onStatus);
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _showAfterFrame();
  }

  void _showAfterFrame() {
    if (_scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const CreateExplorerDialog(),
        );
      }
    });
  }

  @override
  void dispose() {
    _transition?.removeStatusListener(_onStatus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const HomeScreen();
}
