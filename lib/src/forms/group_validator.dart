import 'package:validasi/src/forms/field_validator.dart';
import 'package:validasi/src/forms/group_error.dart';
import 'package:validasi/src/validators/validator.dart';

class GroupValidator {
  final Map<String, Validator> schema;

  const GroupValidator(this.schema);

  String? validate(String field, dynamic value, {String path = 'field'}) {
    if (!schema.containsKey(field)) {
      throw GroupError("$field is not found on the schema.");
    }

    return FieldValidator(schema[field]!).validate(value, path: path);
  }
}
