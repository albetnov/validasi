import 'package:intl/intl.dart';
import 'package:validasi/src/transformers/transformer.dart';

class DateTransformer extends Transformer<DateTime> {
  final String pattern;

  const DateTransformer({this.pattern = 'y-MM-dd'});

  @override
  DateTime? transform(value, fail) =>
      DateFormat(pattern).tryParse(value.toString());
}
