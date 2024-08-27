import 'package:validasi/src/forms/field_validator.dart';
import 'package:validasi/src/forms/group_validator.dart';
import 'package:validasi/src/validators/validator.dart';

class Form {
  static GroupValidator group(Map<String, Validator> schema) =>
      GroupValidator(schema);

  static FieldValidator field(Validator validator) => FieldValidator(validator);
}
