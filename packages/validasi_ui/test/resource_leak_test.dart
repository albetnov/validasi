import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/validasi_ui.dart';

class _Field extends ValidasiField<String, String> {
  final String _name;
  const _Field(this._name);
  @override
  String get name => _name;
  @override
  String? extract(String owner) => owner;
  @override
  ValidasiResult<String> validate(String? v) => ValidasiResult.success(v);
}

const _stringSchema = _StringSchema();

class _StringSchema extends ValidasiSchema<String> {
  const _StringSchema();
  @override
  String allocate(ValidasiFieldReader<String> reader) => '';
}

ValidasiFormController<String> _ctrl() =>
    ValidasiFormController(schema: _stringSchema);

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
  ValidasiResult<List<_Person>> validate(List<_Person>? v) =>
      ValidasiResult.success(v as List<_Person>);
}

List<ValidasiField<String, dynamic>> _indexedFields(int index) => [
      IndexedField<String, String>(
        fieldName: 'name',
        parentPath: 'people',
        index: index,
        validate: (v) => ValidasiResult.success(v),
        validateAsync: (v) async => ValidasiResult.success(v),
        extractFromItem: (item) => (item as _Person).name,
      ),
      IndexedField<String, int>(
        fieldName: 'age',
        parentPath: 'people',
        index: index,
        validate: (v) => ValidasiResult.success(v),
        validateAsync: (v) async => ValidasiResult.success(v),
        extractFromItem: (item) => (item as _Person).age,
      ),
    ];

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
  return [
    for (var i = 0; i < count; i++) _reconstructItem(ctrl, i) as _Person,
  ];
}

