import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/json/json_utils.dart';
import '../../../network/dio_provider.dart';

class OperationsRepository {
  OperationsRepository(this._dio);

  final Dio _dio;

  Future<List<Map<String, dynamic>>> fetchBuyers() async {
    final response = await _get('buyers');
    return _asRows(response.data);
  }

  Future<void> createBuyer({required String name, String? country}) async {
    await _post(
      'buyers',
      data: <String, dynamic>{
        'name': name,
        if (country != null && country.trim().isNotEmpty)
          'country': country.trim(),
      },
    );
  }

  Future<void> updateBuyer({
    required String id,
    required String name,
    String? country,
  }) async {
    await _put(
      'buyers/${Uri.encodeComponent(id)}',
      data: <String, dynamic>{
        'name': name,
        if (country != null && country.trim().isNotEmpty)
          'country': country.trim(),
      },
    );
  }

  Future<void> deleteBuyer(String id) async {
    await _delete('buyers/${Uri.encodeComponent(id)}');
  }

  Future<List<Map<String, dynamic>>> fetchMaterials() async {
    final response = await _get('materials');
    return _asRows(response.data);
  }

  Future<void> createMaterial({
    required String name,
    required String type,
    required String uom,
  }) async {
    await _post(
      'materials',
      data: <String, dynamic>{'name': name, 'type': type, 'uom': uom},
    );
  }

  Future<List<Map<String, dynamic>>> fetchStyles() async {
    final response = await _get('styles');
    return _asRows(response.data);
  }

  Future<void> createStyle({
    required String styleNo,
    required String name,
    String? season,
  }) async {
    await _post(
      'styles',
      data: <String, dynamic>{
        'styleNo': styleNo,
        'name': name,
        if (season != null && season.trim().isNotEmpty) 'season': season.trim(),
      },
    );
  }

  Future<void> updateStyle({
    required String id,
    required String styleNo,
    required String name,
    String? season,
  }) async {
    await _put(
      'styles/${Uri.encodeComponent(id)}',
      data: <String, dynamic>{
        'styleNo': styleNo,
        'name': name,
        if (season != null && season.trim().isNotEmpty) 'season': season.trim(),
      },
    );
  }

  Future<void> deleteStyle(String id) async {
    await _delete('styles/${Uri.encodeComponent(id)}');
  }

