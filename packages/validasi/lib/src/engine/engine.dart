import 'dart:collection';

import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/result.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/rule_metadata.dart';
import 'package:validasi/src/engine/schema_descriptor.dart';
import 'package:validasi/src/transformer/validasi_transformation.dart';
import 'package:validasi/src/engine/cache.dart';

class ValidasiEngine<T> {
  const ValidasiEngine({this.rules, this.preprocess, this.cacheEnabled = true});

  final List<Rule<T>>? rules;
  final ValidasiTransformation<dynamic, T>? preprocess;
  final bool cacheEnabled;

  ValidasiEngine<T> withPreprocess(
      ValidasiTransformation<dynamic, T> preprocess) {
    return ValidasiEngine<T>(
      rules: rules,
      preprocess: preprocess,
      cacheEnabled: cacheEnabled,
    );
  }

  ValidasiResult<T> validate(dynamic value) {
    final originalInput = value;

    // Cache lookup (default ON)
    final cacheKey = cacheEnabled ? computeCacheKey(originalInput) : null;
    if (cacheKey != null && cacheEnabled) {
      final cached = EngineCache.get(this, cacheKey);
      if (cached != null) {
        return cached as ValidasiResult<T>;
      }
    }

    if (preprocess != null) {
      final result = preprocess!.tryTransform(value);
      if (!result.isValid) {
        final ValidasiResult<T> r = ValidasiResult<T>.error(
          ValidationError(
            rule: 'Preprocess',
            message: 'Failed to preprocess value',
            details: {
              'exception': result.error?.toString() ?? 'Unknown error',
            },
          ),
        );
        if (cacheKey != null && cacheEnabled) {
          EngineCache.set(this, cacheKey, r);
        }
        return r;
      }

      value = result.data;
    }

    if (value is! T?) {
      final ValidasiResult<T> r = ValidasiResult<T>.error(ValidationError(
        rule: 'TypeCheck',
        message: 'Expected type $T, got ${value.runtimeType}',
        details: {'value': value},
      ));
      if (cacheKey != null && cacheEnabled) {
        EngineCache.set(this, cacheKey, r);
      }
      return r;
    }

    final context = ValidationContext(value: value);

    for (final rule in rules ?? <Rule<T>>[]) {
      if (context.value == null && !rule.runOnNull) {
        continue;
      }

      rule.apply(context);

      if (context.isStopped) {
        break;
      }
    }

    final ValidasiResult<T> result = ValidasiResult<T>(
      isValid: context.errors.isEmpty,
      data: context.value,
      errors: context.errors,
    );

    if (cacheKey != null && cacheEnabled) {
      EngineCache.set(this, cacheKey, result);
    }

    return result;
  }

  /// Clears the per-instance cache.
  void clearCache() {
    EngineCache.clear(this);
  }

  SchemaDescriptor introspect() {
    return _SchemaIntrospector().describe(this);
  }
}

class _SchemaIntrospector {
  final HashMap<ValidasiEngine<dynamic>, String> _ids =
      HashMap<ValidasiEngine<dynamic>, String>.identity();
  final HashSet<ValidasiEngine<dynamic>> _active =
      HashSet<ValidasiEngine<dynamic>>.identity();
  final HashSet<ValidasiEngine<dynamic>> _completed =
      HashSet<ValidasiEngine<dynamic>>.identity();

  SchemaDescriptor describe<T>(ValidasiEngine<T> engine) {
    return _describe(engine as ValidasiEngine<dynamic>);
  }

  SchemaDescriptor _describe(ValidasiEngine<dynamic> engine) {
    final id = _ids.putIfAbsent(engine, () => 'schema_${_ids.length + 1}');
    final type = _extractValueType(engine);

    if (_active.contains(engine) || _completed.contains(engine)) {
      return SchemaDescriptor.reference(
        id: id,
        type: type,
        referenceTo: id,
      );
    }

    _active.add(engine);
    final resolvedRules = <RuleMetadata>[];
    final rules = engine.rules ?? const <Rule<dynamic>>[];

    for (final rule in rules) {
      final nestedSchemas = _describeNestedSchemas(rule.metadataChildren);
      final metadata = nestedSchemas.isEmpty
          ? rule.metadata
          : rule.metadata.withNestedSchemas(nestedSchemas);
      resolvedRules.add(metadata);
    }

    _active.remove(engine);
    _completed.add(engine);

    return SchemaDescriptor(
      id: id,
      type: type,
      cacheEnabled: engine.cacheEnabled,
      hasPreprocess: engine.preprocess != null,
      rules: resolvedRules,
    );
  }

  Map<String, Map<String, Object?>> _describeNestedSchemas(
    Map<String, Object?> children,
  ) {
    if (children.isEmpty) {
      return const <String, Map<String, Object?>>{};
    }

    final keys = children.keys.toList()..sort();
    final nested = <String, Map<String, Object?>>{};

    for (final key in keys) {
      final child = children[key];

      if (child is ValidasiEngine) {
        nested[key] = _describe(child).toJson();
      }
    }

    return nested;
  }

  String _extractValueType(ValidasiEngine<dynamic> engine) {
    final runtime = engine.runtimeType.toString();
    final start = runtime.indexOf('<');
    final end = runtime.lastIndexOf('>');

    if (start == -1 || end == -1 || end <= start + 1) {
      return 'dynamic';
    }

    return runtime.substring(start + 1, end);
  }
}
