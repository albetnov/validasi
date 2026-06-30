import 'package:validasi_annotation/validasi_annotation.dart';

@ValidateClass()
class NodeA {
  @Validate<String>([MinLength(2)])
  final String name;

  final NodeB child;

  const NodeA({required this.name, required this.child});
}

@ValidateClass()
class NodeB {
  @Validate<String>([MinLength(2)])
  final String label;

  final NodeA parent;

  const NodeB({required this.label, required this.parent});
}
