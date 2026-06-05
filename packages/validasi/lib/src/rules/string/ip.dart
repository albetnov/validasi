import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class Ipv4 extends Rule<String> {
  const Ipv4({super.message});

  @override
  String? apply(String? value, ValidationState state) {
    if (value != null && !_isValidIpv4(value)) {
      state.addError(
        ValidationError(
          rule: 'Ipv4',
          message: message ?? 'Must be a valid IPv4 address',
        ),
      );
    }
    return value;
  }

  static bool _isValidIpv4(String value) {
    final parts = value.split('.');
    if (parts.length != 4) return false;

    for (final part in parts) {
      if (part.isEmpty || part.length > 3) return false;
      if (part.length > 1 && part.startsWith('0')) return false;
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) return false;
    }
    return true;
  }
}

class Ipv6 extends Rule<String> {
  const Ipv6({super.message});

  @override
  String? apply(String? value, ValidationState state) {
    if (value != null && !_isValidIpv6(value)) {
      state.addError(
        ValidationError(
          rule: 'Ipv6',
          message: message ?? 'Must be a valid IPv6 address',
        ),
      );
    }
    return value;
  }

  static bool _isValidIpv6(String value) {
    if (value.contains(':::')) return false;

    final parts = value.split(':');
    if (parts.length < 3 || parts.length > 8) return false;

    final hasCompression = value.contains('::');
    final emptyGroups = parts.where((p) => p.isEmpty).length;

    if (hasCompression && emptyGroups > 3) return false;
    if (!hasCompression && parts.length != 8) return false;

    final hexPattern = RegExp(r'^[0-9a-f]{1,4}$', caseSensitive: false);

    for (final part in parts) {
      if (part.isEmpty) continue;
      if (!hexPattern.hasMatch(part)) return false;
    }
    return true;
  }
}

class Ip extends Rule<String> {
  const Ip({super.message});

  @override
  String? apply(String? value, ValidationState state) {
    if (value != null &&
        !Ipv4._isValidIpv4(value) &&
        !Ipv6._isValidIpv6(value)) {
      state.addError(
        ValidationError(
          rule: 'Ip',
          message: message ?? 'Must be a valid IP address',
        ),
      );
    }
    return value;
  }
}
