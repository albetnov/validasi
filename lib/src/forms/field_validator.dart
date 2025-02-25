import 'package:validasi/src/exceptions/field_error.dart';
import 'package:validasi/src/validators/validator.dart';

/// A wrapper around [Validator] to capture first error message and return it.
/// The [FieldValidator] is suitable to be used on Flutter's `FormField`.
/// The constructor accepts [Validator] as parameter.
class FieldValidator {
  /// The [Validator] to be wrapped
  final Validator validator;
  // Custom path for the error message
  final String path;

  const FieldValidator(this.validator, {this.path = 'field'});

  /// Perform the validation and catch the `message`.
  /// Return `null` if success.
  /// Return `string` if any error encountered.
  String? validate(dynamic value) {
    try {
      validator.parse(value, path: path);
      return null;
    } on FieldError catch (e) {
      return e.message;
    }
  }

  /// Perform the validation asynchronously and catch the `message`.
  /// Return `null` if success.
  /// Return `string` if any error encountered.
  Future<String?> validateAsync(dynamic value) async {
    try {
      await validator.parseAsync(value, path: path);
      return null;
    } on FieldError catch (e) {
      return e.message;
    }
  }
}
