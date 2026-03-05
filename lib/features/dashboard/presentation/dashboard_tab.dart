import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/ui/theme.dart';
import '../../../ui/widgets/kpi_card.dart';
import '../../../ui/widgets/state_placeholders.dart';
import '../../../ui/widgets/status_chip.dart';
import '../../../ui/widgets/skeleton_loaders.dart';
import '../data/dashboard_repository.dart';
import '../domain/dashboard_summary.dart';

class DashboardTab extends ConsumerStatefulWidget {
  const DashboardTab({super.key});

  @override
  ConsumerState<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends ConsumerState<DashboardTab> {
  Timer? _tick;
  DateTime _lastUpdated = DateTime.now();
  int _secondsToAutoRefresh = 45;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_secondsToAutoRefresh <= 1) {
        _refresh(isAuto: true);
      } else {
        setState(() => _secondsToAutoRefresh -= 1);
      }
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _refresh({bool isAuto = false}) async {
    if (_isRefreshing) return;

    var refreshedAt = DateTime.now();
    setState(() => _isRefreshing = true);
    ref.invalidate(dashboardSummaryProvider);

    try {
      await ref.read(dashboardSummaryProvider.future);
      refreshedAt = DateTime.now();
      if (!mounted) return;
      if (!isAuto) {
        HapticFeedback.lightImpact();
      }
    } finally {
      if (mounted) {
        setState(() {
          _lastUpdated = refreshedAt;
          _secondsToAutoRefresh = 45;
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _pickDate() async {
    final repository = ref.read(dashboardRepositoryProvider);
    final current = ref.read(dashboardSelectedDateProvider);

    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime.now(),
    );
    if (picked == null || !mounted) return;

    final normalized = repository.normalizeDate(picked);
    if (normalized == current) return;

    ref.read(dashboardSelectedDateProvider.notifier).state = normalized;
    setState(() {
      _secondsToAutoRefresh = 45;
    });
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final selectedDate = ref.watch(dashboardSelectedDateProvider);

    return RefreshIndicator(
      onRefresh: _refresh,
      child: summaryAsync.when(
        data: (summary) => _DashboardContent(
          summary: summary,
          selectedDate: selectedDate,
          lastUpdated: _lastUpdated,
          secondsToAutoRefresh: _secondsToAutoRefresh,
          isRefreshing: _isRefreshing,
          onRefresh: _refresh,
          onPickDate: _pickDate,
        ),
        loading: () => const DashboardSkeleton(),
        error: (error, _) => ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: <Widget>[
            _LiveHeaderStrip(
              selectedDate: selectedDate,
              lastUpdated: _lastUpdated,
              secondsToAutoRefresh: _secondsToAutoRefresh,
              isRefreshing: _isRefreshing,
              onRefresh: _refresh,
              onPickDate: _pickDate,
            ),
            const SizedBox(height: 16),
            if (error is DashboardDataUnavailableException)
              EmptyStateCard(
                title: 'No dashboard data yet',
                message:
                    'API connected, but no metrics were returned for the selected date. '
                    'Try again after production updates are posted.',
                icon: Icons.insights_outlined,
                actionLabel: 'Retry',
                onAction: _refresh,
              )
            else
              ErrorStateCard(
                message: 'Failed to load dashboard. ${error.toString()}',
                onRetry: _refresh,
              ),
          ],
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.summary,
    required this.selectedDate,
    required this.lastUpdated,
    required this.secondsToAutoRefresh,
    required this.isRefreshing,
    required this.onRefresh,
    required this.onPickDate,
  });

  final DashboardSummary summary;
  final DateTime selectedDate;
  final DateTime lastUpdated;
  final int secondsToAutoRefresh;
  final bool isRefreshing;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onPickDate;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final produced = summary.producedToday;
    final defectRate = summary.defectRate;
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width < 360 ? 1 : 2;
    final cardAspectRatio = width < 390 ? 1.12 : 1.28;

    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        _LiveHeaderStrip(
          selectedDate: selectedDate,
          lastUpdated: lastUpdated,
          secondsToAutoRefresh: secondsToAutoRefresh,
          isRefreshing: isRefreshing,
          onRefresh: onRefresh,
          onPickDate: onPickDate,
        ),
        SizedBox(height: spacing.md),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: crossAxisCount,
          childAspectRatio: cardAspectRatio,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: <Widget>[
            KpiCard(
              title: 'Planned Today',
              value: summary.plannedToday.toDouble(),
              badgeLabel: 'Target',
              badgeTone: StatusTone.info,
              icon: Icons.flag_outlined,
            ),
            KpiCard(
              title: 'Produced Today',
              value: produced.toDouble(),
              badgeLabel:
                  produced >= summary.plannedToday ? 'On Track' : 'Behind',
              badgeTone: produced >= summary.plannedToday
                  ? StatusTone.positive
                  : StatusTone.warning,
              icon: Icons.precision_manufacturing_outlined,
            ),
            KpiCard(
              title: 'Efficiency',
              value: summary.efficiency,
              badgeLabel: _efficiencyLabel(summary.efficiency),
              badgeTone: _efficiencyTone(summary.efficiency),
              suffix: '%',
              decimals: 1,
              icon: Icons.speed_rounded,
            ),
            KpiCard(
              title: 'Defect Rate',
              value: defectRate,
              badgeLabel: _defectLabel(defectRate),
              badgeTone: _defectTone(defectRate),
              suffix: '%',
              decimals: 2,
              icon: Icons.warning_amber_rounded,
            ),
          ],
        ),
        SizedBox(height: spacing.lg),
        _HourlyOutputChart(
          hourlyOutput: summary.hourlyOutput,
        ),
        SizedBox(height: spacing.md),
        _PlanActualBars(
          plannedToday: summary.plannedToday,
          producedToday: summary.producedToday,
          defects: summary.defects,
        ),
      ],
    );
  }

  StatusTone _efficiencyTone(double efficiency) {
    if (efficiency >= 95) return StatusTone.positive;
    if (efficiency >= 85) return StatusTone.info;
    return StatusTone.warning;
  }

  String _efficiencyLabel(double efficiency) {
    if (efficiency >= 95) return 'Excellent';
    if (efficiency >= 85) return 'Stable';
    return 'Watch';
  }

  StatusTone _defectTone(double defectRate) {
    if (defectRate <= 1) return StatusTone.positive;
    if (defectRate <= 3) return StatusTone.warning;
    return StatusTone.critical;
  }

  String _defectLabel(double defectRate) {
    if (defectRate <= 1) return 'Low';
    if (defectRate <= 3) return 'Moderate';
    return 'High';
  }
}

class _LiveHeaderStrip extends StatelessWidget {
  const _LiveHeaderStrip({
    required this.selectedDate,
    required this.lastUpdated,
    required this.secondsToAutoRefresh,
    required this.isRefreshing,
    required this.onRefresh,
    required this.onPickDate,
  });

