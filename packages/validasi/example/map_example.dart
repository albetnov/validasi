import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

void main(List<String> args) {
  final schema = Validasi.map<dynamic>([
    Rules.map.hasFields({
      'name': FieldRules<String>([
        Rules.string.minLength(1, message: 'Name cannot be empty'),
      ]),
      'age': FieldRules<int>([
        Rules.number.moreThanEqual(1, message: 'Age cannot be empty'),
      ]),
      'is_order': FieldRules<bool>([]),
      'address': FieldRules<Map<String, dynamic>>([
        Rules.map.hasFields({
          'street': FieldRules<String>([
            Rules.string.minLength(1, message: 'Street cannot be empty'),
          ]),
          'city': FieldRules<String>([
            Rules.string.minLength(1, message: 'City cannot be empty'),
          ]),
          'zip': FieldRules<String>([
            Rules.string
                .minLength(5, message: 'Zip code must be at least 5 digits'),
          ]),
        }),
      ]),
    }),
    Rules.map.conditionalField('address', (context, value) {
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
    Rules.map.hasFieldKeys({'name', 'email'}),
  ]);

  final result2 = schema2.validate(<String, dynamic>{});

  print("Second schema "
      "isValid: ${result2.isValid}, "
      "errors: ${result2.errors.map((e) => "[${e.path?.join(':')}] ${e.message}").join(', ')}, "
      "value: ${result2.data}, type: ${result2.data.runtimeType}");
}
