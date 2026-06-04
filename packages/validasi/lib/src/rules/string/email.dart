import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class Email extends Rule<String> {
  const Email({
    this.allowTopLevelDomain = false,
    this.allowInternational = false,
    this.domains,
    super.message,
  });

  final bool allowTopLevelDomain;
  final bool allowInternational;
  final List<String>? domains;

  static final _localPartPattern = RegExp(r"^[a-zA-Z0-9!#$%&'*+/=?^_`{|}~.-]+$");
  static final _localPartIntlPattern = RegExp(r"^[\p{L}\p{N}!#$%&'*+/=?^_`{|}~.-]+$", unicode: true);
  static final _domainPattern = RegExp(r'^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?)*$');
  static final _domainIntlPattern = RegExp(r'^[\p{L}\p{N}]([\p{L}\p{N}-]*[\p{L}\p{N}])?(\.[\p{L}\p{N}]([\p{L}\p{N}-]*[\p{L}\p{N}])?)*$', unicode: true);

  @override
  String? apply(String? value, ValidationState state) {
    if (value == null) return value;

    final atIndex = value.lastIndexOf('@');
    if (atIndex <= 0 || atIndex == value.length - 1) {
      state.addError(
        ValidationError(
          rule: 'Email',
          message: message ?? 'Must be a valid email address',
        ),
      );
      return value;
    }

    final localPart = value.substring(0, atIndex);
    final domainPart = value.substring(atIndex + 1);

    if (!_validateLocalPart(localPart)) {
      state.addError(
        ValidationError(
          rule: 'Email',
          message: message ?? 'Must be a valid email address',
        ),
      );
      return value;
    }

    if (!_validateDomainPart(domainPart)) {
      state.addError(
        ValidationError(
          rule: 'Email',
          message: message ?? 'Must be a valid email address',
        ),
      );
      return value;
    }

    if (domains != null && domains!.isNotEmpty) {
      if (!domains!.contains(domainPart.toLowerCase())) {
        state.addError(
          ValidationError(
            rule: 'Email',
            message: message ?? 'Email domain must be one of: ${domains!.join(', ')}',
            details: {'domains': domains!.join(', ')},
          ),
        );
      }
    }

    return value;
  }

  bool _validateLocalPart(String localPart) {
    if (localPart.isEmpty || localPart.length > 64) return false;
    if (localPart.startsWith('.') || localPart.endsWith('.')) return false;
    if (localPart.contains('..')) return false;

    final pattern = allowInternational ? _localPartIntlPattern : _localPartPattern;
    return pattern.hasMatch(localPart);
  }

  bool _validateDomainPart(String domainPart) {
    if (domainPart.isEmpty || domainPart.length > 255) return false;

    final pattern = allowInternational ? _domainIntlPattern : _domainPattern;
    if (!pattern.hasMatch(domainPart)) return false;

    final labels = domainPart.split('.');
    if (!allowTopLevelDomain && labels.length < 2) return false;

    for (final label in labels) {
      if (label.isEmpty || label.length > 63) return false;
    }

    final tld = labels.last;
    if (!allowTopLevelDomain && (tld.length < 2 || RegExp(r'^[0-9]+$').hasMatch(tld))) {
      return false;
    }

    return true;
  }
}
