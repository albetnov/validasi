class ValidationError {
  const ValidationError({
    required this.rule,
    required this.message,
    this.details,
    this.path,
  });

  final String rule;
  final String message;
  final Map<String, dynamic>? details;
  final List<String>? path;

  ValidationError withPrefix(String prefix) {
    return ValidationError(
      rule: rule,
      message: message,
      details: details,
      path: [prefix, ...?path],
    );
  }

  Map<String, Object?> toToolMap() {
    final map = <String, Object?>{
      'rule': rule,
      'message': message,
      'path': List<String>.unmodifiable(path ?? const <String>[]),
    };

    if (details != null && details!.isNotEmpty) {
      map['details'] = _normalizeMap(details!);
    }

    return map;
  }
}

Object? normalizeToolValue(Object? value) {
  if (value == null || value is String || value is num || value is bool) {
    return value;
  }

  if (value is DateTime) {
    return value.toIso8601String();
  }

  if (value is Enum) {
    return value.name;
  }

  if (value is Map) {
    return _normalizeMap(value);
  }

  if (value is Iterable) {
    return value
        .map((item) => normalizeToolValue(item))
        .toList(growable: false);
  }

  return '$value';
}

Map<String, Object?> _normalizeMap(Map source) {
  final entries = source.entries.toList(growable: false)
    ..sort(
      (a, b) => a.key.toString().compareTo(b.key.toString()),
    );

  final normalized = <String, Object?>{};

  for (final entry in entries) {
    normalized[entry.key.toString()] = normalizeToolValue(entry.value);
  }

  return normalized;
}
