import 'package:validasi/src/string_validator.dart';

class Validasi {
  static StringValidator string({bool strict = true}) {
    return StringValidator(strict: strict);
  }
}
