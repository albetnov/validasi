import 'package:validasi_annotation/src/base.dart';

class NonNegative<T extends num> extends Rule<T> {
  const NonNegative({super.message});
}
