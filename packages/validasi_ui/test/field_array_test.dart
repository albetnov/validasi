import 'package:flutter_test/flutter_test.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/validasi_ui.dart';

class _TestKey extends ValidasiField<String, List<String>> {
  const _TestKey() : super();

  @override
  String get name => 'emails';

  @override
  List<String>? extract(String owner) => null;

  @override
  ValidasiResult<List<String>> validate(List<String>? value) =>
      ValidasiResult.success(value as List<String>);
}

class _Person {
  final String name;
  final int age;
  const _Person({required this.name, required this.age});
}

class _NameField extends ValidasiField<_Person, String> {
  const _NameField();
  @override
  String get name => 'name';
  @override
  String? extract(_Person owner) => owner.name;
  @override
  ValidasiResult<String> validate(String? v) => v != null && v.length >= 2
      ? ValidasiResult.success(v)
      : ValidasiResult.error(
          ValidationError(rule: 'MinLength', message: 'Name too short'),
        );
}

class _AgeField extends ValidasiField<_Person, int> {
  const _AgeField();
  @override
  String get name => 'age';
  @override
  int? extract(_Person owner) => owner.age;
  @override
  ValidasiResult<int> validate(int? v) => v != null && v >= 0
      ? ValidasiResult.success(v)
      : ValidasiResult.error(
          ValidationError(rule: 'Min', message: 'Age must be >= 0'),
        );
}

const _nameField = _NameField();
const _ageField = _AgeField();

class _PersonListField extends ValidasiField<String, List<_Person>> {
  const _PersonListField() : super();
  @override
  String get name => 'people';
  @override
  List<_Person>? extract(String owner) => null;
  @override
  ValidasiResult<List<_Person>> validate(List<_Person>? value) =>
      ValidasiResult.success(value as List<_Person>);
}

List<ValidasiField<String, dynamic>> _indexedFields(int index) {
  return [
    IndexedField<String, String>(
      fieldName: _nameField.name,
      parentPath: 'people',
      index: index,
      validate: (v) => _nameField.validate(v),
      validateAsync: (v) => _nameField.validateAsync(v),
      extractFromItem: (item) => (item as _Person).name,
    ),
    IndexedField<String, int>(
      fieldName: _ageField.name,
      parentPath: 'people',
      index: index,
      validate: (v) => _ageField.validate(v),
      validateAsync: (v) => _ageField.validateAsync(v),
      extractFromItem: (item) => (item as _Person).age,
    ),
  ];
}

dynamic _reconstructItem(ValidasiFormController<String> ctrl, int index) {
  const field = _PersonListField();
  return _Person(
    name: ctrl.getValue(ctrl.getArraySubField(field, index, 'name')!),
    age: ctrl.getValue(ctrl.getArraySubField(field, index, 'age')!),
  );
}

List<dynamic> _reconstructAll(ValidasiFormController<String> ctrl) {
  const field = _PersonListField();
  final count = ctrl.getArrayItemCount(field);
  final result = <_Person>[];
  for (var i = 0; i < count; i++) {
    result.add(_reconstructItem(ctrl, i) as _Person);
  }
  return result;
}

const _emptyStringSchema = _EmptyStringSchema();

class _EmptyStringSchema extends ValidasiSchema<String> {
  const _EmptyStringSchema();
  @override
  String allocate(ValidasiFieldReader<String> reader) => '';
}

ValidasiFormController<String> _makeController() {
  return ValidasiFormController(schema: _emptyStringSchema);
}

