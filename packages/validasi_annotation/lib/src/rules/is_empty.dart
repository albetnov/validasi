import 'package:validasi_annotation/src/base.dart';

class IsEmpty<T> extends Rule<T> {
  const IsEmpty({super.message});
}

class IsNotEmpty<T> extends Rule<T> {
  const IsNotEmpty({super.message});
}
