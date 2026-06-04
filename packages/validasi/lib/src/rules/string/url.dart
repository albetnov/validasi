import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class Url extends Rule<String> {
  const Url({
    this.requireScheme = true,
    this.requireHost = true,
    this.httpsOnly = false,
    super.message,
  });

  final bool requireScheme;
  final bool requireHost;
  final bool httpsOnly;

  @override
  String? apply(String? value, ValidationState state) {
    if (value == null) return value;

    final uri = Uri.tryParse(value);
    if (uri == null) {
      state.addError(
        ValidationError(
          rule: 'Url',
          message: message ?? 'Must be a valid URL',
        ),
      );
      return value;
    }

    if (requireScheme && uri.scheme.isEmpty) {
      state.addError(
        ValidationError(
          rule: 'Url',
          message: message ?? 'Must have a scheme',
        ),
      );
      return value;
    }

    if (httpsOnly && uri.scheme != 'https') {
      state.addError(
        ValidationError(
          rule: 'Url',
          message: message ?? 'Must use HTTPS scheme',
        ),
      );
      return value;
    }

    if (requireHost && uri.host.isEmpty) {
      state.addError(
        ValidationError(
          rule: 'Url',
          message: message ?? 'Must have a host',
        ),
      );
      return value;
    }

    return value;
  }
}
