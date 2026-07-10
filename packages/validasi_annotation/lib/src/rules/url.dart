import 'package:validasi_annotation/src/base.dart';

class Url<T> extends Rule<T> {
  final bool requireScheme;
  final bool requireHost;
  final bool httpsOnly;
  const Url({
    this.requireScheme = true,
    this.requireHost = true,
    this.httpsOnly = false,
    super.message,
  });
}
