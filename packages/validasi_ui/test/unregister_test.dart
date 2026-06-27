import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/validasi_ui.dart';

class _TestKey extends ValidasiField<String, String> {
  const _TestKey(this._name) : super();
  final String _name;

  @override
  String get name => _name;

  @override
  String? extract(String owner) => null;

  @override
  ValidasiResult<String> validate(String? value) =>
      ValidasiResult.success(value ?? '');
}

class _Person {
  final String name;
  const _Person({required this.name});
}

class _NameField extends ValidasiField<_Person, String> {
  const _NameField();
  @override
  String get name => 'name';
  @override
  String? extract(_Person owner) => owner.name;
  @override
  ValidasiResult<String> validate(String? v) => ValidasiResult.success(v);
}

const _nameField = _NameField();

class _PersonListField extends ValidasiField<String, List<_Person>> {
  const _PersonListField() : super();
  @override
  String get name => 'people';
  @override
  List<_Person>? extract(String owner) => null;
  @override
  ValidasiResult<List<_Person>> validate(List<_Person>? v) =>
      ValidasiResult.success(v as List<_Person>);
}

List<ValidasiField<String, dynamic>> _indexedFields(int index) {
  return [
    IndexedField<String, String>(
      fieldName: _nameField.name,
      parentPath: 'people',
      index: index,
      validate: (v) => ValidasiResult.success(v),
      validateAsync: (v) async => ValidasiResult.success(v),
      extractFromItem: (item) => (item as _Person).name,
    ),
  ];
}

