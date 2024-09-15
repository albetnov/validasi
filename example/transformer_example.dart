import 'package:validasi/src/transformers/string_transformer.dart';
import 'package:validasi/src/validators/string_validator.dart';

void main(List<String> args) {
  StringValidator schema = StringValidator(transformer: StringTransformer());

  var result = schema.parse(true);

  print(result.value); // 'true'
  print(result.value.runtimeType); // String
}
