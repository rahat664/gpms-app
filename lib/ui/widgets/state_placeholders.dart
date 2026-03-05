import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_rounded,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 38, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: 14),
              FilledButton.tonal(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onAction!();
                },
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorStateCard extends StatelessWidget {
  const ErrorStateCard({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyStateCard(
      title: 'Something went wrong',
      message: message,
      icon: Icons.error_outline_rounded,
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }
}
