import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/session/session_controller.dart';
import '../../../core/session/session_state.dart';
import '../../../ui/widgets/app_loader.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    final result = await ref
        .read(sessionControllerProvider.notifier)
        .bootstrap();
    if (!mounted) return;

    switch (result.status) {
      case SessionStatus.ready:
        context.go('/home');
      case SessionStatus.needsFactory:
        context.go('/factory-selector');
      case SessionStatus.unauthenticated:
      case SessionStatus.initial:
      case SessionStatus.loading:
        context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: AppLoader(message: 'Checking session...'));
  }
}
