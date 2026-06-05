import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class Uuid extends Rule<String> {
  const Uuid({this.versions = const [4, 7], super.message});

  final List<int> versions;

  static final _basePattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-([0-9a-f])[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  @override
  String? apply(String? value, ValidationState state) {
    if (value == null) return value;

    final match = _basePattern.firstMatch(value);
    if (match == null) {
      state.addError(
        ValidationError(
          rule: 'Uuid',
          message: message ?? 'Must be a valid UUID',
          details: {'versions': versions.join(', ')},
        ),
      );
      return value;
    }

    final version = int.parse(match.group(1)!, radix: 16);
    if (!versions.contains(version)) {
      state.addError(
        ValidationError(
          rule: 'Uuid',
          message: message ?? 'Must be UUID v${versions.join("/v")}',
          details: {'versions': versions.join(', ')},
        ),
      );
    }
    return value;
  }
}
