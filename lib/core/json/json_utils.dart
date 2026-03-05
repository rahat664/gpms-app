Map<String, dynamic> jsonMap(dynamic input) {
  if (input is Map<String, dynamic>) return input;
  if (input is Map) {
    return input.map((key, value) => MapEntry(key.toString(), value));
  }
  return <String, dynamic>{};
}

List<dynamic> jsonList(dynamic input) {
  if (input is List<dynamic>) return input;
  if (input is List) return input.cast<dynamic>();
  return const <dynamic>[];
}

String? firstString(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}

int firstInt(Map<String, dynamic> map, List<String> keys, {int fallback = 0}) {
  for (final key in keys) {
    final value = map[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
  }
  return fallback;
}

double firstDouble(
  Map<String, dynamic> map,
  List<String> keys, {
  double fallback = 0,
}) {
  for (final key in keys) {
    final value = map[key];
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
  }
  return fallback;
}
