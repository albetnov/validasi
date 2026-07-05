import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/validasi_ui.dart';

class _Model {
  final String name;
  final String email;
  const _Model({this.name = '', this.email = ''});
}

class _NameField extends ValidasiField<_Model, String> {
  const _NameField();
  @override
  String get name => 'name';
  @override
  String? extract(_Model owner) => owner.name;
  @override
  ValidasiResult<String> validate(String? v) {
    if (v == null || v.isEmpty) {
      return ValidasiResult.error(
        ValidationError(rule: 'Required', message: 'Name required'),
      );
    }
    return ValidasiResult.success(v);
  }
}

class _EmailField extends ValidasiField<_Model, String> {
  const _EmailField();
  @override
  String get name => 'email';
  @override
  String? extract(_Model owner) => owner.email;
  @override
  ValidasiResult<String> validate(String? v) {
    if (v == null || v.isEmpty) {
      return ValidasiResult.error(
        ValidationError(rule: 'Required', message: 'Email required'),
      );
    }
    if (!v.contains('@')) {
      return ValidasiResult.error(
        ValidationError(rule: 'Format', message: 'Invalid email'),
      );
    }
    return ValidasiResult.success(v);
  }
}

class _ModelSchema extends ValidasiSchema<_Model> {
  const _ModelSchema();
  @override
  _Model allocate(ValidasiFieldReader<_Model> reader) => _Model(
        name: reader.getValue(const _NameField()) ?? '',
        email: reader.getValue(const _EmailField()) ?? '',
      );
}

const _schema = _ModelSchema();

/// Form validator that cross-validates: email must contain name
ValidasiResult<_Model> _crossValidator(ValidasiFormController<_Model> ctrl) {
  final errors = <ValidationError>[];
  final name = ctrl.getValue(const _NameField());
  final email = ctrl.getValue(const _EmailField());
  if (name != null && name.isNotEmpty && email != null && email.isNotEmpty) {
    if (!email.contains(name)) {
      errors.add(ValidationError(
        rule: 'Refine',
        message: 'Email must contain name',
        path: ['email'],
      ));
    }
  }
  return ValidasiResult(errors: errors, isValid: errors.isEmpty);
}

