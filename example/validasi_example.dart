import 'package:validasi/validasi.dart';

void main() {
  // simple single validation
  var idSchema = Validasi.number().required();

  idSchema.parse(null); // FieldErorr exception: field is required

  // customize message and field name
  var nameSchema = Validasi.string().required(message: ':name must be filled');

  nameSchema.parse(null, path: 'name'); // FieldError: name is required

  // non-strict validation (allowing type conversion in the end).
  var roomNumberSchema = Validasi.number(strict: false).required();

  var roomNumber = roomNumberSchema.parse('35');
  print(roomNumber.value); // num(35).

  // object schema validation
  var payloadSchema = Validasi.object({
    'name': Validasi.string().required().maxLength(200),
    'address': Validasi.string().required().maxLength(255)
  });

  var payload =
      payloadSchema.parse({'name': 'Asep', 'address': 'Somewhere else...'});

  print(payload.value); // return the parse payload (with casting)

  // array validation
  var arrSchema = Validasi.array(Validasi.string().required());

  // use `try` prefix to avoid raised any exceptions
  var arr = arrSchema.tryParse(['test']);

  print(arr.value); // return the payload (with casting)

  // The Form Helpers (for flutter)

  // the group helper
  var group = GroupValidator(
      {'field1': Validasi.string(), 'field2': Validasi.number()});

  group.validate('field1', 10); // String?(field1 is not a string.)

  // the inline field helper
  FieldValidator(Validasi.string())
      .validate(10); // String?(field is not a string.)
}
