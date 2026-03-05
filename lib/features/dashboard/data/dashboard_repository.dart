import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/json/json_utils.dart';
import '../../../network/dio_provider.dart';
import '../domain/dashboard_summary.dart';

class DashboardDataUnavailableException implements Exception {
  DashboardDataUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
}

class DashboardRepository {
  DashboardRepository(this._dio);

  final Dio _dio;

  Future<DashboardSummary> fetchToday() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return fetchForDate(today);
  }

  Future<DashboardSummary> fetchForDate(String date) async {
    // Mirror web dashboard data contract:
    // /reports/plan-vs-actual + /sewing/line-status + /qc/summary.
    return _fetchFromReportEndpoints(date);
  }

  DateTime normalizeDate(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  String formatDateIso(DateTime value) {
    return DateFormat('yyyy-MM-dd').format(normalizeDate(value));
  }

  DateTime todayDate() => normalizeDate(DateTime.now());

  Future<DashboardSummary> fetchSelectedDate(DateTime date) async {
    final iso = formatDateIso(date);
    return _fetchFromReportEndpoints(iso);
  }

  Future<DashboardSummary> _fetchFromReportEndpoints(String date) async {
    final responses = await Future.wait<Response<dynamic>?>(<Future<Response<dynamic>?>>[
      _safeGet('/api/reports/plan-vs-actual', date: date),
      _safeGet('/api/sewing/line-status', date: date),
      _safeGet('/api/qc/summary', date: date),
    ]);

    final planVsActualPayload = _payloadFromResponse(responses[0]);
    final sewingStatusPayload = _payloadFromResponse(responses[1]);
    final qcSummaryPayload = _payloadFromResponse(responses[2]);

    final planRows = _asRows(planVsActualPayload);
    final lineRows = _asRows(sewingStatusPayload);
    final qcMap = jsonMap(qcSummaryPayload);

    final plannedFromPlanRows = _sumInt(planRows, const <String>['targetQty']);
    final producedFromPlanRows = _sumInt(planRows, const <String>['actualQty']);
    final producedFromLineStatus = _sumInt(
      lineRows,
      const <String>['totalOutputToday', 'actualQty', 'actual', 'produced'],
    );

    final plannedFallback = _extractInt(
      jsonMap(planVsActualPayload),
      const <String>['plannedToday', 'planned', 'target', 'targetQty', 'planQty'],
    );
    final producedFallbackPlan = _extractInt(
      jsonMap(planVsActualPayload),
      const <String>['producedToday', 'actual', 'produced', 'actualQty', 'output'],
    );
    final producedFallbackLine = _extractInt(
      jsonMap(sewingStatusPayload),
      const <String>['producedToday', 'actual', 'produced', 'actualQty', 'totalOutputToday'],
    );

    final plannedToday = plannedFromPlanRows > 0
        ? plannedFromPlanRows
        : (plannedFallback > 0 ? plannedFallback : 0);

    final producedCandidates = <int>[
      producedFromPlanRows,
      producedFromLineStatus,
      producedFallbackPlan,
      producedFallbackLine,
    ];
    producedCandidates.sort();
    final producedToday = producedCandidates.last;

    final hourlyOutput = _buildHourlyOutput(lineRows);

    final topDefects = jsonList(qcMap['topDefects']).map(jsonMap).toList(growable: false);
    final defectsFromTopList = _sumInt(topDefects, const <String>['count']);
    final defectsFallback = _extractInt(
      qcMap,
      const <String>['defects', 'defectCount', 'totalDefects', 'rejectQty', 'rejected'],
    );
    final defects = defectsFromTopList > 0 ? defectsFromTopList : defectsFallback;

    var defectRate = _extractDouble(
      qcMap,
      const <String>['dhuEstimate', 'defectRate', 'dhuRate'],
      fallback: double.nan,
    );
    if (defectRate.isNaN) {
      defectRate = producedToday > 0 ? (defects / producedToday) * 100 : 0.0;
    }

    final efficiency = plannedToday > 0
        ? (producedToday / plannedToday) * 100
        : _extractDouble(
            jsonMap(planVsActualPayload),
            const <String>['efficiency', 'efficiencyRate', 'eff'],
            fallback: _extractDouble(
              jsonMap(sewingStatusPayload),
              const <String>['efficiency', 'efficiencyRate', 'eff'],
              fallback: 0.0,
            ),
          );

    final hasAnySignal = plannedToday > 0 ||
        producedToday > 0 ||
        defects > 0 ||
        defectRate > 0 ||
        hourlyOutput.any((value) => value > 0);
    if (!hasAnySignal) {
      throw DashboardDataUnavailableException(
        'No dashboard metrics returned from API for $date.',
      );
    }

    return DashboardSummary(
      plannedToday: plannedToday,
      producedToday: producedToday,
      efficiency: efficiency,
      defects: defects,
      defectRate: defectRate,
      hourlyOutput: hourlyOutput,
    );
  }

  Future<Response<dynamic>?> _safeGet(
    String path, {
    required String date,
  }) async {
    try {
      return await _dio.get<dynamic>(
        path,
        queryParameters: <String, dynamic>{'date': date},
      );
    } on DioException catch (error) {
      if (_is404(error)) return null;
      rethrow;
    }
  }

  bool _is404(DioException error) => error.response?.statusCode == 404;

  dynamic _payloadFromResponse(Response<dynamic>? response) {
    if (response == null) return const <String, dynamic>{};
    final data = response.data;
    if (data is List) return data;
    final map = jsonMap(data);
    if (map['data'] is List || map['data'] is Map) return map['data'];
    if (map['items'] is List || map['items'] is Map) return map['items'];
    if (map['results'] is List || map['results'] is Map) return map['results'];
    if (map['rows'] is List || map['rows'] is Map) return map['rows'];
    return map;
  }

  List<Map<String, dynamic>> _asRows(dynamic payload) {
    if (payload is List) {
      return jsonList(payload).map(jsonMap).toList(growable: false);
    }

    final map = jsonMap(payload);
    final rows = map['rows'] ?? map['items'] ?? map['results'] ?? map['data'];
    if (rows is List) {
      return jsonList(rows).map(jsonMap).toList(growable: false);
    }

    // Fallback for inconsistent APIs:
    // find the first list-of-maps field.
    for (final value in map.values) {
      if (value is List && value.isNotEmpty) {
        final parsed = jsonList(value).map(jsonMap).toList(growable: false);
        if (parsed.isNotEmpty) {
          return parsed;
        }
      }
    }

    return const <Map<String, dynamic>>[];
  }

  int _sumInt(List<Map<String, dynamic>> rows, List<String> keys) {
    var total = 0;
    for (final row in rows) {
      total += _extractInt(row, keys);
    }
    return total;
  }

  List<int> _buildHourlyOutput(List<Map<String, dynamic>> lineRows) {
    final series = List<int>.filled(12, 0);
    for (final line in lineRows) {
      final breakdown = jsonMap(line['hourlyBreakdown']);
      for (var i = 0; i < 12; i++) {
        final hour = 8 + i;
        final value = firstInt(
          breakdown,
          <String>[hour.toString(), '$hour:00', '$hour.0'],
        );
        series[i] += value;
      }
    }
    return series;
  }

  int _extractInt(
    Map<String, dynamic> map,
    List<String> keys, {
    int fallback = 0,
    int maxDepth = 2,
  }) {
    final direct = firstInt(map, keys, fallback: fallback);
    if (direct != fallback) return direct;
    if (maxDepth <= 0) return fallback;

    for (final value in map.values) {
      final nested = jsonMap(value);
      if (nested.isEmpty) continue;
      final candidate = _extractInt(
        nested,
        keys,
        fallback: fallback,
        maxDepth: maxDepth - 1,
      );
      if (candidate != fallback) return candidate;
    }

    return fallback;
  }

  double _extractDouble(
    Map<String, dynamic> map,
    List<String> keys, {
    double fallback = 0,
    int maxDepth = 2,
  }) {
    final direct = firstDouble(map, keys, fallback: fallback);
    if (direct != fallback) return direct;
    if (maxDepth <= 0) return fallback;

    for (final value in map.values) {
      final nested = jsonMap(value);
      if (nested.isEmpty) continue;
      final candidate = _extractDouble(
        nested,
        keys,
        fallback: fallback,
        maxDepth: maxDepth - 1,
      );
      if (candidate != fallback) return candidate;
    }

    return fallback;
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepository(ref.read(dioProvider)),
);

final dashboardSelectedDateProvider = StateProvider<DateTime>((ref) {
  return ref.read(dashboardRepositoryProvider).todayDate();
});

final dashboardSelectedDateIsoProvider = Provider<String>((ref) {
  final date = ref.watch(dashboardSelectedDateProvider);
  return ref.read(dashboardRepositoryProvider).formatDateIso(date);
});

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) {
  final date = ref.watch(dashboardSelectedDateIsoProvider);
  return ref.read(dashboardRepositoryProvider).fetchForDate(date);
});
