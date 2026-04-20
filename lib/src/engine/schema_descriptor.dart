import 'package:validasi/src/engine/rule_metadata.dart';

class SchemaDescriptor {
  const SchemaDescriptor({
    required this.id,
    required this.type,
    required this.cacheEnabled,
    required this.hasPreprocess,
    required this.rules,
    this.isReference = false,
    this.referenceTo,
  });

  const SchemaDescriptor.reference({
    required this.id,
    required this.type,
    required this.referenceTo,
  })  : cacheEnabled = true,
        hasPreprocess = false,
        rules = const <RuleMetadata>[],
        isReference = true;

  final String id;
  final String type;
  final bool cacheEnabled;
  final bool hasPreprocess;
  final List<RuleMetadata> rules;
  final bool isReference;
  final String? referenceTo;

  Map<String, Object?> toJson() {
    final json = <String, Object?>{
      'id': id,
      'type': type,
      'isReference': isReference,
    };

    if (isReference) {
      json['referenceTo'] = referenceTo;
      return json;
    }

    json['cacheEnabled'] = cacheEnabled;
    json['hasPreprocess'] = hasPreprocess;
    json['rules'] = rules.map((rule) => rule.toJson()).toList(growable: false);

    return json;
  }
}