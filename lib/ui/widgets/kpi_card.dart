import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/ui/theme.dart';
import 'status_chip.dart';

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.badgeLabel,
    this.badgeTone = StatusTone.info,
    this.suffix,
    this.icon,
    this.decimals = 0,
  });

  final String title;
  final double value;
  final String badgeLabel;
  final StatusTone badgeTone;
  final String? suffix;
  final IconData? icon;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: context.gradients.accentSurface,
        ),
        padding: EdgeInsets.all(spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, size: 18, color: Theme.of(context).colorScheme.secondary),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                StatusChip(label: badgeLabel, tone: badgeTone, compact: true),
              ],
            ),
            SizedBox(height: spacing.xs),
            Expanded(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  tween: Tween<double>(begin: 0, end: value),
                  builder: (context, animatedValue, _) {
                    final formatted = decimals == 0
                        ? NumberFormat.decimalPattern().format(animatedValue.round())
                        : animatedValue.toStringAsFixed(decimals);
                    final text = suffix == null ? formatted : '$formatted$suffix';
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        text,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
