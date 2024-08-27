import 'package:validasi/src/field_error.dart';
import 'package:validasi/src/validators/validator.dart';

class FieldValidator {
  final Validator validator;

  const FieldValidator(this.validator);

  String? validate(dynamic value, {String path = 'field'}) {
    try {
      validator.parse(value, path: path);
      return null;
    } on FieldError catch (e) {
      return e.message;
    }
  }
}
