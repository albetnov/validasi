import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

import 'package:validasi_gen/src/handlers.dart';
import 'package:validasi_gen/src/utils.dart';

bool? readGenerateFieldsOverride(ClassElement cls) {
  for (final meta in cls.metadata.annotations) {
    final element = meta.element;
    if (element is ConstructorElement &&
        element.enclosingElement.name == 'ValidateClass') {
      final constant = meta.computeConstantValue();
      if (constant == null) return null;
      return ConstantReader(constant).peek('generateFields')?.boolValue;
    }
  }
  return null;
}

class FieldRules {
  final FieldElement field;
  final List<RuleInfo> rules;
  final String context;
  final String? nestedClassName;
  final bool isNestedIterable;

  FieldRules(
    this.field,
    this.rules, {
    this.context = '',
    this.nestedClassName,
    this.isNestedIterable = false,
  });

  bool get isNested => nestedClassName != null;

  String get dartTypeDisplay => field.type.getDisplayString();
}

class CrossFieldInfo {
  final FieldElement field;
  final String validatorName;
  final List<String> dependsOn;
  final String? functionName;

  CrossFieldInfo({
    required this.field,
    required this.validatorName,
    required this.dependsOn,
    this.functionName,
  });
}

List<FieldRules> extractValidateFields(
    ClassElement element, LibraryReader library) {
  final result = <FieldRules>[];

  for (final field in element.fields) {
    if (field.isStatic) continue;

    final extracted = _extractRules(field);
    if (extracted != null) {
      result.add(FieldRules(field, extracted.$1, context: extracted.$2));
      continue;
    }

    final nested = detectNestedField(field, library);
    if (nested != null) {
      result.add(FieldRules(
        field,
        const [],
        nestedClassName: nested.$1,
        isNestedIterable: nested.$2,
      ));
    }
  }

  return result;
}

List<CrossFieldInfo> extractCrossFields(ClassElement element) {
  final result = <CrossFieldInfo>[];

  for (final field in element.fields) {
    if (field.isStatic) continue;

    for (final meta in field.metadata.annotations) {
      final metaElement = meta.element;
      if (metaElement is ConstructorElement &&
          metaElement.enclosingElement.name == 'ValidateWith') {
        final constant = meta.computeConstantValue();
        if (constant == null) continue;

        final reader = ConstantReader(constant);

        // Read the validator function name
        final validatorReader = reader.read('validator');
        final validatorElement = validatorReader.objectValue.toFunctionValue();
        final functionName = validatorElement?.name ?? '_unknown';

        // Read dependsOn — a Set<Symbol>
        final dependsOnReader = reader.read('dependsOn');
        final dependsOnSet = dependsOnReader.setValue;
        final dependsOn = <String>[];
        for (final symbol in dependsOnSet) {
          final name = symbol.toSymbolValue();
          if (name != null && name.isNotEmpty) {
            dependsOn.add(name);
          }
        }

        result.add(CrossFieldInfo(
          field: field,
          validatorName: field.name!,
          dependsOn: dependsOn,
          functionName: functionName,
        ));
      }
    }
  }

  return result;
}

(List<RuleInfo>, String)? _extractRules(FieldElement field) {
  for (final meta in field.metadata.annotations) {
    final element = meta.element;
    if (element is ConstructorElement &&
        element.enclosingElement.name == 'Validate') {
      final context = element.name!;
      final constant = meta.computeConstantValue();
      if (constant == null) return null;

      final reader = ConstantReader(constant);
      final rulesReader = reader.read('rules');
      final rulesList = rulesReader.listValue;
      if (rulesList.isEmpty) return ([], context);

      final rules = rulesList.map<RuleInfo>((dartObj) {
        final ruleReader = ConstantReader(dartObj);
        final rule = _parseRule(ruleReader);
        final gen = ruleGens[rule.name];
        if (gen != null) gen.validateType(rule.typeArg, field);
        return rule;
      }).toList();
      return (rules, context);
    }
  }
  return null;
}

RuleInfo _parseRule(ConstantReader rule) {
  final type = rule.objectValue.type;
  final typeElement = type?.element;
  final name = typeElement is ClassElement ? typeElement.name! : 'Unknown';
  final message = rule.peek('message')?.stringValue;

  if (name == 'Required') return RuleInfo('Required', const {}, message);
  if (name == 'Nullable') return RuleInfo('Nullable', const {}, message);

  final gen = ruleGens[name];
  if (gen != null) return gen.parse(rule);

  return RuleInfo(name, const {}, message, isUnknown: true);
}
