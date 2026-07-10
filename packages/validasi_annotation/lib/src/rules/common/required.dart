import 'package:validasi_annotation/src/base.dart';

/// Validates that a field is non-null.
///
/// By default, any field with a non-nullable Dart type automatically receives
/// the Required check—you don't need to write `@Required()` explicitly.
/// Write `@Required(message: '...')` only to override the error message, or to
/// force the required check on a field that would otherwise be nullable
/// (e.g., a field with a nullable type that should not be).
///
/// See [Nullable] to mark a non-nullable field as exempt from the check.
class Required<T> extends Rule<T> {
  const Required({super.message});
}
