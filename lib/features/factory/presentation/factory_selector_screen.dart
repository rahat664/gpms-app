import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/session/session_controller.dart';

class FactorySelectorScreen extends ConsumerWidget {
  const FactorySelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Factory')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          if (session.factories.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('No factories available for this account.'),
                    const SizedBox(height: 12),
                    FilledButton.tonal(
                      onPressed: () => context.go('/login'),
                      child: const Text('Back to login'),
                    ),
                  ],
                ),
              ),
            )
          else
            ...session.factories.map(
              (factory) => Card(
                child: ListTile(
                  title: Text(factory.name),
                  subtitle: Text(factory.id),
                  leading: Icon(
                    session.activeFactoryId == factory.id
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  onTap: () async {
                    await ref
                        .read(sessionControllerProvider.notifier)
                        .selectFactory(factory.id);
                    if (context.mounted) {
                      context.go('/home');
                    }
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
