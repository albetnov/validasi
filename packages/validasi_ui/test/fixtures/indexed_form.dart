import 'package:validasi/validasi.dart';
import 'package:validasi_annotation/validasi_annotation.dart';
import 'package:validasi_ui/validasi_ui.dart';

part 'indexed_form.validasi.dart';

@ValidateClass(generateIndexedFields: true)
class IndexedFormItem {
  const IndexedFormItem({required this.title, required this.quantity});

  @Validate<String>([Required(), MinLength(1)])
  final String title;

  @Validate<int>([
    OneOf<int>([1, 2, 3])
  ])
  final int quantity;
}

@ValidateClass()
class IndexedArrayForm {
  const IndexedArrayForm({
    required this.title,
    this.items = const <IndexedFormItem>[],
  });

  @Validate<String>([Required(), MinLength(1)])
  final String title;

  final List<IndexedFormItem> items;
}
