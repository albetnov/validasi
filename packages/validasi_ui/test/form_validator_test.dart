import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/validasi_ui.dart';
import 'package:validasi_ui/validasi.dart';

class _Model {
  final String name;
  final String email;
  const _Model({required this.name, required this.email});
}

class _NameField extends ValidasiField<_Model, String> {
  const _NameField() : super();
  @override
  String get name => 'name';
  @override
  String? extract(_Model owner) => owner.name;
  @override
  ValidasiResult<String> validate(String? value) {
    if (value == null || value.isEmpty) {
      return ValidasiResult.error(
        ValidationError(rule: 'Required', message: 'Required'),
      );
    }
    return ValidasiResult.success(value);
  }
}

class _EmailField extends ValidasiField<_Model, String> {
  const _EmailField() : super();
  @override
  String get name => 'email';
  @override
  String? extract(_Model owner) => owner.email;
  @override
  ValidasiResult<String> validate(String? value) {
    if (value == null || value.isEmpty) {
      return ValidasiResult.error(
        ValidationError(rule: 'Required', message: 'Required'),
      );
    }
    return ValidasiResult.success(value);
  }
}

const _modelSchema = _ModelSchema();

class _ModelSchema extends ValidasiSchema<_Model> {
  const _ModelSchema();
  @override
  _Model allocate(ValidasiFieldReader<_Model> reader) => _Model(
        name: reader.getValue(const _NameField()) ?? '',
        email: reader.getValue(const _EmailField()) ?? '',
      );
}

ValidasiResult<_Model> _formValidator(ValidasiFormController<_Model> ctrl) {
  final errors = <ValidationError>[];
  final name = ctrl.getValue(const _NameField());
  final email = ctrl.getValue(const _EmailField());
  if (name == null || name.isEmpty) {
    errors.add(ValidationError(
        rule: 'Required', message: 'Name required', path: ['name']));
  }
  if (email == null || email.isEmpty) {
    errors.add(ValidationError(
        rule: 'Required', message: 'Email required', path: ['email']));
  }
  // refine: email must contain name
  if (name != null &&
      email != null &&
      email.isNotEmpty &&
      name.isNotEmpty &&
      !email.contains(name)) {
    errors.add(ValidationError(
        rule: 'Refine', message: 'Email must contain name', path: ['email']));
  }
  return ValidasiResult(errors: errors, isValid: errors.isEmpty);
}

Future<ValidasiResult<_Model>> _asyncFormValidator(
    ValidasiFormController<_Model> ctrl) async {
  return _formValidator(ctrl);
}

const _autoValidatedSchema = _ModelSchemaWithAutoValidator();

class _ModelSchemaWithAutoValidator extends ValidasiSchema<_Model>
    implements ValidasiFormValidatorSchema<_Model> {
  const _ModelSchemaWithAutoValidator();
  @override
  _Model allocate(ValidasiFieldReader<_Model> reader) => _Model(
        name: reader.getValue(const _NameField()) ?? '',
        email: reader.getValue(const _EmailField()) ?? '',
      );

  @override
  FutureOr<ValidasiResult<_Model>> Function(ValidasiFormController<_Model>)
      get formValidator => _formValidator;
}

ValidasiFormController<_Model> _makeController({
  FutureOr<ValidasiResult<_Model>> Function(ValidasiFormController<_Model>)?
      formValidator,
}) {
  return ValidasiFormController(
    schema: _modelSchema,
    formValidator: formValidator,
  );
}

