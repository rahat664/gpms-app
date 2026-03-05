import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AppSkeleton extends StatelessWidget {
  const AppSkeleton({
    super.key,
    required this.height,
    this.width = double.infinity,
    this.radius = 12,
  });

  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Shimmer.fromColors(
      baseColor: baseColor.withValues(alpha: 0.45),
      highlightColor: Colors.white.withValues(alpha: 0.08),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const <Widget>[
        AppSkeleton(height: 54, radius: 14),
        SizedBox(height: 12),
        AppSkeleton(height: 112, radius: 16),
        SizedBox(height: 10),
        AppSkeleton(height: 112, radius: 16),
        SizedBox(height: 10),
        AppSkeleton(height: 112, radius: 16),
        SizedBox(height: 10),
        AppSkeleton(height: 112, radius: 16),
        SizedBox(height: 14),
        AppSkeleton(height: 220, radius: 16),
        SizedBox(height: 12),
        AppSkeleton(height: 185, radius: 16),
      ],
    );
  }
}

class OrdersSkeleton extends StatelessWidget {
  const OrdersSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 7,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => const AppSkeleton(height: 104, radius: 16),
    );
  }
}