  Future<void> saveBom({
    required String styleId,
    required String materialId,
    required double consumption,
  }) async {
    await _post(
      'styles/${Uri.encodeComponent(styleId)}/bom',
      data: <String, dynamic>{
        'items': <Map<String, dynamic>>[
          <String, dynamic>{
            'materialId': materialId,
            'consumption': consumption,
          },
        ],
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchInventoryStock() async {
    final response = await _get('inventory/stock');
    return _asRows(response.data);
  }

  Future<void> receiveInventory({
    required String materialId,
    required double qty,
  }) async {
    await _post(
      'inventory/receive',
      data: <String, dynamic>{
        'materialId': materialId,
        'qty': qty,
        'refType': 'GRN',
      },
    );
  }

  Future<void> issueInventoryToCutting({
    required String materialId,
    required double qty,
  }) async {
    await _post(
      'inventory/issue-to-cutting',
      data: <String, dynamic>{
        'materialId': materialId,
        'qty': qty,
        'refType': 'ISSUE_CUTTING',
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchPos() async {
    final response = await _get('pos');
    return _asRows(response.data);
  }

  Future<Map<String, dynamic>> fetchPoDetail(String poId) async {
    final response = await _get('pos/${Uri.encodeComponent(poId)}');
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> fetchPoMaterialRequirement(String poId) async {
    final response = await _get(
      'pos/${Uri.encodeComponent(poId)}/material-requirement',
    );
    return _asMap(response.data);
  }

  Future<void> createPo({required String poNo, required String buyerId}) async {
    await _post(
      'pos',
      data: <String, dynamic>{'poNo': poNo, 'buyerId': buyerId},
    );
  }

  Future<void> addPoItem({
    required String poId,
    required String styleId,
    required String color,
    required int quantity,
  }) async {
    await _post(
      'pos/${Uri.encodeComponent(poId)}/items',
      data: <String, dynamic>{
        'styleId': styleId,
        'color': color,
        'quantity': quantity,
      },
    );
  }

  Future<void> confirmPo(String id) async {
    await _post('pos/${Uri.encodeComponent(id)}/confirm');
  }

  Future<void> updatePoStatus({
    required String id,
    required String status,
  }) async {
    await _post(
      'pos/${Uri.encodeComponent(id)}/status',
      data: <String, dynamic>{'status': status},
    );
  }

  Future<Map<String, dynamic>> createPlan({
    required String name,
    required String startDate,
    required String endDate,
  }) async {
    final response = await _post(
      'plans',
      data: <String, dynamic>{
        'name': name,
        'startDate': startDate,
        'endDate': endDate,
      },
    );
    return _asMap(response.data);
  }

  Future<void> assignPlan({
    required String planId,
    required String poId,
    required String poItemId,
    required String lineId,
    required String startDate,
    required String endDate,
    required String targetDate,
    required int targetQty,
  }) async {
    await _post(
      'plans/${Uri.encodeComponent(planId)}/assign',
      data: <String, dynamic>{
        'poId': poId,
        'poItemId': poItemId,
        'lineId': lineId,
        'startDate': startDate,
        'endDate': endDate,
        'dailyTargets': <Map<String, dynamic>>[
          <String, dynamic>{'date': targetDate, 'targetQty': targetQty},
        ],
      },
    );
  }

  Future<Map<String, dynamic>> fetchPlanDetail(String planId) async {
    final response = await _get('plans/${Uri.encodeComponent(planId)}');
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> createCuttingBatch({
    required String poItemId,
    required String batchNo,
  }) async {
    final response = await _post(
      'cutting/batches',
      data: <String, dynamic>{'poItemId': poItemId, 'batchNo': batchNo},
    );
    return _asMap(response.data);
  }

  Future<void> createBundles({
    required String batchId,
    required String size,
    required int qty,
  }) async {
    await _post(
      'cutting/batches/${Uri.encodeComponent(batchId)}/bundles',
      data: <String, dynamic>{
        'bundles': <Map<String, dynamic>>[
          <String, dynamic>{'size': size, 'qty': qty},
        ],
      },
    );
  }

  Future<Map<String, dynamic>> fetchCuttingBatch(String batchId) async {
    final response = await _get(
      'cutting/batches/${Uri.encodeComponent(batchId)}',
    );
    return _asMap(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchBundles() async {
    final response = await _get('cutting/bundles');
    return _asRows(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchLineStatus({
    required String date,
  }) async {
    final response = await _get(
      'sewing/line-status',
      queryParameters: <String, dynamic>{'date': date},
    );
    return _asRows(response.data);
  }

  Future<void> submitHourlyOutput({
    required String lineId,
    required String date,
    required int hourSlot,
    required int qty,
    String? bundleId,
  }) async {
    await _post(
      'sewing/hourly-output',
      data: <String, dynamic>{
        'lineId': lineId,
        'date': date,
        'hourSlot': hourSlot,
        'qty': qty,
        if (bundleId != null && bundleId.trim().isNotEmpty)
          'bundleId': bundleId.trim(),
      },
    );
  }

  Future<Map<String, dynamic>> fetchQcSummary({required String date}) async {
    final response = await _get(
      'qc/summary',
      queryParameters: <String, dynamic>{'date': date},
    );
    return _asMap(response.data);
  }

  Future<void> submitQcInspection({
    required String bundleId,
    required String type,
    required bool pass,
    String? notes,
    String? defectType,
    int? defectCount,
  }) async {
    await _post(
      'qc/inspect',
      data: <String, dynamic>{
        'bundleId': bundleId,
        'type': type,
        'pass': pass,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
        if (defectType != null &&
            defectType.trim().isNotEmpty &&
            defectCount != null &&
            defectCount > 0)
          'defects': <Map<String, dynamic>>[
            <String, dynamic>{
              'defectType': defectType.trim(),
              'count': defectCount,
            },
          ],
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchDashboardPlanVsActual({
    required String date,
  }) async {
    final response = await _get(
      'reports/plan-vs-actual',
      queryParameters: <String, dynamic>{'date': date},
    );
    return _asRows(response.data);
  }

  Future<Response<dynamic>> _get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _requestWithApiFallback(
      'GET',
      path,
      queryParameters: queryParameters,
    );
  }

  Future<Response<dynamic>> _post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _requestWithApiFallback(
      'POST',
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response<dynamic>> _put(String path, {Map<String, dynamic>? data}) {
    return _requestWithApiFallback('PUT', path, data: data);
  }

  Future<Response<dynamic>> _delete(String path) {
    return _requestWithApiFallback('DELETE', path);
  }

  Future<Response<dynamic>> _requestWithApiFallback(
    String method,
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final normalized = path.startsWith('/') ? path.substring(1) : path;
    final options = Options(method: method);

    try {
      return await _dio.request<dynamic>(
        '/api/$normalized',
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (error) {
      if (error.response?.statusCode != 404) rethrow;
    }

    return _dio.request<dynamic>(
      '/$normalized',
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is List) {
      final list = jsonList(raw);
      if (list.isEmpty) return const <String, dynamic>{};
      return jsonMap(list.first);
    }

    final map = jsonMap(raw);
    final payloadMap = jsonMap(map['data']);
    if (payloadMap.isNotEmpty) return payloadMap;

    final payloadItems = jsonList(map['data']);
    if (payloadItems.isNotEmpty) return jsonMap(payloadItems.first);

    final itemsMap = jsonMap(map['items']);
    if (itemsMap.isNotEmpty) return itemsMap;

    return map;
  }

  List<Map<String, dynamic>> _asRows(dynamic raw) {
    if (raw is List) {
      return jsonList(raw).map(jsonMap).toList(growable: false);
    }

    final map = jsonMap(raw);
    final candidates = <dynamic>[
      map['data'],
      map['items'],
      map['results'],
      map['rows'],
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return jsonList(candidate).map(jsonMap).toList(growable: false);
      }
    }

    for (final value in map.values) {
      if (value is List) {
        final rows = jsonList(value).map(jsonMap).toList(growable: false);
        if (rows.isNotEmpty) return rows;
      }
    }

    return const <Map<String, dynamic>>[];
  }
}

final operationsRepositoryProvider = Provider<OperationsRepository>(
  (ref) => OperationsRepository(ref.read(dioProvider)),
);
