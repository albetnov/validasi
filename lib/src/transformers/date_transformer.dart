import 'package:intl/intl.dart';
import 'package:validasi/src/transformers/transformer.dart';

/// Transform the value into [DateTime] object.
/// Based on the [pattern] provided.
///
/// If the value is not a valid date, the transformer will return `null`.
///
/// Example:
/// ```dart
/// Validasi.date(transformer: DateTransformer()).parse('2021-01-01');
/// ```
class DateTransformer extends Transformer<DateTime> {
  final String pattern;

  const DateTransformer({this.pattern = 'y-MM-dd'});

  @override
  DateTime? transform(value, fail) =>
      DateFormat(pattern).tryParse(value.toString());
}
