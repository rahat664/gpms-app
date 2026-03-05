String requireText(String value, String fieldName) {
  final next = value.trim();
  if (next.isEmpty) {
    throw FormatException('$fieldName is required');
  }
  return next;
}

String requireDate(String value, String fieldName) {
  final next = requireText(value, fieldName);
  final parsed = DateTime.tryParse(next);
  if (parsed == null) {
    throw FormatException('$fieldName must be a valid date');
  }
  return next;
}

int requirePositiveInt(String value, String fieldName, {int min = 1}) {
  final parsed = int.tryParse(value.trim());
  if (parsed == null || parsed < min) {
    throw FormatException('$fieldName must be at least $min');
  }
  return parsed;
}

double requirePositiveDouble(String value, String fieldName, {double min = 1}) {
  final parsed = double.tryParse(value.trim());
  if (parsed == null || parsed < min) {
    throw FormatException('$fieldName must be at least $min');
  }
  return parsed;
}

void ensureDateOrder(
  String startDate,
  String endDate, {
  String startLabel = 'Start Date',
  String endLabel = 'End Date',
}) {
  final start = DateTime.parse(requireDate(startDate, startLabel));
  final end = DateTime.parse(requireDate(endDate, endLabel));

  if (start.isAfter(end)) {
    throw FormatException('$startLabel must be on or before $endLabel');
  }
}
