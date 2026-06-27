import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
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

bool? readGenerateIndexedFieldsOverride(ClassElement cls) {
  for (final meta in cls.metadata.annotations) {
    final element = meta.element;
    if (element is ConstructorElement &&
        element.enclosingElement.name == 'ValidateClass') {
      final constant = meta.computeConstantValue();
      if (constant == null) return null;
      return ConstantReader(constant).peek('generateIndexedFields')?.boolValue;
    }
  }
  return null;
}

bool? readGenerateAssembleOverride(ClassElement cls) {
  for (final meta in cls.metadata.annotations) {
    final element = meta.element;
    if (element is ConstructorElement &&
        element.enclosingElement.name == 'ValidateClass') {
      final constant = meta.computeConstantValue();
      if (constant == null) return null;
      return ConstantReader(constant).peek('generateAssemble')?.boolValue;
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

  bool get hasAsyncRule => rules.any((r) => r.isAsync);

  String get dartTypeDisplay => field.type.getDisplayString();

  /// True when the Dart type itself enforces non-null (e.g. `String`, not `String?`).
  /// Returns false for `dynamic` and `Object?` since nullability can't be reliably inferred.
  bool get isTypeRequired {
    final t = field.type;
    if (t is DynamicType) return false;
    if (t.isDartCoreObject && t.nullabilitySuffix != NullabilitySuffix.none) {
      return false;
    }
    return t.nullabilitySuffix == NullabilitySuffix.none;
  }

  /// True when the field is required — either inferred from type or explicitly via `@Required`.
  bool get isRequired =>
      isTypeRequired || rules.any((r) => r.name == 'Required');

  /// Custom message from an explicit `@Required(...)` annotation, if present.
  String? get requiredMessage {
    final r = rules.where((r) => r.name == 'Required');
    return r.isNotEmpty ? r.first.message : null;
  }
}

class RefineParamInfo {
  final String name;
  final DartType type;

  const RefineParamInfo({required this.name, required this.type});
}

class RefineMethodInfo {
  final String methodName;
  final List<String> dependsOn;
  final List<RefineParamInfo> parameters;
  final bool isAsync;

  const RefineMethodInfo({
    required this.methodName,
    required this.dependsOn,
    required this.parameters,
    required this.isAsync,
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
      continue;
    }
  }

  return result;
}

List<RefineMethodInfo> extractRefineMethods(ClassElement element) {
  final result = <RefineMethodInfo>[];

  for (final method in element.methods) {
    if (method.isStatic) continue;
    if (method.name == null) continue;

    final annotation = _findRefineFn(method);
    if (annotation == null) continue;

    final dependsOn = _readDependsOnList(annotation);
    final parameters = method.formalParameters
        .where((p) => p.isNamed)
        .map((p) => RefineParamInfo(name: p.name!, type: p.type))
        .toList();
    final isAsync = _isAsyncMethod(method);

    result.add(RefineMethodInfo(
      methodName: method.name!,
      dependsOn: dependsOn,
      parameters: parameters,
      isAsync: isAsync,
    ));
  }

  return result;
}

ElementAnnotation? _findRefineFn(MethodElement method) {
  for (final meta in method.metadata.annotations) {
    final e = meta.element;
    if (e is ConstructorElement && e.enclosingElement.name == 'RefineFn') {
      return meta;
    }
  }
  return null;
}

List<String> _readDependsOnList(ElementAnnotation annotation) {
  final constant = annotation.computeConstantValue();
  if (constant == null) return const [];
  final list = ConstantReader(constant).peek('dependsOn')?.listValue;
  if (list == null) return const [];
  return list
      .map((obj) => ConstantReader(obj).stringValue)
      .where((s) => s.isNotEmpty)
      .toList();
}

bool _isAsyncMethod(MethodElement method) {
  final returnType = method.returnType;
  final element = returnType.element;
  if (element is ClassElement && element.name == 'Future') return true;
  if (returnType.isDartCoreNull) return false;
  final display = returnType.getDisplayString();
  return display.startsWith('Future<');
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

  if (typeElement is ClassElement) {
    final baseName = _customBaseName(typeElement);
    if (baseName != null) {
      return ruleGens[baseName]!.parse(rule);
    }
  }

  return RuleInfo(name, const {}, message, isUnknown: true);
}

String? _customBaseName(ClassElement element) {
  for (final supertype in element.allSupertypes) {
    final name = supertype.element.name;
    if (name == 'CustomRule' || name == 'AsyncCustomRule') {
      return name;
    }
  }
  return null;
}
