import 'package:validasi_annotation/src/base.dart';

class Email<T> extends Rule<T> {
  final bool allowTopLevelDomain;
  final bool allowInternational;
  final List<String>? domains;
  const Email({
    this.allowTopLevelDomain = false,
    this.allowInternational = false,
    this.domains,
    super.message,
  });
}