void main() {
  group('D. Behavior mismatch', () {
    // D1: validateField vs validate — field-level only vs form-level
    test('D1: validateField runs only per-field, not formValidator', () {
      final controller = ValidasiFormController<_Model>(
        schema: _schema,
        formValidator: (ctrl) => ValidasiResult(
          errors: [ValidationError(rule: 'Custom', message: 'Form error')],
          isValid: false,
        ),
      );

      controller.register(const _NameField(), initialValue: 'Alice');
      controller.register(const _EmailField(), initialValue: 'alice@test.com');

      // validateField should return true (field is valid)
      expect(controller.validateField(const _NameField()), isTrue);
      // But form errors are NOT set by validateField
      expect(controller.formErrors, isEmpty);
    });

    // D2: validate() with formValidator runs the formValidator
    test('D2: validate() with formValidator runs cross-validation', () {
      final controller = ValidasiFormController<_Model>(
        schema: _schema,
        formValidator: _crossValidator,
      );

      controller.register(const _NameField(), initialValue: 'Bob');
      controller.register(const _EmailField(), initialValue: 'alice@test.com');

      // Cross-validation: email must contain 'Bob', but it doesn't
      expect(controller.validate(), isFalse);
      final emailErrors = controller.getErrors(const _EmailField());
      expect(emailErrors.length, 1);
      expect(emailErrors.first.message, 'Email must contain name');
    });

    // D3: submit() without arguments — just returns wrapped callback
    test('D3: submit returns a VoidCallback', () {
      final controller = ValidasiFormController<_Model>(schema: _schema);
      controller.register(const _NameField(), initialValue: 'Alice');

      String? result;
      final cb = controller.submit((model) {
        result = model.name;
      });
      expect(cb, isA<VoidCallback>());

      cb();
      expect(result, 'Alice');
    });

    // D4: submitAsync with async formValidator
    test('D4: submitAsync with async formValidator', () async {
      final controller = ValidasiFormController<_Model>(
        schema: _schema,
        formValidator: (ctrl) async {
          await Future<void>.delayed(Duration.zero);
          final name = ctrl.getValue(const _NameField());
          if (name == null || name.isEmpty) {
            return ValidasiResult(
              errors: [ValidationError(rule: 'Required', message: 'Name req')],
              isValid: false,
            );
          }
          return const ValidasiResult(errors: [], isValid: true);
        },
      );

      controller.register(const _NameField(), initialValue: 'Alice');
      controller.register(const _EmailField(), initialValue: 'alice@test.com');

      String? captured;
      await controller.submitAsync((model) {
        captured = model.name;
      })();
      expect(captured, 'Alice');
    });

    // D5: isValid with mixed states
    test('D5: isValid reflects all fields including async errors', () async {
      final controller = ValidasiFormController<_Model>(schema: _schema);
      controller.register(const _NameField(), initialValue: 'Alice');
      controller.register(const _EmailField(), initialValue: 'alice@test.com');

      expect(controller.isValid, isTrue);

      // Field-level validation fails
      controller.setValue(const _NameField(), '');
      expect(controller.isValid, isTrue); // No validation run yet

      controller.validateField(const _NameField());
      expect(controller.isValid, isFalse);

      // Fix name
      controller.setValue(const _NameField(), 'Alice');
      controller.validateField(const _NameField());
      expect(controller.isValid, isTrue);

      // Add async error
      controller.setFieldValidator(
        const _EmailField(),
        (v) async => 'Already registered',
        debounce: Duration.zero,
      );
      await controller.triggerAsyncValidation(const _EmailField());
      await Future<void>.delayed(Duration.zero);
      expect(controller.isValid, isFalse);

      // Disable the invalid field — isValid becomes true again
      controller.setFieldDisabled(const _EmailField(), true);
      expect(controller.isValid, isTrue);
    });

    // D6: getValues excludes disabled and array-item fields
    test('D6: getValues filters correctly', () {
      final controller = ValidasiFormController<_Model>(schema: _schema);
      controller.register(const _NameField(), initialValue: 'Alice');
      controller.register(const _EmailField(), initialValue: 'alice@test.com');

      var values = controller.getValues();
      expect(values.length, 2);

      controller.setFieldDisabled(const _NameField(), true);
      values = controller.getValues();
      expect(values.length, 1);
      expect(values.containsKey(const _NameField()), isFalse);
    });

    // D7: reset clears everything
    test('D7: reset restores initial values and clears state', () {
      final controller = ValidasiFormController<_Model>(schema: _schema);
      controller.register(const _NameField(), initialValue: 'Alice');
      controller.register(const _EmailField(), initialValue: 'alice@test.com');

      controller.setValue(const _NameField(), 'Bob');
      controller.setValue(const _EmailField(), 'bob@test.com');
      controller.markSubmitted();

      controller.reset();

      expect(controller.getValue(const _NameField()), 'Alice');
      expect(controller.getValue(const _EmailField()), 'alice@test.com');
      expect(controller.isSubmitted, isFalse);
      expect(controller.isFieldDirty(const _NameField()), isFalse);
      expect(controller.isFieldTouched(const _NameField()), isFalse);
    });

    // D8: validateAsync without formValidator but with async field validators
    test('D8: validateAsync with async field validators', () async {
      final controller = ValidasiFormController<_Model>(schema: _schema);

      // Register a field with async-only validation
      final asyncField = _EmailField();
      controller.register(asyncField, initialValue: 'test@test.com');

      // No formValidator, but field has async validateAsync
      // In this case, validateAsync calls each field's validateAsync
      final result = await controller.validateAsync();
      expect(result, isTrue);
    });

    // D9: clearErrors after setValue preserves new value
    test('D9: clearErrors after setValue retains the new value', () {
      final controller = ValidasiFormController<_Model>(schema: _schema);
      controller.register(const _NameField(), initialValue: 'Alice');

      controller.setValue(const _NameField(), 'Bob');
      controller.setError(const _NameField(), 'Error');
      expect(controller.getErrors(const _NameField()).length, 1);

      controller.clearErrors(const _NameField());
      expect(controller.getErrors(const _NameField()), isEmpty);
      expect(controller.getValue(const _NameField()), 'Bob');
    });

    // D10: isSubmitted transition on invalid submit
    test('D10: isSubmitted set to true on invalid submit', () {
      final controller = ValidasiFormController<_Model>(schema: _schema);
      controller.register(const _NameField()); // empty = invalid

      bool called = false;
      controller.submit((_) {
        called = true;
      })();
      expect(called, isFalse);
      expect(controller.isSubmitted, isTrue);
    });

    // D11: isSubmitted NOT set on valid submit
    test('D11: isSubmitted NOT set on valid submit', () {
      final controller = ValidasiFormController<_Model>(schema: _schema);
      controller.register(const _NameField(), initialValue: 'Alice');

      bool called = false;
      controller.submit((_) {
        called = true;
      })();
      expect(called, isTrue);
      expect(controller.isSubmitted, isFalse);
    });

    // D12: getValue for unregistered field auto-registers
    test('D12: getValue auto-registers field', () {
      final controller = ValidasiFormController<_Model>(schema: _schema);
      expect(controller.getValue(const _NameField()), isNull);
      // Field is now registered
      controller.setValue(const _NameField(), 'test');
      expect(controller.getValue(const _NameField()), 'test');
    });

    // D13: double register is idempotent
    test('D13: double register does not reset value', () {
      final controller = ValidasiFormController<_Model>(schema: _schema);
      controller.register(const _NameField(), initialValue: 'first');
      controller.register(const _NameField(), initialValue: 'second');
      expect(controller.getValue(const _NameField()), 'first');
    });

    // D14: setInitialValues after manual changes overrides
    test('D14: setInitialValues overrides current values', () {
      final controller = ValidasiFormController<_Model>(schema: _schema);
      controller.register(const _NameField(), initialValue: 'Alice');
      controller.setValue(const _NameField(), 'Bob');

      controller.setInitialValues(const _Model(name: 'Charlie', email: ''));
      expect(controller.getValue(const _NameField()), 'Charlie');
    });

    // D15: validate() throws on async formValidator
    test('D15: validate() throws StateError with async formValidator', () {
      final controller = ValidasiFormController<_Model>(
        schema: _schema,
        formValidator: (ctrl) async =>
            const ValidasiResult(errors: [], isValid: true),
      );

      expect(
        () => controller.validate(),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('async'),
        )),
      );
    });

    // D16: Repeated validate runs accumulate errors correctly
    test('D16: repeated validate accumulates correct errors', () {
      final controller = ValidasiFormController<_Model>(schema: _schema);
      controller.register(const _NameField(), initialValue: '');
      controller.register(const _EmailField(), initialValue: '');

      // First validate — both empty
      controller.validate();
      expect(controller.getErrors(const _NameField()).length, 1);
      expect(controller.getErrors(const _EmailField()).length, 1);

      // Fix email
      controller.setValue(const _EmailField(), 'a@b.com');
      controller.validate();
      expect(controller.getErrors(const _NameField()).length, 1);
      expect(controller.getErrors(const _EmailField()).length, 0);
    });

    // D17: validateField on already-valid field returns true
    test('D17: validateField on valid field returns true and keeps 0 errors',
        () {
      final controller = ValidasiFormController<_Model>(schema: _schema);
      controller.register(const _NameField(), initialValue: 'Alice');

      expect(controller.validateField(const _NameField()), isTrue);
      expect(controller.getErrors(const _NameField()), isEmpty);
    });

    // D18: isLoading is false by default
    test('D18: isLoading defaults to false', () {
      final controller = ValidasiFormController<_Model>(schema: _schema);
      expect(controller.isLoading, isFalse);
    });
  });
}