void main() {
  group('C. Resource leak — signal / timer / subscription cleanup', () {
    // C1: unregister disposes signals
    test('C1: unregister field disposes all signals', () {
      final controller = _ctrl();
      const field = _Field('leak1');

      controller.register(field);
      final fc = controller.getFieldController(field);
      controller.unregister(field);

      // The signal should be disposed — accessing it would create a fresh one
      final newFc = controller.getFieldController(field);
      // newFc is a different object from the old fc (new signal created on re-register)
      expect(identical(fc, newFc), isFalse);
    });

    // C2: unregister timers are cancelled
    test('C2: unregister cancels debounce timer', () async {
      final controller = _ctrl();
      const field = _Field('timer');

      var validatorCalled = false;
      controller.setFieldValidator(
        field,
        (v) async {
          validatorCalled = true;
          await Future.delayed(const Duration(milliseconds: 50));
          return 'error';
        },
        debounce: const Duration(milliseconds: 10),
      );

      controller.setValue(field, 'test');
      await Future<void>.delayed(const Duration(milliseconds: 5));

      // Unregister before debounce fires
      controller.unregister(field);

      // Wait long enough for timer to have fired if it wasn't cancelled
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(validatorCalled, isFalse,
          reason: 'Validator should not have been called after unregister');
    });

    // C3: subscriptions are cleaned up on unregister
    test('C3: unregister removes subscriptions from internal map', () {
      final controller = _ctrl();
      const field = _Field('sub');

      controller.register(field);
      controller.unregister(field);

      // Register again — fresh signal should have no stale subscriptions
      controller.register(field);
      controller.setValue(field, 'test');
      expect(controller.getValue(field), 'test');
    });

    // C4: dispose controller cleans up everything
    test('C4: controller dispose cleans all registrations', () {
      final controller = _ctrl();
      const a = _Field('a');
      const b = _Field('b');

      controller.register(a);
      controller.register(b);
      controller.setValue(a, 'A');
      controller.setValue(b, 'B');

      controller.dispose();

      // After dispose, all operations throw
      expect(() => controller.isValid, throwsA(isA<StateError>()));
    });

    // C5: register → unregister → register cycle does not leak signals
    test('C5: register/unregister/register cycle — no leaking signal refs', () {
      final controller = _ctrl();
      const field = _Field('cycle');

      final signals = <Object>[];
      for (var i = 0; i < 5; i++) {
        controller.register(field);
        controller.setValue(field, 'v$i');
        final fc = controller.getFieldController(field);
        signals.add(fc);
        controller.unregister(field);
      }

      // All 5 signals should be distinct (each unregister disposed the old one)
      for (var i = 1; i < signals.length; i++) {
        expect(identical(signals[0], signals[i]), isFalse);
      }
    });

    // C6: array append/remove does not leak sub-field signals
    test('C6: array append then remove all — no leftover sub-fields', () {
      final controller = _ctrl();
      const listField = _PersonListField();

      controller.appendArrayItem(
        listField,
        const _Person(name: 'A', age: 1),
        indexedFields: _indexedFields,
        reconstructItem: _reconstructItem,
        reconstructAll: _reconstructAll,
      );
      controller.appendArrayItem(
        listField,
        const _Person(name: 'B', age: 2),
        indexedFields: _indexedFields,
        reconstructItem: _reconstructItem,
        reconstructAll: _reconstructAll,
      );

      expect(controller.getArrayItemCount(listField), 2);

      controller.removeArrayItem(listField, 0);
      controller.removeArrayItem(listField, 0);

      expect(controller.getArrayItemCount(listField), 0);

      // After removing all items, sub-fields should be gone
      expect(controller.getArraySubField(listField, 0, 'name'), isNull);
      expect(controller.getArraySubField(listField, 0, 'age'), isNull);
    });

    // C7: swap array items — no stale signals left
    test('C7: swap does not leak or orphan signals', () {
      final controller = _ctrl();
      const listField = _PersonListField();

      controller.appendArrayItem(
        listField,
        const _Person(name: 'A', age: 1),
        indexedFields: _indexedFields,
        reconstructItem: _reconstructItem,
        reconstructAll: _reconstructAll,
      );
      controller.appendArrayItem(
        listField,
        const _Person(name: 'B', age: 2),
        indexedFields: _indexedFields,
        reconstructItem: _reconstructItem,
        reconstructAll: _reconstructAll,
      );

      controller.swapArrayItems(listField, 0, 1);

      // Sub-fields swapped and values correct
      final name0 = controller.getArraySubField(listField, 0, 'name')!;
      final name1 = controller.getArraySubField(listField, 1, 'name')!;
      expect(controller.getValue(name0), 'B');
      expect(controller.getValue(name1), 'A');
    });

    // C8: multiple field registrations and clean up
    test('C8: register 10 fields, unregister all, then dispose', () {
      final controller = _ctrl();
      final fields = List.generate(10, (i) => _Field('f$i'));

      for (final f in fields) {
        controller.register(f);
      }

      for (final f in fields) {
        controller.unregister(f);
      }

      controller.dispose();
      // No crash = no leak
    });

    // C9: async validator cleanup on unregister
    test('C9: async validator state removed on unregister', () async {
      final controller = _ctrl();
      const field = _Field('asyncClean');

      controller.register(field);
      controller.setFieldValidator(
        field,
        (v) async => 'error',
        debounce: Duration.zero,
      );

      await controller.triggerAsyncValidation(field);
      await Future<void>.delayed(Duration.zero);

      expect(controller.getErrors(field).length, 1);

      controller.unregister(field);

      // Re-register — should be clean, no stale async error
      controller.register(field);
      expect(controller.getErrors(field), isEmpty);
    });

    // C10: append + remove in a loop — no crash or growth
    test('C10: 20 append/remove cycles — stable', () {
      final controller = _ctrl();
      const listField = _PersonListField();

      for (var i = 0; i < 20; i++) {
        controller.appendArrayItem(
          listField,
          _Person(name: 'X', age: i),
          indexedFields: _indexedFields,
          reconstructItem: _reconstructItem,
          reconstructAll: _reconstructAll,
        );
      }
      expect(controller.getArrayItemCount(listField), 20);

      for (var i = 0; i < 20; i++) {
        controller.removeArrayItem(listField, 0);
      }
      expect(controller.getArrayItemCount(listField), 0);

      // After all removes, no orphaned sub-fields
      for (var i = 0; i < 5; i++) {
        expect(controller.getArraySubField(listField, i, 'name'), isNull);
      }
    });

    // C11: conditional — setFieldValidator(null) removes async state without unregister
    test('C11: setFieldValidator(null) cleans async state', () async {
      final controller = _ctrl();
      const field = _Field('nullAsync');

      controller.register(field);
      controller.setFieldValidator(
        field,
        (v) async => 'error',
        debounce: Duration.zero,
      );

      await controller.triggerAsyncValidation(field);
      await Future<void>.delayed(Duration.zero);
      expect(controller.getErrors(field).length, 1);

      // Remove validator
      controller.setFieldValidator(field, null);
      expect(controller.getErrors(field), isEmpty);
    });

    // C12: async in-flight + remove array item — cleanup
    test('C12: remove array item with in-flight async — no leak', () async {
      final controller = _ctrl();
      const listField = _PersonListField();

      controller.appendArrayItem(
        listField,
        const _Person(name: 'A', age: 1),
        indexedFields: _indexedFields,
        reconstructItem: _reconstructItem,
        reconstructAll: _reconstructAll,
      );

      final nameField = controller.getArraySubField(listField, 0, 'name')!;
      final completer = Completer<String?>();

      controller.setFieldValidator(
        nameField,
        (v) async => completer.future,
        debounce: Duration.zero,
      );
      controller.setValue(nameField, 'Test');
      await controller.triggerAsyncValidation(nameField);
      await Future<void>.delayed(Duration.zero);

      // Remove the item while async is in-flight
      controller.removeArrayItem(listField, 0);

      // Complete the async validation
      completer.complete('bad');
      await Future<void>.delayed(Duration.zero);

      // Item is gone, no errors remain
      expect(controller.getArrayItemCount(listField), 0);

      // No crash when completing the completer
    });

    // C13: stress — many register/unregister cycles with async
    test('C13: 50 register/unregister cycles with async — stable', () async {
      final controller = _ctrl();
      const field = _Field('stress');

      for (var i = 0; i < 50; i++) {
        controller.register(field);
        controller.setValue(field, 'v$i');
        controller.setFieldValidator(
          field,
          (v) async {
            await Future<void>.delayed(Duration.zero);
            return null;
          },
          debounce: Duration.zero,
        );
        await controller.triggerAsyncValidation(field);
        await Future<void>.delayed(Duration.zero);
        controller.unregister(field);
      }

      // Final register — should be clean
      controller.register(field);
      expect(controller.getValue(field), isNull);
    });
  });
}
