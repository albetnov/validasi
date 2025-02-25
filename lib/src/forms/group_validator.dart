import 'package:validasi/src/exceptions/validasi_exception.dart';
import 'package:validasi/src/forms/field_validator.dart';
import 'package:validasi/src/validators/object_validator.dart';
import 'package:validasi/src/validators/validator.dart';

/// [GroupValidator] allows you to combine couple of validators with
/// Map syntax and grouped them together. Do note, that [GroupValidator] is
/// not for validating [Map], you should use [ObjectValidator] instead.
///
/// The [GroupValidator] allow you to use [validate] to quickly return
/// first error message or null if success. Suitable to be passed on Flutter's
/// `FormField`.
///
/// The [GroupValidator] takes [schema] as parameter. The [schema] is a Map
/// with [String] as key and [Validator] as value.
class GroupValidator {
  /// The [schema] contains all [Validator] to be used on [validate].
  final Map<String, Validator> schema;
  String? field;
  String path = 'field';

  GroupValidator(this.schema);

  /// Check if the schema contains [field]. Throw [ValidasiException] if not
  /// found instead.
  void _checkKey() {
    if (field == null) {
      throw ValidasiException('field argument is required');
    }

    if (!schema.containsKey(field)) {
      throw ValidasiException("$field is not found on the schema");
    }
  }

  // Set the [field] to be validated.
  // The [path] is optional, default to 'field'.
  GroupValidator on(String field, {String? path}) {
    this.field = field;

    if (path != null) {
      this.path = path;
    }

    return this;
  }

  /// Perform the validation and catch the `message`.
  /// Return `null` if success.
  /// Return `string` if any error encountered.
  /// Throw [ValidasiException] if [field] not found in [schema].
  String? validate(dynamic value) {
    _checkKey();
    return FieldValidator(schema[field]!, path: path).validate(value);
  }

  /// Perform the validation asynchronously and catch the `message`.
  /// Return `null` if success.
  /// Return `string` if any error encountered.
  /// Throw [ValidasiException] if [field] not found in [schema].
  Future<String?> validateAsync(dynamic value) {
    _checkKey();
    return FieldValidator(schema[field]!, path: path).validateAsync(value);
  }
}