void main() {
  group('formValidator — error distribution', () {
    test('distributes errors to correct fields by path[0]', () {
      final controller = _makeController(formValidator: _formValidator);
      const nameField = _NameField();
      const emailField = _EmailField();

      controller.register(nameField);
      controller.register(emailField);
      controller.setValue(nameField, 'Alice');
      controller.setValue(emailField, 'bob@example.com');

      final result = controller.validate();
      expect(result, isFalse);

      final nameErrors = controller.getErrors(nameField);
      expect(nameErrors, isEmpty);

      final emailErrors = controller.getErrors(emailField);
      expect(emailErrors, hasLength(1));
      expect(emailErrors.first.message, 'Email must contain name');
    });

    test('distributes multiple errors per field', () {
      final controller = _makeController(formValidator: _formValidator);
      const nameField = _NameField();

      controller.register(nameField);
      controller.setValue(nameField, '');

      controller.validate();
      final errors = controller.getErrors(nameField);
      expect(errors, hasLength(1));
      expect(errors.first.rule, 'Required');
    });

    test('clears previous field errors before distributing', () {
      final controller = ValidasiFormController(
        schema: _modelSchema,
        formValidator: _formValidator,
      );
      const nameField = _NameField();
      const emailField = _EmailField();

      controller.register(nameField);
      controller.register(emailField);
      controller.setValue(nameField, '');
      controller.setValue(emailField, '');

      controller.validate();

      expect(controller.getErrors(nameField).length, 1);
      expect(controller.getErrors(emailField).length, 1);

      // Fix name, keep email mismatched to trigger refine
      controller.setValue(nameField, 'Alice');
      controller.setValue(emailField, 'alice@example.com');
      controller.validate();

      expect(controller.getErrors(nameField), isEmpty);
      // Refine error: 'alice@example.com' doesn't contain 'Alice'
      expect(controller.getErrors(emailField).length, 1);
      expect(controller.getErrors(emailField).first.rule, 'Refine');
    });
  });

  group('formValidator — form-level error bucket', () {
    test('empty/unknown path errors go to formErrors', () {
      final controller = _makeController(formValidator: (ctrl) {
        return ValidasiResult(
          errors: [
            ValidationError(rule: 'Custom', message: 'Form-level error')
          ],
          isValid: false,
        );
      });
      const nameField = _NameField();
      controller.register(nameField);
      controller.setValue(nameField, 'Alice');

      controller.validate();
      expect(controller.formErrors, hasLength(1));
      expect(controller.formErrors.first.message, 'Form-level error');
    });
  });

  group('setError / clearErrors', () {
    test('setError adds error to a specific field', () {
      final controller = _makeController();
      const nameField = _NameField();
      controller.register(nameField, initialValue: 'Alice');

      controller.setError(nameField, 'Manual error');
      final errors = controller.getErrors(nameField);
      expect(errors, hasLength(1));
      expect(errors.first.rule, 'Manual');
      expect(errors.first.message, 'Manual error');
    });

    test('setError replaces existing errors by default', () {
      final controller = _makeController();
      const nameField = _NameField();
      controller.register(nameField, initialValue: '');

      controller.validateField(nameField);
      expect(controller.getErrors(nameField).length, 1);

      controller.setError(nameField, 'Replacement error');
      final errorsAfterSet = controller.getErrors(nameField);
      expect(errorsAfterSet, hasLength(1));
      expect(errorsAfterSet.first.message, 'Replacement error');
    });

    test('setError with overwrite: false preserves existing errors', () {
      final controller = _makeController();
      const nameField = _NameField();
      controller.register(nameField, initialValue: '');

      controller.validateField(nameField);
      expect(controller.getErrors(nameField).length, 1);

      controller.setError(nameField, 'Skipped error', overwrite: false);
      expect(controller.getErrors(nameField).length, 1);
    });

    test('setError with overwrite: false adds error when field is clean', () {
      final controller = _makeController();
      const nameField = _NameField();
      controller.register(nameField, initialValue: 'Alice');

      controller.setError(nameField, 'Only error', overwrite: false);
      final errors = controller.getErrors(nameField);
      expect(errors, hasLength(1));
      expect(errors.first.message, 'Only error');
    });

    test('clearErrors removes all errors from a single field', () {
      final controller = _makeController();
      const nameField = _NameField();
      const emailField = _EmailField();
      controller.register(nameField, initialValue: '');
      controller.register(emailField, initialValue: '');

      controller.validateField(nameField);
      controller.validateField(emailField);
      expect(controller.getErrors(nameField), isNotEmpty);
      expect(controller.getErrors(emailField), isNotEmpty);

      controller.clearErrors(nameField);
      expect(controller.getErrors(nameField), isEmpty);
      expect(controller.getErrors(emailField), isNotEmpty);
    });

    test('clearAllErrors clears all fields and formErrors', () {
      final controller = ValidasiFormController(
        schema: _modelSchema,
        formValidator: (ctrl) {
          return ValidasiResult(
            errors: [ValidationError(rule: 'Custom', message: 'Form error')],
            isValid: false,
          );
        },
      );
      const nameField = _NameField();
      controller.register(nameField, initialValue: '');

      controller.validate();
      expect(controller.formErrors, isNotEmpty);

      controller.clearAllErrors();
      expect(controller.formErrors, isEmpty);
    });
  });

  group('validateAsync with formValidator', () {
    test('calls formValidator and distributes errors', () async {
      final controller = _makeController(formValidator: _asyncFormValidator);
      const nameField = _NameField();
      const emailField = _EmailField();

      controller.register(nameField);
      controller.register(emailField);
      controller.setValue(nameField, 'Alice');
      controller.setValue(emailField, 'bob@example.com');

      final result = await controller.validateAsync();
      expect(result, isFalse);

      final emailErrors = controller.getErrors(emailField);
      expect(emailErrors, hasLength(1));
      expect(emailErrors.first.message, 'Email must contain name');
    });
  });

  group('backwards compatibility — no formValidator', () {
    test('validate() falls back to per-field iteration', () {
      final controller = _makeController();
      const nameField = _NameField();
      controller.register(nameField, initialValue: '');

      final result = controller.validate();
      expect(result, isFalse);
      expect(controller.getErrors(nameField).length, 1);
    });

    test('validateAsync() falls back to per-field async iteration', () async {
      final controller = _makeController();
      const nameField = _NameField();
      controller.register(nameField, initialValue: '');

      final result = await controller.validateAsync();
      expect(result, isFalse);
      expect(controller.getErrors(nameField).length, 1);
    });

    test('validateField() still works without formValidator', () {
      final controller = _makeController();
      const nameField = _NameField();
      controller.register(nameField, initialValue: '');

      expect(controller.validateField(nameField), isFalse);
      expect(controller.getErrors(nameField).length, 1);
    });

    test('submit() still works without formValidator', () {
      final controller = _makeController();
      const nameField = _NameField();
      controller.register(nameField, initialValue: 'hello');

      String? captured;
      controller.submit((model) {
        captured = model.name;
      })();

      expect(captured, 'hello');
    });
  });

  group('validateField with formValidator', () {
    test('validateField still runs per-field only (no refine)', () {
      final controller = _makeController(formValidator: _formValidator);
      const nameField = _NameField();
      const emailField = _EmailField();

      controller.register(nameField);
      controller.register(emailField);
      controller.setValue(nameField, 'Alice');
      controller.setValue(emailField, 'bob@example.com');

      // validateField on name should pass (name has a value)
      expect(controller.validateField(nameField), isTrue);

      // Refine error on email should NOT appear from validateField
      // (refine only runs via formValidator in validate())
      expect(controller.getErrors(emailField), isEmpty);
    });
  });

  group('formValidator auto-discovery from schema', () {
    test('controller picks up formValidator from schema when not passed', () {
      final controller = ValidasiFormController(schema: _autoValidatedSchema);
      expect(controller.formValidator, isNotNull);
    });

    test('explicit formValidator argument still wins over schema', () {
      var explicitCalled = false;
      final controller = ValidasiFormController(
        schema: _autoValidatedSchema,
        formValidator: (ctrl) {
          explicitCalled = true;
          return const ValidasiResult(errors: [], isValid: true);
        },
      );

      controller.validate();
      expect(explicitCalled, isTrue);
    });

    test('revalidates a dependent field without passing formValidator',
        () async {
      final controller = ValidasiFormController(schema: _autoValidatedSchema);
      const nameField = _NameField();
      const emailField = _EmailField();

      controller.register(nameField);
      controller.register(emailField);
      controller.setValue(nameField, 'Alice');
      controller.setValue(emailField, 'bob@example.com');

      await controller.validateFieldAsync(nameField);

      expect(controller.getErrors(emailField), hasLength(1));
      expect(controller.getErrors(emailField).first.message,
          'Email must contain name');
    });
  });

  group('validateFieldAsync with formValidator', () {
    test('revalidates a dependent field via formValidator', () async {
      final controller = _makeController(formValidator: _formValidator);
      const nameField = _NameField();
      const emailField = _EmailField();

      controller.register(nameField);
      controller.register(emailField);
      controller.setValue(nameField, 'Alice');
      controller.setValue(emailField, 'bob@example.com');
      await controller.validateFieldAsync(nameField);

      // Refine error appears on the dependent field (email), even though
      // only nameField's revalidation was triggered.
      expect(controller.getErrors(emailField), hasLength(1));
      expect(controller.getErrors(emailField).first.message,
          'Email must contain name');

      // Fixing the value that email depends on (name) clears the refine
      // error on email, again triggered only via nameField.
      controller.setValue(nameField, 'bob');
      await controller.validateFieldAsync(nameField);
      expect(controller.getErrors(emailField), isEmpty);
    });

    test('async formValidator revalidates dependent field too', () async {
      final controller = _makeController(formValidator: _asyncFormValidator);
      const nameField = _NameField();
      const emailField = _EmailField();

      controller.register(nameField);
      controller.register(emailField);
      controller.setValue(nameField, 'Alice');
      controller.setValue(emailField, 'bob@example.com');

      final result = await controller.validateFieldAsync(nameField);
      expect(result, isFalse);
      expect(controller.getErrors(emailField), hasLength(1));
    });
  });

  group('validateFieldAsync without formValidator', () {
    test('behaves like validateField but async-safe', () async {
      final controller = _makeController();
      const nameField = _NameField();
      controller.register(nameField, initialValue: '');

      final result = await controller.validateFieldAsync(nameField);
      expect(result, isFalse);
      expect(controller.getErrors(nameField).length, 1);
    });

    test('does not throw for a field with an async rule', () async {
      final controller = ValidasiFormController(schema: _modelSchema);
      const field = _AsyncNameField();
      controller.register(field, initialValue: 'x');

      expect(await controller.validateFieldAsync(field), isTrue);
    });
  });

  group('ValidasiForm builder — submit.async', () {
    testWidgets('awaits an async formValidator before calling onSubmit',
        (tester) async {
      final controller = _makeController(formValidator: _asyncFormValidator);
      const nameField = _NameField();
      const emailField = _EmailField();
      controller.register(nameField);
      controller.register(emailField);
      controller.setValue(nameField, 'bob');
      controller.setValue(emailField, 'bob@example.com');

      _Model? captured;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ValidasiForm<_Model>(
            controller: controller,
            schema: _modelSchema,
            builder: (context, submit) => ElevatedButton(
              onPressed: () => submit.async((model) => captured = model)(),
              child: const Text('submit'),
            ),
          ),
        ),
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(captured, isNotNull);
      expect(captured!.name, 'bob');
    });
  });
}

class _AsyncNameField extends ValidasiField<_Model, String> {
  const _AsyncNameField() : super();
  @override
  String get name => 'name';
  @override
  String? extract(_Model owner) => owner.name;
  @override
  ValidasiResult<String> validate(String? value) {
    throw StateError(
      'Async rules cannot be used with validate(). Use validateAsync() instead.',
    );
  }

  @override
  Future<ValidasiResult<String>> validateAsync(String? value) async {
    return ValidasiResult.success(value ?? '');
  }
}
