import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/result.dart';
import 'package:validasi/src/engine/rule.dart';
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

    for (final rule in rules ?? []) {
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
}
