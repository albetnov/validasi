import 'package:validasi/src/transformers/transformer.dart';

class NumberTransformer extends Transformer<num> {
  @override
  num? transform(value, fail) => num.tryParse(value.toString());
}
