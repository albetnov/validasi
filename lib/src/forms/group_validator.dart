import 'package:validasi/src/exceptions/validasi_exception.dart';
import 'package:validasi/src/forms/field_validator.dart';
import 'package:validasi/src/validators/object_validator.dart';
import 'package:validasi/src/validators/validator.dart';

/// [GroupValidator] allows you to combine couple of validators with
/// Map syntax and grouped them together. Do note, that [GroupValidator] is
/// not for validating [Map], you should use [ObjectValidator] instead.
///
/// The [GroupValidator] allows you to use [validate] to quickly return
/// first error message or null if success. Suitable to be passed on Flutter's
/// `FormField`.
class GroupValidator {
  /// [schema] to store the validator.
  final Map<String, Validator> schema;

  const GroupValidator(this.schema);

  /// Check if the schema contains [field]. Throw [ValidasiException] if not
  /// found instead.
  void _containKey(String field) {
    if (!schema.containsKey(field)) {
      throw ValidasiException("$field is not found on the schema");
    }
  }

  /// The [validate] function to run the validation based on [schema] key
  /// ([field]).
  ///
  /// If [field] not found in [schema], [validate] will throw [ValidasiException].
  /// return [String] first error message if found, or `null` if success.
  String? validate(String field, dynamic value, {String path = 'field'}) {
    _containKey(field);

    return FieldValidator(schema[field]!).validate(value, path: path);
  }

  /// Similar to [validate] but with Asyncronous context.
  ///
  /// Throw [ValidasiException] if [field] not found in [schema].
  Future<String?> validateAsync(String field, dynamic value,
      {String path = 'field'}) {
    _containKey(field);

    return FieldValidator(schema[field]!).validateAsync(value, path: path);
  }
}