void main() {
  group('field arrays', () {
    group('scalar', () {
      test('appendArrayItem adds an item', () {
        final controller = _makeController();
        const field = _TestKey();

        controller.appendArrayItem(field, 'a@example.com');
        expect(controller.getValue(field), ['a@example.com']);
      });

      test('appendArrayItem registers indexed sub-fields', () {
        final controller = _makeController();
        const field = _TestKey();

        controller.appendArrayItem(field, 'a@example.com');
        controller.appendArrayItem(field, 'b@example.com');

        final item0 = controller.getArrayItemField(field, 0)!;
        final item1 = controller.getArrayItemField(field, 1)!;
        expect(controller.getValue(item0), 'a@example.com');
        expect(controller.getValue(item1), 'b@example.com');
      });

      test('appendArrayItem multiple items builds correct list', () {
        final controller = _makeController();
        const field = _TestKey();

        controller.appendArrayItem(field, 'first');
        controller.appendArrayItem(field, 'second');
        controller.appendArrayItem(field, 'third');

        expect(controller.getValue(field), ['first', 'second', 'third']);
      });

      test('getValues excludes array item fields', () {
        final controller = _makeController();
        const field = _TestKey();

        controller.appendArrayItem(field, 'a@example.com');

        final values = controller.getValues();
        expect(values.containsKey(field), isTrue);
        expect(values.length, 1);
      });

      test('removeArrayItem removes an item', () {
        final controller = _makeController();
        const field = _TestKey();

        controller.appendArrayItem(field, 'a');
        controller.appendArrayItem(field, 'b');
        controller.appendArrayItem(field, 'c');
        expect(controller.getValue(field), ['a', 'b', 'c']);

        controller.removeArrayItem(field, 1);
        expect(controller.getValue(field), ['a', 'c']);
      });

      test('removeArrayItem re-indexes remaining items', () {
        final controller = _makeController();
        const field = _TestKey();

        controller.appendArrayItem(field, 'a');
        controller.appendArrayItem(field, 'b');
        controller.appendArrayItem(field, 'c');

        controller.removeArrayItem(field, 0);

        final item0 = controller.getArrayItemField(field, 0)!;
        final item1 = controller.getArrayItemField(field, 1)!;
        expect(controller.getValue(item0), 'b');
        expect(controller.getValue(item1), 'c');
      });

      test('removeArrayItem with invalid index does nothing', () {
        final controller = _makeController();
        const field = _TestKey();

        controller.appendArrayItem(field, 'a');
        controller.removeArrayItem(field, 5);
        expect(controller.getValue(field), ['a']);
      });

      test('swapArrayItems swaps two items', () {
        final controller = _makeController();
        const field = _TestKey();

        controller.appendArrayItem(field, 'a');
        controller.appendArrayItem(field, 'b');
        controller.appendArrayItem(field, 'c');

        controller.swapArrayItems(field, 0, 2);
        expect(controller.getValue(field), ['c', 'b', 'a']);
      });

      test('swapArrayItems re-indexes sub-field values', () {
        final controller = _makeController();
        const field = _TestKey();

        controller.appendArrayItem(field, 'a');
        controller.appendArrayItem(field, 'b');

        controller.swapArrayItems(field, 0, 1);

        final item0 = controller.getArrayItemField(field, 0)!;
        final item1 = controller.getArrayItemField(field, 1)!;
        expect(controller.getValue(item0), 'b');
        expect(controller.getValue(item1), 'a');
      });

      test('swapArrayItems with invalid indices does nothing', () {
        final controller = _makeController();
        const field = _TestKey();

        controller.appendArrayItem(field, 'a');
        controller.swapArrayItems(field, 0, 10);
        expect(controller.getValue(field), ['a']);
      });

      test('setValue on array item updates parent list', () {
        final controller = _makeController();
        const field = _TestKey();

        controller.appendArrayItem(field, 'a');
        controller.appendArrayItem(field, 'b');

        final item0 = controller.getArrayItemField(field, 0)!;
        controller.setValue(item0, 'changed');
        expect(controller.getValue(field), ['changed', 'b']);
      });

      test('setError on array item sets error for that item', () {
        final controller = _makeController();
        const field = _TestKey();

        controller.appendArrayItem(field, 'a');

        final item0 = controller.getArrayItemField(field, 0)!;
        controller.setError(item0, 'Item error');
        expect(controller.getErrors(item0).length, 1);
        expect(controller.getErrors(item0).first.message, 'Item error');
      });

      test('insertArrayItem inserts at specified index', () {
        final controller = _makeController();
        const field = _TestKey();

        controller.appendArrayItem(field, 'a');
        controller.appendArrayItem(field, 'c');
        controller.insertArrayItem(field, 1, 'b');

        expect(controller.getValue(field), ['a', 'b', 'c']);
      });

      test('insertArrayItem at end appends item', () {
        final controller = _makeController();
        const field = _TestKey();

        controller.appendArrayItem(field, 'a');
        controller.insertArrayItem(field, 1, 'b');

        expect(controller.getValue(field), ['a', 'b']);
      });

      test('insertArrayItem at start prepends item', () {
        final controller = _makeController();
        const field = _TestKey();

        controller.appendArrayItem(field, 'b');
        controller.insertArrayItem(field, 0, 'a');

        expect(controller.getValue(field), ['a', 'b']);
      });

      test('insertArrayItem re-indexes sub-fields', () {
        final controller = _makeController();
        const field = _TestKey();

        controller.appendArrayItem(field, 'a');
        controller.appendArrayItem(field, 'c');
        controller.insertArrayItem(field, 1, 'b');

        final item0 = controller.getArrayItemField(field, 0)!;
        final item1 = controller.getArrayItemField(field, 1)!;
        final item2 = controller.getArrayItemField(field, 2)!;
        expect(controller.getValue(item0), 'a');
        expect(controller.getValue(item1), 'b');
        expect(controller.getValue(item2), 'c');
      });

      test('insertArrayItem with invalid index does nothing', () {
        final controller = _makeController();
        const field = _TestKey();

        controller.appendArrayItem(field, 'a');
        controller.insertArrayItem(field, 5, 'b');
        expect(controller.getValue(field), ['a']);
      });

      test('insertArrayItem with negative index does nothing', () {
        final controller = _makeController();
        const field = _TestKey();

        controller.appendArrayItem(field, 'a');
        controller.insertArrayItem(field, -1, 'b');
        expect(controller.getValue(field), ['a']);
      });

      test('append after remove keeps correct structure', () {
        final controller = _makeController();
        const field = _TestKey();

        controller.appendArrayItem(field, 'a');
        controller.appendArrayItem(field, 'b');
        controller.appendArrayItem(field, 'c');

        controller.removeArrayItem(field, 1);
        controller.appendArrayItem(field, 'd');

        expect(controller.getValue(field), ['a', 'c', 'd']);

        final item0 = controller.getArrayItemField(field, 0)!;
        final item1 = controller.getArrayItemField(field, 1)!;
        final item2 = controller.getArrayItemField(field, 2)!;
        expect(controller.getValue(item0), 'a');
        expect(controller.getValue(item1), 'c');
        expect(controller.getValue(item2), 'd');
      });
    });

    group('object', () {
      test('appendArrayItem with indexedFields registers sub-fields', () {
        final controller = _makeController();
        const field = _PersonListField();

        controller.appendArrayItem(
          field,
          const _Person(name: 'Alice', age: 30),
          indexedFields: _indexedFields,
          reconstructItem: _reconstructItem,
          reconstructAll: _reconstructAll,
        );

        expect(controller.getValue(field), hasLength(1));
        expect(controller.getValue(field)![0].name, 'Alice');

        final nameField = controller.getArraySubField(field, 0, 'name')!;
        expect(controller.getValue(nameField), 'Alice');
      });

      test('appendArrayItem sets initial values from object', () {
        final controller = _makeController();
        const field = _PersonListField();

        controller.appendArrayItem(
          field,
          const _Person(name: 'Bob', age: 25),
          indexedFields: _indexedFields,
          reconstructItem: _reconstructItem,
          reconstructAll: _reconstructAll,
        );

        final nameField = controller.getArraySubField(field, 0, 'name')!;
        final ageField = controller.getArraySubField(field, 0, 'age')!;
        expect(controller.getValue(nameField), 'Bob');
        expect(controller.getValue(ageField), 25);
      });

      test('setValue on indexed sub-field stores value', () {
        final controller = _makeController();
        const field = _PersonListField();

        controller.appendArrayItem(
          field,
          const _Person(name: 'Alice', age: 30),
          indexedFields: _indexedFields,
          reconstructItem: _reconstructItem,
          reconstructAll: _reconstructAll,
        );

        final nameField = controller.getArraySubField(field, 0, 'name')!;
        controller.setValue(nameField, 'Updated');

        expect(controller.getValue(nameField), 'Updated');
      });

      test('getValue reconstructs parent list from sub-fields', () {
        final controller = _makeController();
        const field = _PersonListField();

        controller.appendArrayItem(
          field,
          const _Person(name: 'Alice', age: 30),
          indexedFields: _indexedFields,
          reconstructItem: _reconstructItem,
          reconstructAll: _reconstructAll,
        );

        final nameField = controller.getArraySubField(field, 0, 'name')!;
        controller.setValue(nameField, 'Updated');

        final list = controller.getValue(field)!;
        expect(list[0].name, 'Updated');
        expect(list[0].age, 30);
      });

      test('getValues excludes indexed sub-fields', () {
        final controller = _makeController();
        const field = _PersonListField();

        controller.appendArrayItem(
          field,
          const _Person(name: 'Alice', age: 30),
          indexedFields: _indexedFields,
          reconstructItem: _reconstructItem,
          reconstructAll: _reconstructAll,
        );

        final values = controller.getValues();
        expect(values.containsKey(field), isTrue);
        expect(values.length, 1);
      });

      test('removeArrayItem cleans up indexed sub-fields', () {
        final controller = _makeController();
        const field = _PersonListField();

        controller.appendArrayItem(
          field,
          const _Person(name: 'Alice', age: 30),
          indexedFields: _indexedFields,
          reconstructItem: _reconstructItem,
          reconstructAll: _reconstructAll,
        );
        controller.appendArrayItem(
          field,
          const _Person(name: 'Bob', age: 25),
          indexedFields: _indexedFields,
          reconstructItem: _reconstructItem,
          reconstructAll: _reconstructAll,
        );

        controller.removeArrayItem(field, 0);

        expect(controller.getValue(field), hasLength(1));
        expect(controller.getValue(field)![0].name, 'Bob');

        final nameField = controller.getArraySubField(field, 0, 'name')!;
        expect(controller.getValue(nameField), 'Bob');
      });

      test('swapArrayItems re-indexes sub-field values', () {
        final controller = _makeController();
        const field = _PersonListField();

        controller.appendArrayItem(
          field,
          const _Person(name: 'Alice', age: 30),
          indexedFields: _indexedFields,
          reconstructItem: _reconstructItem,
          reconstructAll: _reconstructAll,
        );
        controller.appendArrayItem(
          field,
          const _Person(name: 'Bob', age: 25),
          indexedFields: _indexedFields,
          reconstructItem: _reconstructItem,
          reconstructAll: _reconstructAll,
        );

        controller.swapArrayItems(field, 0, 1);

        expect(controller.getValue(field)![0].name, 'Bob');
        expect(controller.getValue(field)![1].name, 'Alice');
      });

      test('insertArrayItem inserts and re-indexes', () {
        final controller = _makeController();
        const field = _PersonListField();

        controller.appendArrayItem(
          field,
          const _Person(name: 'Alice', age: 30),
          indexedFields: _indexedFields,
          reconstructItem: _reconstructItem,
          reconstructAll: _reconstructAll,
        );
        controller.appendArrayItem(
          field,
          const _Person(name: 'Charlie', age: 35),
          indexedFields: _indexedFields,
          reconstructItem: _reconstructItem,
          reconstructAll: _reconstructAll,
        );

        controller.insertArrayItem(
          field,
          1,
          const _Person(name: 'Bob', age: 25),
          indexedFields: _indexedFields,
          reconstructItem: _reconstructItem,
          reconstructAll: _reconstructAll,
        );

        expect(controller.getValue(field), hasLength(3));
        expect(controller.getValue(field)![0].name, 'Alice');
        expect(controller.getValue(field)![1].name, 'Bob');
        expect(controller.getValue(field)![2].name, 'Charlie');
      });

      test('validate on indexed field validates correctly', () {
        final controller = _makeController();
        const field = _PersonListField();

        controller.appendArrayItem(
          field,
          const _Person(name: 'A', age: -1),
          indexedFields: _indexedFields,
          reconstructItem: _reconstructItem,
          reconstructAll: _reconstructAll,
        );

        final nameField = controller.getArraySubField(field, 0, 'name')!;
        final ageField = controller.getArraySubField(field, 0, 'age')!;

        controller.validateField(nameField);
        controller.validateField(ageField);

        expect(controller.getErrors(nameField), isNotEmpty);
        expect(controller.getErrors(ageField), isNotEmpty);
      });

      test('reset restores initial sub-field values', () {
        final controller = _makeController();
        const field = _PersonListField();

        controller.appendArrayItem(
          field,
          const _Person(name: 'Alice', age: 30),
          indexedFields: _indexedFields,
          reconstructItem: _reconstructItem,
          reconstructAll: _reconstructAll,
        );

        final nameField = controller.getArraySubField(field, 0, 'name')!;
        controller.setValue(nameField, 'Changed');

        controller.reset();

        expect(controller.getValue(nameField), 'Alice');
      });
    });
  });
}
