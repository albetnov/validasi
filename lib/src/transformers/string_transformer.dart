import 'package:validasi/src/transformers/transformer.dart';

class StringTransformer extends Transformer<String> {
  @override
  String transform(value, fail) => value.toString();
}
