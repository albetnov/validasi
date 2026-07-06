import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

class CrossFieldRuleInfo {
  final String kind;
  final List<String> fields;
  final String? message;

  const CrossFieldRuleInfo({
    required this.kind,
    required this.fields,
    this.message,
  });
}

const _kinds = {
  'RequiredAny',
  'RequiredOneOf',
  'RequiredAll',
  'DependsOn',
  'MutuallyExclusive',
  'MatchesField',
};

List<CrossFieldRuleInfo> extractCrossFieldRules(ClassElement element) {
  final result = <CrossFieldRuleInfo>[];

  for (final meta in element.metadata.annotations) {
    final e = meta.element;
    if (e is! ConstructorElement) continue;
    final kind = e.enclosingElement.name;
    if (kind == null || !_kinds.contains(kind)) continue;

    final constant = meta.computeConstantValue();
    if (constant == null) continue;
    final reader = ConstantReader(constant);
    final message = reader.peek('message')?.stringValue;

    switch (kind) {
      case 'RequiredAny':
      case 'RequiredOneOf':
      case 'RequiredAll':
        final fields = reader
            .read('fields')
            .listValue
            .map((o) => ConstantReader(o).stringValue)
            .toList();
        result.add(
            CrossFieldRuleInfo(kind: kind, fields: fields, message: message));
      case 'DependsOn':
        result.add(CrossFieldRuleInfo(
          kind: kind,
          fields: [
            reader.read('field').stringValue,
            reader.read('dependsOn').stringValue,
          ],
          message: message,
        ));
      case 'MutuallyExclusive':
        result.add(CrossFieldRuleInfo(
          kind: kind,
          fields: [
            reader.read('fieldA').stringValue,
            reader.read('fieldB').stringValue,
          ],
          message: message,
        ));
      case 'MatchesField':
        result.add(CrossFieldRuleInfo(
          kind: kind,
          fields: [
            reader.read('field').stringValue,
            reader.read('matchesField').stringValue,
          ],
          message: message,
        ));
    }
  }

  return result;
}
