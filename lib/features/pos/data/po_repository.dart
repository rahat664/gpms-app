import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/json/json_utils.dart';
import '../../../network/dio_provider.dart';
import '../domain/po_models.dart';

class PoRepository {
  PoRepository(this._dio);

  final Dio _dio;

  Future<List<PoListItem>> fetchPos() async {
    final response = await _getWithApiFallback('pos');

    final data = response.data;
    final source = data is List
        ? data
        : (jsonMap(data)['data'] ??
              jsonMap(data)['items'] ??
              jsonMap(data)['results'] ??
              const <dynamic>[]);

    return jsonList(source)
        .map(jsonMap)
        .map(PoListItem.fromJson)
        .where((po) => po.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<PoDetail> fetchPo(String id) async {
    final encodedId = Uri.encodeComponent(id);
    try {
      final response = await _getWithApiFallback('pos/$encodedId');
      return _parsePoDetail(response.data);
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode ?? 0;
      if (statusCode != 404 && statusCode != 400) {
        rethrow;
      }
    }

    final requirementPayload = await _fetchPoMaterialRequirementPayload(id);
    if (requirementPayload.isNotEmpty) {
      final materials =
          requirementPayload['materials'] ??
          requirementPayload['items'] ??
          requirementPayload['requirements'];
      return PoDetail(
        id: id,
        poNo:
            firstString(requirementPayload, const ['poNo', 'number']) ?? id,
        status: firstString(requirementPayload, const ['status']) ?? 'unknown',
        buyerName:
            firstString(requirementPayload, const ['buyerName', 'buyer']) ??
            '-',
        createdAt: firstString(requirementPayload, const [
          'createdAt',
          'created_at',
        ]),
        dueDate: firstString(requirementPayload, const [
          'shipDate',
          'dueDate',
        ]),
        deliveryDate: firstString(requirementPayload, const [
          'deliveryDate',
          'shipDate',
        ]),
        items: const <Map<String, dynamic>>[],
        materialRequirements: jsonList(materials).map(jsonMap).toList(
          growable: false,
        ),
      );
    }

    // Fallback: use list payload so PO detail screen remains usable
    // when dedicated detail endpoint is unavailable in some deployments.
    final fallbackList = await fetchPos();
    final match = fallbackList.where((po) => po.id == id || po.poNo == id).toList(
      growable: false,
    );

    if (match.isNotEmpty) {
      final po = match.first;
      return PoDetail(
        id: po.id,
        poNo: po.poNo,
        status: po.status,
        buyerName: po.buyerName,
        createdAt: po.createdAt,
        dueDate: po.dueDate,
        deliveryDate: po.dueDate,
        items: const <Map<String, dynamic>>[],
        materialRequirements: const <Map<String, dynamic>>[],
      );
    }

    return PoDetail(
      id: id,
      poNo: id,
      status: 'unknown',
      buyerName: '-',
      createdAt: null,
      dueDate: null,
      deliveryDate: null,
      items: const <Map<String, dynamic>>[],
      materialRequirements: const <Map<String, dynamic>>[],
    );
  }

  Future<List<Map<String, dynamic>>> fetchPoMaterialRequirement(String id) async {
    final payload = await _fetchPoMaterialRequirementPayload(id);
    final materials = payload['materials'] ?? payload['items'] ?? payload['requirements'];
    return jsonList(materials).map(jsonMap).toList(growable: false);
  }

  Future<Map<String, dynamic>> _fetchPoMaterialRequirementPayload(String id) async {
    final encodedId = Uri.encodeComponent(id);
    try {
      final response = await _getWithApiFallback(
        'pos/$encodedId/material-requirement',
      );
      final data = jsonMap(response.data);
      final payload = jsonMap(data['data']).isNotEmpty ? jsonMap(data['data']) : data;
      return payload;
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return const <String, dynamic>{};
      }
      rethrow;
    }
  }

  Future<Response<dynamic>> _getWithApiFallback(String pathWithoutLeadingSlash) async {
    try {
      return await _dio.get<dynamic>('/api/$pathWithoutLeadingSlash');
    } on DioException catch (error) {
      if (error.response?.statusCode != 404) rethrow;
    }

    return _dio.get<dynamic>('/$pathWithoutLeadingSlash');
  }

  PoDetail _parsePoDetail(dynamic input) {
    final data = jsonMap(input);

    final payloadMap = jsonMap(data['data']);
    if (payloadMap.isNotEmpty) {
      return PoDetail.fromJson(payloadMap);
    }

    final itemList = jsonList(data['data']);
    if (itemList.isNotEmpty) {
      final first = jsonMap(itemList.first);
      if (first.isNotEmpty) {
        return PoDetail.fromJson(first);
      }
    }

    return PoDetail.fromJson(data);
  }
}

final poRepositoryProvider = Provider<PoRepository>(
  (ref) => PoRepository(ref.read(dioProvider)),
);

final poListProvider = FutureProvider<List<PoListItem>>((ref) {
  return ref.read(poRepositoryProvider).fetchPos();
});

final poDetailsProvider = FutureProvider.family<PoDetail, String>((ref, id) {
  return ref.read(poRepositoryProvider).fetchPo(id);
});

final poMaterialRequirementProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, id) {
      return ref.read(poRepositoryProvider).fetchPoMaterialRequirement(id);
    });
