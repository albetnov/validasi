import 'package:flutter_test/flutter_test.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/validasi_ui.dart';

class _Item {
  const _Item({required this.title});

  final String title;
}

class _Form {
  const _Form({required this.title, required this.items});

  final String title;
  final List<_Item> items;
}

class _TitleField extends ValidasiField<_Form, String> {
  const _TitleField();

  @override
  String get name => 'title';

  @override
  String? extract(_Form owner) => owner.title;

  @override
  ValidasiResult<String> validate(String? value) =>
      ValidasiResult<String>.success(value);
}

class _ItemsField extends ValidasiField<_Form, List<_Item>> {
  const _ItemsField();

  @override
  String get name => 'items';

  @override
  List<_Item>? extract(_Form owner) => owner.items;

  @override
  ValidasiResult<List<_Item>> validate(List<_Item>? value) =>
      ValidasiResult<List<_Item>>.success(value);
}

const _titleField = _TitleField();
const _itemsField = _ItemsField();

class _FormSchema extends ValidasiSchema<_Form> {
  const _FormSchema();

  @override
  _Form allocate(ValidasiFieldReader<_Form> reader) {
    return _Form(
      title: reader.getValue(_titleField) as String,
      items: reader.getValue(_itemsField) ?? const <_Item>[],
    );
  }
}

ValidasiResult<String> _validateTitle(String? value) {
  if (value == null) {
    return ValidasiResult<String>.error(
      ValidationError(rule: 'Required', message: 'Title is required'),
    );
  }
  return ValidasiResult<String>.success(value);
}

List<ValidasiField<_Form, dynamic>> _indexedFields(int index) {
  return [
    IndexedField<_Form, String>(
      fieldName: 'title',
      parentPath: 'items',
      index: index,
      validate: _validateTitle,
      extractFromItem: (item) => (item as _Item).title,
    ),
  ];
}

_Item _reconstructItem(ValidasiFormController<_Form> ctrl, int index) {
  final titleField = ctrl.getArraySubField(_itemsField, index, 'title')!;
  return _Item(title: ctrl.getValue(titleField) as String);
}

List<_Item> _reconstructAll(ValidasiFormController<_Form> ctrl) {
  return List.generate(
    ctrl.getArrayItemCount(_itemsField),
    (index) => _reconstructItem(ctrl, index),
  );
}

void main() {
  test('schema allocation preserves reconstructed nested array values', () {
    final controller =
        ValidasiFormController<_Form>(schema: const _FormSchema());
    controller.setValue(_titleField, 'Form title');
    controller.appendArrayItem(
      _itemsField,
      const _Item(title: 'Before'),
      indexedFields: _indexedFields,
      reconstructItem: _reconstructItem,
      reconstructAll: _reconstructAll,
    );

    final titleField = controller.getArraySubField(_itemsField, 0, 'title')!;
    controller.setValue(titleField, 'After');

    final form = const _FormSchema().allocate(controller);

    expect(form.title, 'Form title');
    expect(form.items, hasLength(1));
    expect(form.items.single.title, 'After');
  });

  test('schema allocation uses an empty list for an uninitialized array', () {
    final controller =
        ValidasiFormController<_Form>(schema: const _FormSchema());
    controller.setValue(_titleField, 'Form title');

    final form = const _FormSchema().allocate(controller);

    expect(form.items, isEmpty);
  });
}
