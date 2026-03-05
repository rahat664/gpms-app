import '../../../core/json/json_utils.dart';

class PoListItem {
  const PoListItem({
    required this.id,
    required this.poNo,
    required this.status,
    required this.buyerName,
    this.progress,
    this.createdAt,
    this.dueDate,
  });

  final String id;
  final String poNo;
  final String status;
  final String buyerName;
  final double? progress;
  final String? createdAt;
  final String? dueDate;

  factory PoListItem.fromJson(Map<String, dynamic> json) {
    return PoListItem(
      id: firstString(json, const ['id', 'poId']) ?? '',
      poNo: firstString(json, const ['poNo', 'po_no', 'number']) ?? '-',
      status: firstString(json, const ['status']) ?? 'unknown',
      buyerName:
          firstString(json, const ['buyerName', 'buyer', 'buyer_name']) ?? '-',
      progress: () {
        final value = firstDouble(
          json,
          const ['progress', 'progressPercent', 'completion'],
          fallback: double.nan,
        );
        return value.isNaN ? null : value;
      }(),
      createdAt: firstString(json, const ['createdAt', 'created_at']),
      dueDate: firstString(json, const ['dueDate', 'deliveryDate', 'due_date']),
    );
  }
}

class PoDetail {
  const PoDetail({
    required this.id,
    required this.poNo,
    required this.status,
    required this.buyerName,
    required this.items,
    required this.materialRequirements,
    this.createdAt,
    this.dueDate,
    this.deliveryDate,
  });

  final String id;
  final String poNo;
  final String status;
  final String buyerName;
  final String? createdAt;
  final String? dueDate;
  final String? deliveryDate;
  final List<Map<String, dynamic>> items;
  final List<Map<String, dynamic>> materialRequirements;

  factory PoDetail.fromJson(Map<String, dynamic> json) {
    final nestedPo = jsonMap(json['po']);
    final source = nestedPo.isNotEmpty ? <String, dynamic>{...json, ...nestedPo} : json;
    final buyerMap = jsonMap(source['buyer']);

    final materialSource =
        source['materialRequirements'] ??
        source['materialRequirement'] ??
        source['requirement'] ??
        source['materials'] ??
        source['materialsRequired'];
    final itemSource = source['items'] ?? source['poItems'] ?? source['lines'];

    return PoDetail(
      id: firstString(source, const ['id', 'poId']) ?? '',
      poNo: firstString(source, const ['poNo', 'po_no', 'number']) ?? '-',
      status: firstString(source, const ['status']) ?? 'unknown',
      buyerName: firstString(
            source,
            const ['buyerName', 'buyer_name'],
          ) ??
          firstString(buyerMap, const ['name']) ??
          '-',
      createdAt: firstString(source, const ['createdAt', 'created_at']),
      dueDate: firstString(source, const ['shipDate', 'dueDate', 'due_date']),
      deliveryDate: firstString(source, const [
        'deliveryDate',
        'delivery_date',
        'shipDate',
      ]),
      items: jsonList(itemSource).map(jsonMap).toList(growable: false),
      materialRequirements:
          jsonList(materialSource).map(jsonMap).toList(growable: false),
    );
  }
}
