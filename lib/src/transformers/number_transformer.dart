import 'package:validasi/src/transformers/transformer.dart';

/// Transform the value into [num] object.
///
/// If the value is not a valid number, the transformer will return `null`.
///
/// Example:
/// ```dart
/// Validasi.number(transformer: NumberTransformer()).parse('123');
/// ```
class NumberTransformer extends Transformer<num> {
  @override
  num? transform(value, fail) => num.tryParse(value.toString());
}
