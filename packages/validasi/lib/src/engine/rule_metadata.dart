class RuleMetadata {
  const RuleMetadata({
    required this.name,
    this.parameters = const <String, Object?>{},
    this.runOnNull = false,
    this.message,
    this.isDynamic = false,
    this.dynamicReason,
    this.nestedSchemas = const <String, Map<String, Object?>>{},
  });

  factory RuleMetadata.dynamic({
    required String name,
    bool runOnNull = false,
    String? message,
    String? dynamicReason,
  }) {
    return RuleMetadata(
      name: name,
      runOnNull: runOnNull,
      message: message,
      isDynamic: true,
      dynamicReason:
          dynamicReason ?? 'Rule metadata is not explicitly defined.',
    );
  }

  final String name;
  final Map<String, Object?> parameters;
  final bool runOnNull;
  final String? message;
  final bool isDynamic;
  final String? dynamicReason;
  final Map<String, Map<String, Object?>> nestedSchemas;

  RuleMetadata withNestedSchemas(
    Map<String, Map<String, Object?>> value,
  ) {
    return RuleMetadata(
      name: name,
      parameters: parameters,
      runOnNull: runOnNull,
      message: message,
      isDynamic: isDynamic,
      dynamicReason: dynamicReason,
      nestedSchemas: value,
    );
  }

  Map<String, Object?> toJson() {
    final json = <String, Object?>{
      'name': name,
      'runOnNull': runOnNull,
      'isDynamic': isDynamic,
    };

    if (message != null) {
      json['message'] = message;
    }

    if (dynamicReason != null) {
      json['dynamicReason'] = dynamicReason;
    }

    if (parameters.isNotEmpty) {
      json['parameters'] = _sortObjectMap(parameters);
    }

    if (nestedSchemas.isNotEmpty) {
      final keys = nestedSchemas.keys.toList()..sort();
      final sorted = <String, Map<String, Object?>>{};

      for (final key in keys) {
        sorted[key] = nestedSchemas[key]!;
      }

      json['nestedSchemas'] = sorted;
    }

    return json;
  }
}

Map<String, Object?> _sortObjectMap(Map<String, Object?> source) {
  final keys = source.keys.toList()..sort();
  final sorted = <String, Object?>{};

  for (final key in keys) {
    sorted[key] = source[key];
  }

  return sorted;
}
