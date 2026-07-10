import 'package:validasi_annotation/src/base.dart';

class NonPositive<T extends num> extends Rule<T> {
  const NonPositive({super.message});
}