  final DateTime selectedDate;
  final DateTime lastUpdated;
  final int secondsToAutoRefresh;
  final bool isRefreshing;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onPickDate;

  @override
  Widget build(BuildContext context) {
    final timestamp = DateFormat('HH:mm:ss').format(lastUpdated);
    final dateLabel = DateFormat('dd MMM yyyy').format(selectedDate);

    return Card(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: context.gradients.liveStrip,
        ),
        child: Row(
          children: <Widget>[
            const _PulsingDot(),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Live floor telemetry',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(
                    'Date $dateLabel  •  Updated $timestamp  •  Auto refresh in ${secondsToAutoRefresh}s',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: onPickDate,
              icon: const Icon(Icons.calendar_month_rounded),
              tooltip: 'Change date',
            ),
            if (isRefreshing)
              const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh now',
              ),
          ],
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        final size = 8 + (t * 4);
        final alpha = 0.55 + (t * 0.45);
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFF58F3D4).withValues(alpha: alpha),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

class _HourlyOutputChart extends StatelessWidget {
  const _HourlyOutputChart({required this.hourlyOutput});

  final List<int> hourlyOutput;

  @override
  Widget build(BuildContext context) {
    final values = _hourlyBarsFromApi();
    final maxY = values.fold<double>(0, (p, c) => math.max(p, c)) * 1.2;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Hourly Output', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: maxY <= 0 ? 10 : maxY,
                  minY: 0,
                  barTouchData: const BarTouchData(enabled: false),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: math.max(1, maxY / 4),
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.white.withValues(alpha: 0.08),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    leftTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= values.length) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            '${8 + index}h',
                            style: Theme.of(context).textTheme.labelMedium,
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List<BarChartGroupData>.generate(values.length, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: <BarChartRodData>[
                        BarChartRodData(
                          toY: values[index],
                          width: 12,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                          gradient: const LinearGradient(
                            colors: <Color>[Color(0xFF33D5E5), Color(0xFF21A7BE)],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxY,
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<double> _hourlyBarsFromApi() {
    final source = hourlyOutput.isEmpty
        ? List<int>.filled(12, 0)
        : (hourlyOutput.length >= 12
              ? hourlyOutput.take(12).toList(growable: false)
              : <int>[...hourlyOutput, ...List<int>.filled(12 - hourlyOutput.length, 0)]);

    return source
        .map((value) => value < 0 ? 0.0 : value.toDouble())
        .toList(growable: false);
  }
}

class _PlanActualBars extends StatelessWidget {
  const _PlanActualBars({
    required this.plannedToday,
    required this.producedToday,
    required this.defects,
  });

  final int plannedToday;
  final int producedToday;
  final int defects;

  @override
  Widget build(BuildContext context) {
    final ceiling = math.max(plannedToday, producedToday).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Plan vs Actual',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _HorizontalMetricBar(
              label: 'Planned',
              value: plannedToday.toDouble(),
              maxValue: ceiling == 0 ? 1 : ceiling,
              color: const Color(0xFF6AB6FF),
            ),
            const SizedBox(height: 8),
            _HorizontalMetricBar(
              label: 'Actual',
              value: producedToday.toDouble(),
              maxValue: ceiling == 0 ? 1 : ceiling,
              color: const Color(0xFF4CE2C0),
            ),
            const SizedBox(height: 8),
            _HorizontalMetricBar(
              label: 'Defects',
              value: defects.toDouble(),
              maxValue: math.max(1, defects).toDouble(),
              color: const Color(0xFFF28A8A),
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalMetricBar extends StatelessWidget {
  const _HorizontalMetricBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  final String label;
  final double value;
  final double maxValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ratio = (value / maxValue).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            Text(value.toStringAsFixed(0), style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 11,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
