import 'package:validasi_annotation/validasi_annotation.dart';

@ValidateClass(generateIndexedFields: true)
class Item {
  @Validate<String>([])
  final String title;

  const Item({required this.title});
}

@ValidateClass(generateSchema: true)
class Form {
  @Validate<String>([])
  final String title;

  final List<Item> items;

  const Form({required this.title, this.items = const <Item>[]});
}
