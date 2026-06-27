import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/validasi_ui.dart';

class _Person {
  final String name;
  final int age;
  const _Person({required this.name, required this.age});
}

class _PersonListField extends ValidasiField<String, List<_Person>> {
  const _PersonListField();
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
      fieldName: 'name',
      parentPath: 'people',
      index: index,
      validate: (v) => v != null && v.length >= 2
          ? ValidasiResult.success(v)
          : ValidasiResult.error(
              ValidationError(rule: 'MinLength', message: 'Name too short'),
            ),
      validateAsync: (v) async => v != null && v.length >= 2
          ? ValidasiResult.success(v)
          : ValidasiResult.error(
              ValidationError(rule: 'MinLength', message: 'Name too short'),
            ),
      extractFromItem: (item) => (item as _Person).name,
    ),
    IndexedField<String, int>(
      fieldName: 'age',
      parentPath: 'people',
      index: index,
      validate: (v) => v != null && v >= 0
          ? ValidasiResult.success(v)
          : ValidasiResult.error(
              ValidationError(rule: 'Min', message: 'Age must be >= 0'),
            ),
      validateAsync: (v) async => v != null && v >= 0
          ? ValidasiResult.success(v)
          : ValidasiResult.error(
              ValidationError(rule: 'Min', message: 'Age must be >= 0'),
            ),
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
  return ValidasiFormController<String>(schema: _emptyStringSchema);
}

ValidasiFormController<String> _makeControllerWith(int count) {
  final ctrl = _makeController();
  const field = _PersonListField();
  for (var i = 0; i < count; i++) {
    ctrl.appendArrayItem(
      field,
      _Person(name: 'Person $i', age: 20 + i),
      indexedFields: _indexedFields,
      reconstructItem: _reconstructItem,
      reconstructAll: _reconstructAll,
    );
  }
  return ctrl;
}

