import 'package:validasi/validasi.dart';

void main() {
  // simple single validation
  var idSchema = Validasi.number();

  idSchema.parse(null); // FieldErorr exception: field is required

  // nullable skip validation
  // will skip any rules (except custom rule) if the given value is null.
  Validasi.number().nullable().parse(null); // success

  // customize message and field name
  var nameSchema = Validasi.string().minLength(1, message: 'Name is required!');

  nameSchema.parse(null, path: 'name'); // FieldError: name is required

  // object schema validation
  var payloadSchema = Validasi.object({
    'name': Validasi.string().minLength(1).maxLength(200),
    'address': Validasi.string().minLength(1).maxLength(255)
  });

  var payload =
      payloadSchema.parse({'name': 'Asep', 'address': 'Somewhere else...'});

  print(payload.value); // return the parse payload (with casting)

  // array validation
  var arrSchema = Validasi.array(Validasi.string().minLength(1));

  // use `try` prefix to avoid raised any exceptions
  var arr = arrSchema.tryParse(['test']);

  print(arr.value); // return the payload (with casting)

  // The Form Helpers (for flutter)

  // the group helper
  var group = GroupValidator(
    {'field1': Validasi.string(), 'field2': Validasi.number()},
  );

  group.using('field1').validate(10); // String?(field1 is not a string.)
  group.using('field2').validate('test'); // num?(field2 is not a number.)

  // extending the group validator entry
  group
      .extend<StringValidator>('field1', (validator) => validator.maxLength(3))
      .validate('1234'); // String?(field1 is too long, max 3)

  // the inline field helper
  FieldValidator(Validasi.string())
      .validate(10); // String?(field is not a string.)
}
