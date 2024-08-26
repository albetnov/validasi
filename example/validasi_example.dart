import 'package:validasi/src/array_validator.dart';
import 'package:validasi/src/string_validator.dart';

void main() {
  var schema = ArrayValidator<ArrayValidator, List<dynamic>>(
      ArrayValidator(ArrayValidator(StringValidator().required())));

  var result = schema.tryParse([
    ['persist']
  ]);

  for (var error in result.errors) {
    print(error.message);
  }
}
