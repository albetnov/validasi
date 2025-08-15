import 'package:validasi/src/rules/map/has_fields.dart';
import 'package:validasi/src/rules/string/min_length.dart';
import 'package:validasi/validasi.dart';

void main(List<String> args) {
  final schema = Validasi.map([
    HasFields({
      'name': Validasi.string([MinLength(1, message: 'Name cannot be empty')]),
      'age': Validasi.string([MinLength(1, message: 'Age cannot be empty')]),
      'address': Validasi.map([
        HasFields({
          'street': Validasi.string(
              [MinLength(1, message: 'Street cannot be empty')]),
          'city':
              Validasi.string([MinLength(1, message: 'City cannot be empty')]),
          'zip': Validasi.string(
              [MinLength(5, message: 'Zip code must be at least 5 digits')]),
        })
      ]),
    }),
  ]);

  final result = schema.validate({
    'name': 'John Doe',
    'age': 30,
    'address': <String, String>{},
  });

  print("isValid: ${result.isValid}, "
      "errors: ${result.errors.map((e) => "[${e.path?.join(':')}] ${e.message}").join(', ')}, "
      "value: ${result.data}, type: ${result.data.runtimeType}");
}
