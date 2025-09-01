import 'package:validasi/src/rules/map/conditional_field.dart';
import 'package:validasi/src/rules/map/has_field_keys.dart';
import 'package:validasi/src/rules/map/has_fields.dart';
import 'package:validasi/src/rules/string/min_length.dart';
import 'package:validasi/validasi.dart';

void main(List<String> args) {
  final schema = Validasi.map<dynamic>([
    HasFields({
      'name': Validasi.string([MinLength(1, message: 'Name cannot be empty')]),
      'age': Validasi.string([MinLength(1, message: 'Age cannot be empty')]),
      'is_order': Validasi.any<bool>(),
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
    ConditionalField('address', (context, value) {
      if (context.get('is_order') == true && context.get('address') == null) {
        return 'Address is required when is_order is true';
      }

      return null;
    })
  ]);

  final result = schema.validate({
    'name': 'John Doe',
    'age': 30,
    'is_order': true,
    'address': <String, String>{},
  });

  print("First schema "
      "isValid: ${result.isValid}, "
      "errors: ${result.errors.map((e) => "[${e.path?.join(':')}] ${e.message}").join(', ')}, "
      "value: ${result.data}, type: ${result.data.runtimeType}");

  final schema2 = Validasi.map([
    HasFieldKeys({'name', 'email'}),
  ]);

  final result2 = schema2.validate(<String, dynamic>{});

  print("Second schema "
      "isValid: ${result2.isValid}, "
      "errors: ${result2.errors.map((e) => "[${e.path?.join(':')}] ${e.message}").join(', ')}, "
      "value: ${result2.data}, type: ${result2.data.runtimeType}");
}
