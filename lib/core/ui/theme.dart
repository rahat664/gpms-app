import 'package:flutter/material.dart';

@immutable
class AppSpacing extends ThemeExtension<AppSpacing> {
  const AppSpacing({
    this.xs = 6,
    this.sm = 10,
    this.md = 14,
    this.lg = 18,
    this.xl = 24,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;

  @override
  AppSpacing copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
  }) {
    return AppSpacing(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
    );
  }

  @override
  AppSpacing lerp(ThemeExtension<AppSpacing>? other, double t) {
    if (other is! AppSpacing) return this;
    return AppSpacing(
      xs: lerpDouble(xs, other.xs, t),
      sm: lerpDouble(sm, other.sm, t),
      md: lerpDouble(md, other.md, t),
      lg: lerpDouble(lg, other.lg, t),
      xl: lerpDouble(xl, other.xl, t),
    );
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

@immutable
class AppGradients extends ThemeExtension<AppGradients> {
  const AppGradients({required this.accentSurface, required this.liveStrip});

  final Gradient accentSurface;
  final Gradient liveStrip;

  @override
  AppGradients copyWith({Gradient? accentSurface, Gradient? liveStrip}) {
    return AppGradients(
      accentSurface: accentSurface ?? this.accentSurface,
      liveStrip: liveStrip ?? this.liveStrip,
    );
  }

  @override
  AppGradients lerp(ThemeExtension<AppGradients>? other, double t) {
    if (other is! AppGradients) return this;
    return AppGradients(
      accentSurface: Gradient.lerp(accentSurface, other.accentSurface, t)!,
      liveStrip: Gradient.lerp(liveStrip, other.liveStrip, t)!,
    );
  }
}

class GpmsTheme {
  static const double radius = 16;

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF10B7C8),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF0D1419),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    visualDensity: VisualDensity.standard,
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 15, height: 1.35),
      bodyMedium: TextStyle(fontSize: 13.5, height: 1.35),
      labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      labelMedium: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xCC10222A),
      foregroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0.4,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF12212A),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(radius),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF27C9DA)),
        borderRadius: BorderRadius.circular(radius),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 70,
      backgroundColor: const Color(0xE613222A),
      indicatorColor: const Color(0x3327C9DA),
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: 0.1,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(size: selected ? 25 : 23);
      }),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      side: BorderSide.none,
      backgroundColor: const Color(0xFF18303A),
      selectedColor: const Color(0xFF1D4E59),
      labelStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
    ),
    dividerColor: Colors.white.withValues(alpha: 0.07),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF13343E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      contentTextStyle: const TextStyle(fontSize: 13),
      actionTextColor: const Color(0xFF6DE8F3),
    ),
    extensions: const <ThemeExtension<dynamic>>[
      AppSpacing(),
      AppGradients(
        accentSurface: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0x7F1AB5C7), Color(0x1A7CF4D0)],
        ),
        liveStrip: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[Color(0xFF134955), Color(0xFF0E2E38)],
        ),
      ),
    ],
  );
}

extension ThemeX on BuildContext {
  AppSpacing get spacing => Theme.of(this).extension<AppSpacing>()!;
  AppGradients get gradients => Theme.of(this).extension<AppGradients>()!;
}
