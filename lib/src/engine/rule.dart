import 'package:validasi/src/engine/context.dart';

abstract class Rule<T> {
  const Rule({this.message});

  final String? message;

  void apply(ValidationContext context);
}
