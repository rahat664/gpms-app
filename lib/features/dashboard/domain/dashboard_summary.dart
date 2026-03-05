import '../../../core/json/json_utils.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.plannedToday,
    required this.producedToday,
    required this.efficiency,
    required this.defects,
    required this.defectRate,
    required this.hourlyOutput,
  });

  final int plannedToday;
  final int producedToday;
  final double efficiency;
  final int defects;
  final double defectRate;
  final List<int> hourlyOutput;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final hourlySource = jsonList(json['hourlyOutput']);
    return DashboardSummary(
      plannedToday: firstInt(json, const ['plannedToday', 'planned', 'target']),
      producedToday: firstInt(json, const [
        'producedToday',
        'actual',
        'produced',
      ]),
      efficiency: firstDouble(json, const [
        'efficiency',
        'efficiencyRate',
        'eff',
      ]),
      defects: firstInt(json, const ['defects', 'defectCount']),
      defectRate: firstDouble(
        json,
        const ['defectRate', 'dhuEstimate', 'dhuRate'],
      ),
      hourlyOutput: hourlySource
          .map((item) {
            if (item is int) return item;
            if (item is num) return item.toInt();
            if (item is String) return int.tryParse(item) ?? 0;
            return 0;
          })
          .toList(growable: false),
    );
  }
}
