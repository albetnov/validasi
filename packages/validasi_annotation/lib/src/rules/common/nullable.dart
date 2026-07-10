import 'package:validasi_annotation/src/base.dart';

/// Marks a field as exempt from the automatic Required check.
///
/// Fields with non-nullable Dart types automatically receive the Required
/// validation (non-null check). Use `@Nullable()` on a non-nullable field
/// to opt out of this automatic check.
///
/// See [Required] for the validation rule itself.
class Nullable<T> extends Rule<T> {
  const Nullable() : super();
}
