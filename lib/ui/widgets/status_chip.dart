import 'package:flutter/material.dart';

enum StatusTone { neutral, positive, warning, critical, info }

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.tone = StatusTone.neutral,
    this.compact = false,
    this.icon,
    this.maxWidth,
  });

  final String label;
  final StatusTone tone;
  final bool compact;
  final IconData? icon;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final palette = _paletteFor(context, tone);

    final chip = Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: compact ? 12 : 14, color: palette.foreground),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                color: palette.foreground,
                fontSize: compact ? 10.5 : 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (maxWidth == null) {
      return chip;
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth!),
      child: chip,
    );
  }

  _StatusPalette _paletteFor(BuildContext context, StatusTone value) {
    final scheme = Theme.of(context).colorScheme;
    return switch (value) {
      StatusTone.positive => _StatusPalette(
        foreground: const Color(0xFF69F0AE),
        background: const Color(0x1A69F0AE),
        border: const Color(0x3A69F0AE),
      ),
      StatusTone.warning => _StatusPalette(
        foreground: const Color(0xFFFFD166),
        background: const Color(0x1AFFD166),
        border: const Color(0x3AFFD166),
      ),
      StatusTone.critical => _StatusPalette(
        foreground: scheme.error,
        background: scheme.error.withValues(alpha: 0.16),
        border: scheme.error.withValues(alpha: 0.3),
      ),
      StatusTone.info => _StatusPalette(
        foreground: const Color(0xFF6DE8F3),
        background: const Color(0x1A6DE8F3),
        border: const Color(0x3A6DE8F3),
      ),
      StatusTone.neutral => _StatusPalette(
        foreground: scheme.onSurfaceVariant,
        background: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        border: scheme.outlineVariant.withValues(alpha: 0.4),
      ),
    };
  }
}

class _StatusPalette {
  const _StatusPalette({
    required this.foreground,
    required this.background,
    required this.border,
  });

  final Color foreground;
  final Color background;
  final Color border;
}
