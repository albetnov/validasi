import 'package:validasi/src/exceptions/validasi_exception.dart';
import 'package:validasi/src/forms/field_validator.dart';
import 'package:validasi/src/validators/validator.dart';

class GroupValidator {
  final Map<String, Validator> schema;

  const GroupValidator(this.schema);

  String? validate(String field, dynamic value, {String path = 'field'}) {
    if (!schema.containsKey(field)) {
      throw ValidasiException("$field is not found on the schema.");
    }

    return FieldValidator(schema[field]!).validate(value, path: path);
  }
}
