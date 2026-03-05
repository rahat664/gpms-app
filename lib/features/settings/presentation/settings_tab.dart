import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/session/session_controller.dart';

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final activeFactoryName = session.factories
        .where((factory) => factory.id == session.activeFactoryId)
        .map((factory) => factory.name)
        .toList(growable: false);
    final factoryLabel = activeFactoryName.isEmpty
        ? 'Not selected'
        : activeFactoryName.first;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Signed in as', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Text(session.userName ?? 'Unknown user'),
                const SizedBox(height: 12),
                Text('Factory: $factoryLabel'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: () => context.go('/factory-selector'),
          child: const Text('Switch Factory'),
        ),
        const SizedBox(height: 12),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: () async {
            await ref.read(sessionControllerProvider.notifier).logout();
            if (context.mounted) {
              context.go('/login');
            }
          },
          child: const Text('Logout'),
        ),
      ],
    );
  }
}