dynamic _reconstructItem(ValidasiFormController<String> ctrl, int index) {
  const field = _PersonListField();
  return _Person(
    name: ctrl.getValue(ctrl.getArraySubField(field, index, 'name')!),
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

void main() {
  group('unregister', () {
    test('removes field from controller', () {
      final controller = _makeController();
      const field = _TestKey('email');

      controller.setValue(field, 'test@example.com');
      expect(controller.getValue(field), 'test@example.com');

      controller.unregister(field);
      expect(controller.getFieldController(field).value, isNull);
    });

    test('clears field from fieldsByName', () {
      final controller = _makeController();
      const field = _TestKey('name');

      controller.register(field);
      controller.unregister(field);

      expect(
          () => controller.getFieldController(field), isNot(throwsA(anything)));
    });

    test('re-register after unregister creates fresh signal', () {
      final controller = _makeController();
      const field = _TestKey('fresh');

      controller.setValue(field, 'old');
      controller.unregister(field);

      controller.setValue(field, 'new');
      expect(controller.getValue(field), 'new');
    });

    test('unregister cancels async validators', () {
      final controller = _makeController();
      const field = _TestKey('async');

      controller.setFieldValidator(field, (_) async => null);
      controller.unregister(field);

      controller.setFieldValidator(field, (_) async => 'error');
      expect(controller.getValue(field), isNull);
    });

    test('unregister updates isValid', () {
      final controller = _makeController();
      const field = _TestKey('valid');

      controller.register(field);
      controller.setError(field, 'some error');
      expect(controller.isValid, isFalse);

      controller.unregister(field);
      expect(controller.isValid, isTrue);
    });

    test('unregister does not throw for unregistered field', () {
      final controller = _makeController();
      const field = _TestKey('never');

      expect(() => controller.unregister(field), returnsNormally);
    });
  });

  group('edge: unregister/register cycles', () {
    test('unregister → register → unregister → register', () {
      final controller = _makeController();
      const field = _TestKey('cycle');

      controller.setValue(field, 'v1');
      controller.unregister(field);
      controller.setValue(field, 'v2');
      controller.unregister(field);
      controller.setValue(field, 'v3');

      expect(controller.getValue(field), 'v3');
    });

    test('double unregister does not throw', () {
      final controller = _makeController();
      const field = _TestKey('double');

      controller.register(field);
      controller.unregister(field);
      expect(() => controller.unregister(field), returnsNormally);
    });

    test('unregister during validateField no crash', () {
      final controller = _makeController();
      const field = _TestKey('during');

      controller.setValue(field, 'x');
      controller.validateField(field);
      controller.unregister(field);

      expect(controller.isValid, isTrue);
    });
  });

  group('edge: dispose ordering', () {
    test('dispose controller after unregister no crash', () {
      final controller = _makeController();
      const a = _TestKey('a');
      const b = _TestKey('b');

      controller.register(a);
      controller.register(b);
      controller.unregister(a);

      expect(() => controller.dispose(), returnsNormally);
    });

    test('unregister after controller dispose is unsafe', () {
      final controller = _makeController();
      const field = _TestKey('gone');

      controller.register(field);
      controller.dispose();

      expect(() => controller.unregister(field), throwsA(anything));
    });
  });

  group('edge: async validation + unregister', () {
    test('unregister cancels in-flight async validation', () async {
      final controller = _makeController();
      const field = _TestKey('inflight');

      controller.setValue(field, 'initial');
      controller.setFieldValidator(
        field,
        (_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return 'error';
        },
        debounce: const Duration(milliseconds: 10),
      );

      controller.triggerAsyncValidation(field);
      controller.unregister(field);

      await Future.delayed(const Duration(milliseconds: 200));
      // No stale error set — test passes without assertion failure
      expect(controller.getFieldController(field).value, isNull);
    });

    test('async completes before unregister does not crash', () async {
      final controller = _makeController();
      const field = _TestKey('quick');

      controller.setFieldValidator(
        field,
        (v) async {
          if (v == 'bad') return 'error';
          return null;
        },
        debounce: const Duration(milliseconds: 5),
      );

      controller.setValue(field, 'bad');
      await Future.delayed(const Duration(milliseconds: 50));
      controller.unregister(field);

      expect(controller.getFieldController(field).value, isNull);
    });
  });

  group('edge: object arrays + unregister', () {
    test('unregister parent array field cleans up sub-fields', () {
      final controller = _makeController();
      const field = _PersonListField();

      controller.appendArrayItem(
        field,
        const _Person(name: 'Alice'),
        indexedFields: _indexedFields,
        reconstructItem: _reconstructItem,
        reconstructAll: _reconstructAll,
      );

      controller.unregister(field);

      expect(controller.getArraySubField(field, 0, 'name'), isNull);
      expect(controller.getArrayItemCount(field), 0);
    });

    test('unregister sub-field directly', () {
      final controller = _makeController();
      const field = _PersonListField();

      controller.appendArrayItem(
        field,
        const _Person(name: 'Bob'),
        indexedFields: _indexedFields,
        reconstructItem: _reconstructItem,
        reconstructAll: _reconstructAll,
      );

      final nameField = controller.getArraySubField(field, 0, 'name')!;
      controller.unregister(nameField);

      expect(controller.getArraySubField(field, 0, 'name'), isNull);
      // Parent list still has the item
      expect(controller.getArrayItemCount(field), 1);
    });
  });

  group('edge: setValue / reset interaction', () {
    test('setValue after reset', () {
      final controller = _makeController();
      const field = _TestKey('post');

      controller.setValue(field, 'initial');
      controller.reset();
      controller.setValue(field, 'after');

      expect(controller.getValue(field), 'after');
      expect(controller.isFieldDirty(field), isTrue);
    });

    test('reset after unregister does not crash', () {
      final controller = _makeController();
      const a = _TestKey('a');
      const b = _TestKey('b');

      controller.setValue(a, 'x');
      controller.setValue(b, 'y');
      controller.unregister(a);
      controller.reset();

      expect(controller.getValue(b), isNull);
    });

    test('setValue on unregistered field auto-registers', () {
      final controller = _makeController();
      const field = _TestKey('auto');

      controller.setValue(field, 'val');
      expect(controller.getValue(field), 'val');
    });
  });

  group('edge: isDirty / isTouched after re-register', () {
    test('re-register after dirty is pristine', () {
      final controller = _makeController();
      const field = _TestKey('dirty');

      controller.setValue(field, 'changed');
      expect(controller.isFieldDirty(field), isTrue);

      controller.unregister(field);
      controller.register(field);

      expect(controller.isFieldDirty(field), isFalse);
    });

    test('re-register after touched is untouched', () {
      final controller = _makeController();
      const field = _TestKey('touched');

      controller.register(field);
      controller.getFieldController(field).markTouched();
      expect(controller.isFieldTouched(field), isTrue);

      controller.unregister(field);
      controller.register(field);

      expect(controller.isFieldTouched(field), isFalse);
    });
  });

  group('edge: getValues after unregister', () {
    test('getValues excludes unregistered fields', () {
      final controller = _makeController();
      const a = _TestKey('a');
      const b = _TestKey('b');

      controller.setValue(a, 'A');
      controller.setValue(b, 'B');
      controller.unregister(a);

      final values = controller.getValues();
      expect(values.length, 1);
      expect(values[const _TestKey('b')], 'B');
    });

    test('getValues includes re-registered field', () {
      final controller = _makeController();
      const field = _TestKey('re');

      controller.setValue(field, 'first');
      controller.unregister(field);
      controller.setValue(field, 'second');

      final values = controller.getValues();
      expect(values[field], 'second');
    });
  });

  group('edge: error state edge cases', () {
    test('setError does not auto-register field', () {
      final controller = _makeController();
      const field = _TestKey('err-auto');

      controller.setError(field, 'test error');
      expect(controller.getFieldController(field).syncErrors, isEmpty);

      controller.register(field);
      controller.setError(field, 'test error');
      expect(controller.getFieldController(field).syncErrors, isNotEmpty);
    });

    test('clearErrors after unregister does not crash', () {
      final controller = _makeController();
      const field = _TestKey('clear');

      controller.register(field);
      controller.setError(field, 'err');
      controller.unregister(field);

      expect(() => controller.clearErrors(field), returnsNormally);
    });

    test('clearAllErrors after unregister does not crash', () {
      final controller = _makeController();
      const a = _TestKey('a');
      const b = _TestKey('b');

      controller.register(a);
      controller.register(b);
      controller.setError(a, 'errA');
      controller.setError(b, 'errB');
      controller.unregister(a);
      controller.clearAllErrors();

      expect(controller.getFieldController(b).syncErrors, isEmpty);
    });

    test('validateField on unregistered field auto-registers', () {
      final controller = _makeController();
      const field = _TestKey('val-auto');

      final result = controller.validateField(field);
      expect(result, isTrue);
      expect(controller.getFieldController(field).value, isNull);
    });
  });

  group('edge: getFieldController / getValue consistency', () {
    test('getValue returns null after unregister', () {
      final controller = _makeController();
      const field = _TestKey('get');

      controller.setValue(field, 'x');
      controller.unregister(field);

      expect(controller.getValue(field), isNull);
    });

    test('getErrors returns empty after unregister', () {
      final controller = _makeController();
      const field = _TestKey('err-empty');

      controller.register(field);
      controller.setError(field, 'err');
      controller.unregister(field);

      expect(controller.getErrors(field), isEmpty);
    });
  });

  group('edge: form-level isDirty / isTouched with unregister', () {
    test('isDirty updates after unregister', () {
      final controller = _makeController();
      const a = _TestKey('a');
      const b = _TestKey('b');

      controller.setValue(a, 'A');
      controller.setValue(b, 'B');
      expect(controller.isDirty, isTrue);

      controller.unregister(a);
      controller.unregister(b);
      expect(controller.isDirty, isFalse);
    });

    test('isTouched updates after unregister', () {
      final controller = _makeController();
      const field = _TestKey('t');

      controller.register(field);
      controller.getFieldController(field).markTouched();
      expect(controller.isTouched, isTrue);

      controller.unregister(field);
      expect(controller.isTouched, isFalse);
    });
  });

  group('edge: shouldUnregister widget wizard flow', () {
    testWidgets(
        'mount → unmount → remount restores value with shouldUnregister: false',
        (tester) async {
      final controller = _makeController();
      const field = _TestKey('wizard');

      // First mount with shouldUnregister: false
      await tester.pumpWidget(
        MaterialApp(
          home: ValidasiForm<String>(
            controller: controller,
            schema: _emptyStringSchema,
            shouldUnregister: false,
            builder: (context, submit) => Scaffold(
              body: Column(
                children: [
                  ValidasiFormField<String, String>(
                    field: field,
                    builder: (context, state) =>
                        TextField(onChanged: state.onChanged),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      controller.setValue(field, 'wizard-value');
      expect(controller.getValue(field), 'wizard-value');

      // Remount with a fresh form widget — should reuse same controller
      await tester.pumpWidget(
        MaterialApp(
          home: ValidasiForm<String>(
            controller: controller,
            schema: _emptyStringSchema,
            shouldUnregister: false,
            builder: (context, submit) => Scaffold(
              body: Column(
                children: [
                  ValidasiFormField<String, String>(
                    field: field,
                    builder: (context, state) =>
                        TextField(onChanged: state.onChanged),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(controller.getValue(field), 'wizard-value');
    });

    testWidgets('field-level override beats form-level shouldUnregister',
        (tester) async {
      final controller = _makeController();
      const stickyField = _TestKey('sticky');
      const cleanupField = _TestKey('clean');

      await tester.pumpWidget(
        MaterialApp(
          home: ValidasiForm<String>(
            controller: controller,
            schema: _emptyStringSchema,
            shouldUnregister: true,
            builder: (context, submit) => Scaffold(
              body: Column(
                children: [
                  ValidasiFormField<String, String>(
                    field: stickyField,
                    shouldUnregister: false,
                    builder: (c, s) => TextField(onChanged: s.onChanged),
                  ),
                  ValidasiFormField<String, String>(
                    field: cleanupField,
                    shouldUnregister: true,
                    builder: (c, s) => TextField(onChanged: s.onChanged),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      controller.setValue(stickyField, 'stays');
      controller.setValue(cleanupField, 'gone');

      // Remount
      await tester.pumpWidget(
        MaterialApp(
          home: ValidasiForm<String>(
            controller: controller,
            schema: _emptyStringSchema,
            shouldUnregister: true,
            builder: (context, submit) => Scaffold(
              body: Column(
                children: [
                  ValidasiFormField<String, String>(
                    field: stickyField,
                    shouldUnregister: false,
                    builder: (c, s) => TextField(onChanged: s.onChanged),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(controller.getValue(stickyField), 'stays');
      expect(controller.getValue(cleanupField), isNull);
    });
  });
}
