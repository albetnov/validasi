import 'package:validasi/validasi.dart';

void main(List<String> args) {
  var schema = Validasi.string().maxLength(255);

  var result = schema.parse(args.firstOrNull);

  print("Hello! ${result.value}");
}
