import 'package:validasi/src/transformers/transformer.dart';

/// Transform the value into [String] object.
/// It uses `toString` method to transform the value.
///
/// Example:
/// ```dart
/// Validasi.string(transformer: StringTransformer()).parse(123);
/// ```
class StringTransformer extends Transformer<String> {
  @override
  String transform(value, fail) => value.toString();
}