void main() {
  group('swap state migration', () {
    test('C1: touched swaps with value', () {
      final ctrl = _makeControllerWith(5);
      const field = _PersonListField();

      final slot0Name = ctrl.getArraySubField(field, 0, 'name')!;
      final slot4Name = ctrl.getArraySubField(field, 4, 'name')!;
      ctrl.getFieldController(slot0Name).markTouched();

      ctrl.swapArrayItems(field, 0, 4);

      expect(ctrl.getFieldController(slot0Name).touched, isFalse);
      expect(ctrl.getFieldController(slot4Name).touched, isTrue);
    });

    test('C2: dirty swaps with value', () {
      final ctrl = _makeControllerWith(5);
      const field = _PersonListField();

      final slot0Name = ctrl.getArraySubField(field, 0, 'name')!;
      final slot4Name = ctrl.getArraySubField(field, 4, 'name')!;
      ctrl.setValue(slot0Name, 'Edited');

      ctrl.swapArrayItems(field, 0, 4);

      final fc0 = ctrl.getFieldController(slot0Name);
      final fc4 = ctrl.getFieldController(slot4Name);
      expect(fc0.isDirty.value, isFalse);
      expect(fc4.isDirty.value, isTrue);
    });

    test('C3: sync errors swap', () {
      final ctrl = _makeControllerWith(5);
      const field = _PersonListField();

      final slot0Name = ctrl.getArraySubField(field, 0, 'name')!;
      final slot4Name = ctrl.getArraySubField(field, 4, 'name')!;
      ctrl.setError(slot0Name, 'Error X');
      ctrl.setError(slot4Name, 'Error Y');

      ctrl.swapArrayItems(field, 0, 4);

      expect(ctrl.getErrors(slot0Name).first.message, 'Error Y');
      expect(ctrl.getErrors(slot4Name).first.message, 'Error X');
    });

    test('C4: completed async errors swap', () {
      final ctrl = _makeControllerWith(5);
      const field = _PersonListField();

      final slot0Name = ctrl.getArraySubField(field, 0, 'name')!;
      final slot4Name = ctrl.getArraySubField(field, 4, 'name')!;
      ctrl.getFieldController(slot0Name).setAsyncError('invalid X');
      ctrl.getFieldController(slot4Name).setAsyncError('invalid Y');

      ctrl.swapArrayItems(field, 0, 4);

      expect(
        ctrl.getFieldController(slot0Name).errors.first.message,
        'invalid Y',
      );
      expect(
        ctrl.getFieldController(slot4Name).errors.first.message,
        'invalid X',
      );
    });

    test('C5: in-flight async cancelled on both slots, no re-trigger',
        () async {
      final ctrl = _makeControllerWith(5);
      const field = _PersonListField();

      final slot0Name = ctrl.getArraySubField(field, 0, 'name')!;
      final slot1Name = ctrl.getArraySubField(field, 1, 'name')!;

      final completer0 = Completer<String?>();
      final completer1 = Completer<String?>();

      ctrl.setFieldValidator(
        slot0Name,
        (v) async => completer0.isCompleted ? null : completer0.future,
        debounce: Duration.zero,
      );
      ctrl.setFieldValidator(
        slot1Name,
        (v) async => completer1.isCompleted ? null : completer1.future,
        debounce: Duration.zero,
      );

      ctrl.setValue(slot0Name, 'Test0');
      ctrl.setValue(slot1Name, 'Test1');

      await ctrl.triggerAsyncValidation(slot0Name);
      await ctrl.triggerAsyncValidation(slot1Name);
      await Future<void>.delayed(Duration.zero);

      expect(ctrl.getFieldController(slot0Name).isValidating, isTrue);
      expect(ctrl.getFieldController(slot1Name).isValidating, isTrue);

      ctrl.swapArrayItems(field, 0, 1);

      expect(ctrl.getFieldController(slot0Name).isValidating, isFalse);
      expect(ctrl.getFieldController(slot1Name).isValidating, isFalse);

      completer0.complete('invalid');
      completer1.complete('invalid');
      await Future<void>.delayed(Duration.zero);

      expect(ctrl.getFieldController(slot0Name).isValidating, isFalse);
      expect(ctrl.getFieldController(slot1Name).isValidating, isFalse);
    });

    test('C6: debounce-pending cancelled on swap', () async {
      final ctrl = _makeControllerWith(5);
      const field = _PersonListField();

      final slot0Name = ctrl.getArraySubField(field, 0, 'name')!;
      final slot1Name = ctrl.getArraySubField(field, 1, 'name')!;

      ctrl.setFieldValidator(
        slot0Name,
        (v) async => 'invalid',
        debounce: const Duration(milliseconds: 5),
      );
      ctrl.setFieldValidator(
        slot1Name,
        (v) async => 'invalid',
        debounce: const Duration(milliseconds: 5),
      );

      ctrl.setValue(slot0Name, 'Test0');
      ctrl.setValue(slot1Name, 'Test1');
      await Future<void>.delayed(const Duration(milliseconds: 2));

      ctrl.swapArrayItems(field, 0, 1);

      expect(ctrl.getFieldController(slot0Name).isValidating, isFalse);
      expect(ctrl.getFieldController(slot1Name).isValidating, isFalse);
    });

    test('C7: disabled swaps', () {
      final ctrl = _makeControllerWith(5);
      const field = _PersonListField();

      final slot0Name = ctrl.getArraySubField(field, 0, 'name')!;
      final slot4Name = ctrl.getArraySubField(field, 4, 'name')!;
      ctrl.setFieldDisabled(slot0Name, true);

      ctrl.swapArrayItems(field, 0, 4);

      expect(ctrl.getFieldController(slot0Name).disabled, isFalse);
      expect(ctrl.getFieldController(slot4Name).disabled, isTrue);
    });

    test('C8: baseline swap has no spurious state', () {
      final ctrl = _makeControllerWith(5);
      const field = _PersonListField();

      ctrl.swapArrayItems(field, 0, 4);

      expect(ctrl.getValue(field)![0].name, 'Person 4');
      expect(ctrl.getValue(field)![4].name, 'Person 0');
      for (var i = 0; i < 5; i++) {
        final fc = ctrl.getFieldController(
          ctrl.getArraySubField(field, i, 'name')!,
        );
        expect(fc.touched, isFalse);
        expect(fc.isDirty.value, isFalse);
        expect(fc.errors, isEmpty);
      }
    });

    test('C9: composite state swap (6 attributes bidirectional)', () {
      final ctrl = _makeControllerWith(5);
      const field = _PersonListField();

      final slot0Name = ctrl.getArraySubField(field, 0, 'name')!;
      final slot4Name = ctrl.getArraySubField(field, 4, 'name')!;

      ctrl.getFieldController(slot0Name).markTouched();
      ctrl.getFieldController(slot0Name).disabled = true;
      ctrl.getFieldController(slot0Name).updateErrors([
        FieldValidationError(ValidationError(rule: 'Custom', message: 'err0')),
      ]);

      ctrl.getFieldController(slot4Name).markTouched();
      ctrl.setValue(slot4Name, 'Edited');
      ctrl.getFieldController(slot4Name).setAsyncError('async4');

      ctrl.swapArrayItems(field, 0, 4);

      final fc0 = ctrl.getFieldController(slot0Name);
      final fc4 = ctrl.getFieldController(slot4Name);

      expect(fc0.touched, isTrue);
      expect(fc0.disabled, isFalse);
      expect(fc0.errors.first.message, 'async4');
      expect(fc0.isDirty.value, isTrue);

      expect(fc4.touched, isTrue);
      expect(fc4.disabled, isTrue);
      expect(fc4.errors.first.message, 'err0');
      expect(fc4.isDirty.value, isFalse);
    });

    test('C10: swap(i, i) is a no-op', () {
      final ctrl = _makeControllerWith(5);
      const field = _PersonListField();

      final slot2Name = ctrl.getArraySubField(field, 2, 'name')!;
      ctrl.getFieldController(slot2Name).markTouched();
      ctrl.setError(slot2Name, 'err');

      ctrl.swapArrayItems(field, 2, 2);

      expect(ctrl.getFieldController(slot2Name).touched, isTrue);
      expect(ctrl.getErrors(slot2Name).first.message, 'err');
    });

    test('C11: double-swap returns to original state', () {
      final ctrl = _makeControllerWith(5);
      const field = _PersonListField();

      final slot0Name = ctrl.getArraySubField(field, 0, 'name')!;
      final slot4Name = ctrl.getArraySubField(field, 4, 'name')!;

      ctrl.getFieldController(slot0Name).markTouched();
      ctrl.setError(slot4Name, 'err4');

      ctrl.swapArrayItems(field, 0, 4);
      ctrl.swapArrayItems(field, 0, 4);

      expect(ctrl.getFieldController(slot0Name).touched, isTrue);
      expect(ctrl.getFieldController(slot0Name).errors, isEmpty);
      expect(ctrl.getFieldController(slot4Name).touched, isFalse);
      expect(ctrl.getErrors(slot4Name).first.message, 'err4');
    });
  });

  group('remove state migration', () {
    test('A1: touched preservation', () {
      final ctrl = _makeControllerWith(5);
      const field = _PersonListField();

      final slot1Name = ctrl.getArraySubField(field, 1, 'name')!;
      final slot0Name = ctrl.getArraySubField(field, 0, 'name')!;
      ctrl.getFieldController(slot1Name).markTouched();

      ctrl.removeArrayItem(field, 0);

      expect(ctrl.getFieldController(slot0Name).touched, isTrue);
    });

    test('A2: dirty preservation', () {
      final ctrl = _makeControllerWith(5);
      const field = _PersonListField();

      final slot1Name = ctrl.getArraySubField(field, 1, 'name')!;
      ctrl.setValue(slot1Name, 'Edited');

      ctrl.removeArrayItem(field, 0);

      final slot0Name = ctrl.getArraySubField(field, 0, 'name')!;
      final fc = ctrl.getFieldController(slot0Name);
      expect(fc.isDirty.value, isTrue);
      expect(fc.value, 'Edited');
    });

    test('A3: sync error preservation', () {
      final ctrl = _makeControllerWith(5);
      const field = _PersonListField();

      final slot1Name = ctrl.getArraySubField(field, 1, 'name')!;
      ctrl.setError(slot1Name, 'bad');

      ctrl.removeArrayItem(field, 0);

      final slot0Name = ctrl.getArraySubField(field, 0, 'name')!;
      expect(ctrl.getErrors(slot0Name).first.message, 'bad');
    });

    test('A4: completed async error preservation', () {
      final ctrl = _makeControllerWith(5);
      const field = _PersonListField();

      final slot1Name = ctrl.getArraySubField(field, 1, 'name')!;
      ctrl.getFieldController(slot1Name).setAsyncError('invalid');

      ctrl.removeArrayItem(field, 0);

      final slot0Name = ctrl.getArraySubField(field, 0, 'name')!;
      expect(
        ctrl.getFieldController(slot0Name).errors.first.message,
        'invalid',
      );
    });

    test('A8: baseline (no spurious state)', () {
      final ctrl = _makeControllerWith(5);
      const field = _PersonListField();

      ctrl.removeArrayItem(field, 0);

      expect(ctrl.getValue(field)![0].name, 'Person 1');
      expect(ctrl.getValue(field)!.length, 4);
      for (var i = 0; i < 4; i++) {
        final fc = ctrl.getFieldController(
          ctrl.getArraySubField(field, i, 'name')!,
        );
        expect(fc.touched, isFalse);
        expect(fc.isDirty.value, isFalse);
        expect(fc.errors, isEmpty);
      }
    });

    test('A9: multi-slot touched cascade', () {
      final ctrl = _makeControllerWith(5);
      const field = _PersonListField();

      for (var i = 1; i <= 4; i++) {
        ctrl
            .getFieldController(
              ctrl.getArraySubField(field, i, 'name')!,
            )
            .markTouched();
      }

      ctrl.removeArrayItem(field, 0);

      for (var i = 0; i < 4; i++) {
        expect(
          ctrl
              .getFieldController(
                ctrl.getArraySubField(field, i, 'name')!,
              )
              .touched,
          isTrue,
        );
      }
    });

    test('A12: remove the in-flight slot itself', () async {
      final ctrl = _makeControllerWith(5);
      const field = _PersonListField();

      final slot2Name = ctrl.getArraySubField(field, 2, 'name')!;
      final completer = Completer<String?>();

      ctrl.setFieldValidator(
        slot2Name,
        (v) async => completer.future,
        debounce: Duration.zero,
      );
      ctrl.setValue(slot2Name, 'Test');
      await ctrl.triggerAsyncValidation(slot2Name);
      await Future<void>.delayed(Duration.zero);

      expect(ctrl.getFieldController(slot2Name).isValidating, isTrue);

      ctrl.removeArrayItem(field, 2);

      expect(ctrl.getFieldController(slot2Name).isValidating, isFalse);
      completer.complete(null);
    });
  });

  group('insert state migration', () {
    test('B1: touched shift-up', () {
      final ctrl = _makeControllerWith(4);
      const field = _PersonListField();

      final slot1Name = ctrl.getArraySubField(field, 1, 'name')!;
      ctrl.getFieldController(slot1Name).markTouched();

      ctrl.insertArrayItem(field, 0, const _Person(name: 'New', age: 25),
          indexedFields: _indexedFields,
          reconstructItem: _reconstructItem,
          reconstructAll: _reconstructAll);

      final slot2Name = ctrl.getArraySubField(field, 2, 'name')!;
      expect(ctrl.getFieldController(slot2Name).touched, isTrue);
    });

    test('B3: sync error shift-up', () {
      final ctrl = _makeControllerWith(4);
      const field = _PersonListField();

      final slot1Name = ctrl.getArraySubField(field, 1, 'name')!;
      ctrl.setError(slot1Name, 'bad');

      ctrl.insertArrayItem(field, 0, const _Person(name: 'New', age: 25),
          indexedFields: _indexedFields,
          reconstructItem: _reconstructItem,
          reconstructAll: _reconstructAll);

      final slot2Name = ctrl.getArraySubField(field, 2, 'name')!;
      expect(ctrl.getErrors(slot2Name).first.message, 'bad');
    });

    test('B8: baseline + new slot pristine', () {
      final ctrl = _makeControllerWith(3);
      const field = _PersonListField();

      ctrl.insertArrayItem(field, 1, const _Person(name: 'New', age: 25),
          indexedFields: _indexedFields,
          reconstructItem: _reconstructItem,
          reconstructAll: _reconstructAll);

      expect(ctrl.getValue(field)!.length, 4);
      expect(ctrl.getValue(field)![1].name, 'New');

      final slot1Name = ctrl.getArraySubField(field, 1, 'name')!;
      final fc = ctrl.getFieldController(slot1Name);
      expect(fc.touched, isFalse);
      expect(fc.isDirty.value, isFalse);
      expect(fc.errors, isEmpty);
    });
  });

  group('append state preservation', () {
    test('D1: append does not disturb existing state', () {
      final ctrl = _makeControllerWith(3);
      const field = _PersonListField();

      final slot1Name = ctrl.getArraySubField(field, 1, 'name')!;
      ctrl.getFieldController(slot1Name).markTouched();
      ctrl.setError(slot1Name, 'bad');

      ctrl.appendArrayItem(field, const _Person(name: 'New', age: 25),
          indexedFields: _indexedFields,
          reconstructItem: _reconstructItem,
          reconstructAll: _reconstructAll);

      expect(ctrl.getFieldController(slot1Name).touched, isTrue);
      expect(ctrl.getErrors(slot1Name).first.message, 'bad');
      expect(ctrl.getValue(field)!.length, 4);
    });

    test('D2: append does not cancel in-flight async', () async {
      final ctrl = _makeControllerWith(3);
      const field = _PersonListField();

      final slot1Name = ctrl.getArraySubField(field, 1, 'name')!;
      final completer = Completer<String?>();

      ctrl.setFieldValidator(
        slot1Name,
        (v) async => completer.future,
        debounce: Duration.zero,
      );
      ctrl.setValue(slot1Name, 'Test');
      await ctrl.triggerAsyncValidation(slot1Name);
      await Future<void>.delayed(Duration.zero);

      expect(ctrl.getFieldController(slot1Name).isValidating, isTrue);

      ctrl.appendArrayItem(field, const _Person(name: 'New', age: 25),
          indexedFields: _indexedFields,
          reconstructItem: _reconstructItem,
          reconstructAll: _reconstructAll);

      expect(ctrl.getFieldController(slot1Name).isValidating, isTrue);
      completer.complete(null);
    });
  });

  group('compound scenarios', () {
    test('E4: rapid removes with in-flight async', () async {
      final ctrl = _makeControllerWith(5);
      const field = _PersonListField();

      final slot4Name = ctrl.getArraySubField(field, 4, 'name')!;
      ctrl.getFieldController(slot4Name).markTouched();

      for (var i = 0; i < 4; i++) {
        ctrl.removeArrayItem(field, 0);
      }

      expect(ctrl.getValue(field)!.length, 1);
      final slot0Name = ctrl.getArraySubField(field, 0, 'name')!;
      expect(ctrl.getFieldController(slot0Name).touched, isTrue);
      expect(ctrl.getValue(field)![0].name, 'Person 4');
    });

    test('E5: remove with in-flight then dispose', () async {
      final ctrl = _makeControllerWith(5);
      const field = _PersonListField();

      final slot1Name = ctrl.getArraySubField(field, 1, 'name')!;
      final completer = Completer<String?>();

      ctrl.setFieldValidator(
        slot1Name,
        (v) async => completer.future,
        debounce: Duration.zero,
      );
      ctrl.setValue(slot1Name, 'Test');
      await ctrl.triggerAsyncValidation(slot1Name);
      await Future<void>.delayed(Duration.zero);

      ctrl.removeArrayItem(field, 0);

      completer.complete('invalid');
      await Future<void>.delayed(Duration.zero);

      ctrl.dispose();
    });
  });

  group('remove async re-trigger', () {
    test('A5: in-flight async re-triggers on migrated slot', () async {
      final ctrl = _makeControllerWith(5);
      const field = _PersonListField();

      final slot1Name = ctrl.getArraySubField(field, 1, 'name')!;
      final completer = Completer<String?>();

      ctrl.setFieldValidator(
        slot1Name,
        (v) async => completer.future,
        debounce: Duration.zero,
      );
      ctrl.setValue(slot1Name, 'Test');
      await ctrl.triggerAsyncValidation(slot1Name);
      await Future<void>.delayed(Duration.zero);

      ctrl.removeArrayItem(field, 0);

      final slot0Name = ctrl.getArraySubField(field, 0, 'name')!;
      final fc0 = ctrl.getFieldController(slot0Name);
      expect(fc0.value, 'Test');

      completer.complete('invalid');
      await Future<void>.delayed(Duration.zero);

      expect(fc0.errors.first.message, 'invalid');
    });

    test('A7: disabled preservation on remove', () {
      final ctrl = _makeControllerWith(5);
      const field = _PersonListField();

      final slot1Name = ctrl.getArraySubField(field, 1, 'name')!;
      ctrl.setFieldDisabled(slot1Name, true);

      ctrl.removeArrayItem(field, 0);

      final slot0Name = ctrl.getArraySubField(field, 0, 'name')!;
      expect(ctrl.getFieldController(slot0Name).disabled, isTrue);
    });

    test('A10: multi-slot sync error cascade', () {
      final ctrl = _makeControllerWith(5);
      const field = _PersonListField();

      ctrl.setError(ctrl.getArraySubField(field, 1, 'name')!, 'err1');
      ctrl.setError(ctrl.getArraySubField(field, 2, 'name')!, 'err2');
      ctrl.setError(ctrl.getArraySubField(field, 3, 'name')!, 'err3');

      ctrl.removeArrayItem(field, 0);

      expect(
          ctrl
              .getErrors(ctrl.getArraySubField(field, 0, 'name')!)
              .first
              .message,
          'err1');
      expect(
          ctrl
              .getErrors(ctrl.getArraySubField(field, 1, 'name')!)
              .first
              .message,
          'err2');
      expect(
          ctrl
              .getErrors(ctrl.getArraySubField(field, 2, 'name')!)
              .first
              .message,
          'err3');
    });

    test('A11: concurrent in-flight on 2 slots', () async {
      final ctrl = _makeControllerWith(5);
      const field = _PersonListField();

      final slot1Name = ctrl.getArraySubField(field, 1, 'name')!;
      final slot2Name = ctrl.getArraySubField(field, 2, 'name')!;
      final c1 = Completer<String?>();
      final c2 = Completer<String?>();

      ctrl.setFieldValidator(slot1Name, (v) async => c1.future,
          debounce: Duration.zero);
      ctrl.setFieldValidator(slot2Name, (v) async => c2.future,
          debounce: Duration.zero);
      ctrl.setValue(slot1Name, 'T1');
      ctrl.setValue(slot2Name, 'T2');
      await ctrl.triggerAsyncValidation(slot1Name);
      await ctrl.triggerAsyncValidation(slot2Name);
      await Future<void>.delayed(Duration.zero);

      ctrl.removeArrayItem(field, 0);

      final slot0Name = ctrl.getArraySubField(field, 0, 'name')!;
      final slot1After = ctrl.getArraySubField(field, 1, 'name')!;
      expect(ctrl.getFieldController(slot0Name).value, 'T1');
      expect(ctrl.getFieldController(slot1After).value, 'T2');

      c1.complete('err1');
      c2.complete('err2');
      await Future<void>.delayed(Duration.zero);

      expect(ctrl.getErrors(slot0Name).first.message, 'err1');
      expect(ctrl.getErrors(slot1After).first.message, 'err2');
    });
  });

  group('insert additional tests', () {
    test('B2: dirty shift-up', () {
      final ctrl = _makeControllerWith(4);
      const field = _PersonListField();

      final slot1Name = ctrl.getArraySubField(field, 1, 'name')!;
      ctrl.setValue(slot1Name, 'Edited');

      ctrl.insertArrayItem(field, 0, const _Person(name: 'New', age: 25),
          indexedFields: _indexedFields,
          reconstructItem: _reconstructItem,
          reconstructAll: _reconstructAll);

      final slot2Name = ctrl.getArraySubField(field, 2, 'name')!;
      final fc = ctrl.getFieldController(slot2Name);
      expect(fc.isDirty.value, isTrue);
      expect(fc.value, 'Edited');
    });

    test('B4: completed async error shift-up', () {
      final ctrl = _makeControllerWith(4);
      const field = _PersonListField();

      final slot1Name = ctrl.getArraySubField(field, 1, 'name')!;
      ctrl.getFieldController(slot1Name).setAsyncError('invalid');

      ctrl.insertArrayItem(field, 0, const _Person(name: 'New', age: 25),
          indexedFields: _indexedFields,
          reconstructItem: _reconstructItem,
          reconstructAll: _reconstructAll);

      final slot2Name = ctrl.getArraySubField(field, 2, 'name')!;
      expect(
          ctrl.getFieldController(slot2Name).errors.first.message, 'invalid');
    });

    test('B5: in-flight async re-triggers on shifted slot', () async {
      final ctrl = _makeControllerWith(4);
      const field = _PersonListField();

      final slot1Name = ctrl.getArraySubField(field, 1, 'name')!;
      final completer = Completer<String?>();

      ctrl.setFieldValidator(slot1Name, (v) async => completer.future,
          debounce: Duration.zero);
      ctrl.setValue(slot1Name, 'Test');
      await ctrl.triggerAsyncValidation(slot1Name);
      await Future<void>.delayed(Duration.zero);

      ctrl.insertArrayItem(field, 0, const _Person(name: 'New', age: 25),
          indexedFields: _indexedFields,
          reconstructItem: _reconstructItem,
          reconstructAll: _reconstructAll);

      final slot2Name = ctrl.getArraySubField(field, 2, 'name')!;
      expect(ctrl.getFieldController(slot2Name).value, 'Test');

      completer.complete('invalid');
      await Future<void>.delayed(Duration.zero);
      expect(ctrl.getErrors(slot2Name).first.message, 'invalid');
    });

    test('B7: disabled shift-up', () {
      final ctrl = _makeControllerWith(4);
      const field = _PersonListField();

      final slot1Name = ctrl.getArraySubField(field, 1, 'name')!;
      ctrl.setFieldDisabled(slot1Name, true);

      ctrl.insertArrayItem(field, 0, const _Person(name: 'New', age: 25),
          indexedFields: _indexedFields,
          reconstructItem: _reconstructItem,
          reconstructAll: _reconstructAll);

      final slot2Name = ctrl.getArraySubField(field, 2, 'name')!;
      expect(ctrl.getFieldController(slot2Name).disabled, isTrue);
    });

    test('B9: multi-slot touched shift-up', () {
      final ctrl = _makeControllerWith(4);
      const field = _PersonListField();

      for (var i = 1; i <= 3; i++) {
        ctrl
            .getFieldController(ctrl.getArraySubField(field, i, 'name')!)
            .markTouched();
      }

      ctrl.insertArrayItem(field, 0, const _Person(name: 'New', age: 25),
          indexedFields: _indexedFields,
          reconstructItem: _reconstructItem,
          reconstructAll: _reconstructAll);

      for (var i = 1; i <= 3; i++) {
        expect(
            ctrl
                .getFieldController(
                    ctrl.getArraySubField(field, i + 1, 'name')!)
                .touched,
            isTrue);
      }
    });

    test('B10: multi-slot sync error shift-up', () {
      final ctrl = _makeControllerWith(4);
      const field = _PersonListField();

      ctrl.setError(ctrl.getArraySubField(field, 1, 'name')!, 'err1');
      ctrl.setError(ctrl.getArraySubField(field, 2, 'name')!, 'err2');
      ctrl.setError(ctrl.getArraySubField(field, 3, 'name')!, 'err3');

      ctrl.insertArrayItem(field, 0, const _Person(name: 'New', age: 25),
          indexedFields: _indexedFields,
          reconstructItem: _reconstructItem,
          reconstructAll: _reconstructAll);

      expect(
          ctrl
              .getErrors(ctrl.getArraySubField(field, 2, 'name')!)
              .first
              .message,
          'err1');
      expect(
          ctrl
              .getErrors(ctrl.getArraySubField(field, 3, 'name')!)
              .first
              .message,
          'err2');
      expect(
          ctrl
              .getErrors(ctrl.getArraySubField(field, 4, 'name')!)
              .first
              .message,
          'err3');
    });

    test('B12: compound insert-then-remove', () {
      final ctrl = _makeControllerWith(3);
      const field = _PersonListField();

      final slot1Name = ctrl.getArraySubField(field, 1, 'name')!;
      ctrl.getFieldController(slot1Name).markTouched();
      ctrl.setError(slot1Name, 'err');

      ctrl.insertArrayItem(field, 0, const _Person(name: 'New', age: 25),
          indexedFields: _indexedFields,
          reconstructItem: _reconstructItem,
          reconstructAll: _reconstructAll);

      ctrl.removeArrayItem(field, 0);

      final slot1NameAfter = ctrl.getArraySubField(field, 1, 'name')!;
      expect(ctrl.getFieldController(slot1NameAfter).touched, isTrue);
      expect(ctrl.getErrors(slot1NameAfter).first.message, 'err');
      expect(ctrl.getValue(field)![0].name, 'Person 0');
    });
  });

  group('append additional tests', () {
    test('D3: append does not disturb disabled', () {
      final ctrl = _makeControllerWith(3);
      const field = _PersonListField();

      final slot1Name = ctrl.getArraySubField(field, 1, 'name')!;
      ctrl.setFieldDisabled(slot1Name, true);

      ctrl.appendArrayItem(field, const _Person(name: 'New', age: 25),
          indexedFields: _indexedFields,
          reconstructItem: _reconstructItem,
          reconstructAll: _reconstructAll);

      expect(ctrl.getFieldController(slot1Name).disabled, isTrue);
      expect(ctrl.getValue(field)!.length, 4);
    });
  });

  group('compound additional scenarios', () {
    test('E1: remove with in-flight then validate', () async {
      final ctrl = _makeControllerWith(5);
      const field = _PersonListField();

      final slot1Name = ctrl.getArraySubField(field, 1, 'name')!;
      final completer = Completer<String?>();

      ctrl.setFieldValidator(
        slot1Name,
        (v) async => completer.future,
        debounce: Duration.zero,
      );
      ctrl.setValue(slot1Name, 'Test');
      await ctrl.triggerAsyncValidation(slot1Name);
      await Future<void>.delayed(Duration.zero);

      ctrl.removeArrayItem(field, 0);

      completer.complete('invalid');
      await Future<void>.delayed(Duration.zero);

      expect(ctrl.validate(), isFalse);
      final slot0Name = ctrl.getArraySubField(field, 0, 'name')!;
      expect(
          ctrl.getFieldController(slot0Name).errors.first.message, 'invalid');
    });

    test('E3: swap cancelling validator then user edits', () async {
      final ctrl = _makeControllerWith(5);
      const field = _PersonListField();

      final slot0Name = ctrl.getArraySubField(field, 0, 'name')!;
      final completer = Completer<String?>();

      ctrl.setFieldValidator(
        slot0Name,
        (v) async => completer.future,
        debounce: Duration.zero,
      );
      ctrl.setValue(slot0Name, 'Test');
      await ctrl.triggerAsyncValidation(slot0Name);
      await Future<void>.delayed(Duration.zero);

      ctrl.swapArrayItems(field, 0, 1);

      expect(ctrl.getFieldController(slot0Name).isValidating, isFalse);
      expect(ctrl.getFieldController(slot0Name).value, 'Person 1');

      final slot1Name = ctrl.getArraySubField(field, 1, 'name')!;
      ctrl.setFieldValidator(
        slot1Name,
        (v) async => v == 'bad' ? 'invalid' : null,
        debounce: Duration.zero,
      );
      ctrl.setValue(slot1Name, 'bad');
      await ctrl.triggerAsyncValidation(slot1Name);
      await Future<void>.delayed(Duration.zero);

      expect(ctrl.getErrors(slot1Name).first.message, 'invalid');
    });
  });
}
