import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:validasi_ui/validasi_ui.dart';

class _TestModel {
  final String name;
  final String email;

  const _TestModel({required this.name, required this.email});
}

class _NameField extends ValidasiField<_TestModel, String> {
  const _NameField() : super();

  @override
  String get name => 'name';

  @override
  String? extract(_TestModel owner) => owner.name;

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

class _EmailField extends ValidasiField<_TestModel, String> {
  const _EmailField() : super();

  @override
  String get name => 'email';

  @override
  String? extract(_TestModel owner) => owner.email;

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

ValidasiFormController<_TestModel> _makeController() {
  return ValidasiFormController<_TestModel>(
    assembler: (ctrl) => _TestModel(
      name: ctrl.getValue(const _NameField()) ?? '',
      email: ctrl.getValue(const _EmailField()) ?? '',
    ),
  );
}

Widget _buildForm({
  required ValidasiFormController<_TestModel> controller,
  _TestModel? initialValues,
}) {
  return MaterialApp(
    home: Scaffold(
      body: ValidasiForm<_TestModel>(
        controller: controller,
        assembler: (ctrl) => _TestModel(
          name: ctrl.getValue(const _NameField()) ?? '',
          email: ctrl.getValue(const _EmailField()) ?? '',
        ),
        initialValues: initialValues,
        builder: (context, submit) => Column(
          children: [
            ValidasiFormField<_TestModel, String>(
              field: const _NameField(),
              builder: (context, state) => TextField(
                controller: TextEditingController(text: state.value ?? '')
                  ..selection = TextSelection.collapsed(
                    offset: (state.value ?? '').length,
                  ),
                onChanged: state.onChanged,
                decoration: InputDecoration(errorText: state.errorText),
              ),
            ),
            ValidasiFormField<_TestModel, String>(
              field: const _EmailField(),
              builder: (context, state) => TextField(
                controller: TextEditingController(text: state.value ?? '')
                  ..selection = TextSelection.collapsed(
                    offset: (state.value ?? '').length,
                  ),
                onChanged: state.onChanged,
                decoration: InputDecoration(errorText: state.errorText),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  group('InitialValues', () {
    test('setInitialValues seeds registered fields', () {
      final controller = _makeController();
      const nameField = _NameField();
      const emailField = _EmailField();

      controller.register(nameField);
      controller.register(emailField);

      const model = _TestModel(name: 'Alice', email: 'alice@test.com');
      controller.setInitialValues(model);

      expect(controller.getValue(nameField), 'Alice');
      expect(controller.getValue(emailField), 'alice@test.com');
    });

    test('register after setInitialValues extracts from model', () {
      final controller = _makeController();
      const nameField = _NameField();
      const emailField = _EmailField();

      const model = _TestModel(name: 'Bob', email: 'bob@test.com');
      controller.setInitialValues(model);

      controller.register(nameField);
      controller.register(emailField);

      expect(controller.getValue(nameField), 'Bob');
      expect(controller.getValue(emailField), 'bob@test.com');
    });

    testWidgets('form initialValues seeds all fields', (tester) async {
      final controller = _makeController();
      const model = _TestModel(name: 'Charlie', email: 'charlie@test.com');

      await tester.pumpWidget(_buildForm(
        controller: controller,
        initialValues: model,
      ));

      expect(controller.getValue(const _NameField()), 'Charlie');
      expect(controller.getValue(const _EmailField()), 'charlie@test.com');
    });
  });

  group('Dirty / Pristine tracking', () {
    test('field starts pristine with no initialValues', () {
      final controller = _makeController();
      const nameField = _NameField();

      controller.register(nameField);

      expect(controller.isFieldDirty(nameField), false);
    });

    test('field starts pristine with initialValues', () {
      final controller = _makeController();
      const nameField = _NameField();

      const model = _TestModel(name: 'Alice', email: 'alice@test.com');
      controller.setInitialValues(model);
      controller.register(nameField);

      expect(controller.isFieldDirty(nameField), false);
    });

    test('field becomes dirty after setValue', () {
      final controller = _makeController();
      const nameField = _NameField();

      const model = _TestModel(name: 'Alice', email: 'alice@test.com');
      controller.setInitialValues(model);
      controller.register(nameField);

      controller.setValue(nameField, 'Bob');

      expect(controller.isFieldDirty(nameField), true);
    });

    test('field returns pristine after setValue back to initial', () {
      final controller = _makeController();
      const nameField = _NameField();

      const model = _TestModel(name: 'Alice', email: 'alice@test.com');
      controller.setInitialValues(model);
      controller.register(nameField);

      controller.setValue(nameField, 'Bob');
      expect(controller.isFieldDirty(nameField), true);

      controller.setValue(nameField, 'Alice');
      expect(controller.isFieldDirty(nameField), false);
    });

    test('form-wide isDirty reflects any dirty field', () {
      final controller = _makeController();
      const nameField = _NameField();
      const emailField = _EmailField();

      const model = _TestModel(name: 'Alice', email: 'alice@test.com');
      controller.setInitialValues(model);
      controller.register(nameField);
      controller.register(emailField);

      expect(controller.isDirty, false);
      expect(controller.isPristine, true);

      controller.setValue(nameField, 'Bob');

      expect(controller.isDirty, true);
      expect(controller.isPristine, false);
    });
  });

  group('Touched tracking', () {
    test('field starts untouched', () {
      final controller = _makeController();
      const nameField = _NameField();

      controller.register(nameField);

      expect(controller.isFieldTouched(nameField), false);
      expect(controller.isTouched, false);
    });

    test('field becomes touched after setValue', () {
      final controller = _makeController();
      const nameField = _NameField();

      controller.register(nameField);
      controller.setValue(nameField, 'test');

      expect(controller.isFieldTouched(nameField), true);
      expect(controller.isTouched, true);
    });
  });

  group('Reset restores initial values', () {
    test('reset restores to initial values, not null', () {
      final controller = _makeController();
      const nameField = _NameField();
      const emailField = _EmailField();

      const model = _TestModel(name: 'Alice', email: 'alice@test.com');
      controller.setInitialValues(model);
      controller.register(nameField);
      controller.register(emailField);

      controller.setValue(nameField, 'Bob');
      controller.setValue(emailField, 'bob@test.com');

      controller.reset();

      expect(controller.getValue(nameField), 'Alice');
      expect(controller.getValue(emailField), 'alice@test.com');
    });

    test('reset clears touched state', () {
      final controller = _makeController();
      const nameField = _NameField();

      const model = _TestModel(name: 'Alice', email: 'alice@test.com');
      controller.setInitialValues(model);
      controller.register(nameField);

      controller.setValue(nameField, 'Bob');
      expect(controller.isFieldTouched(nameField), true);

      controller.reset();

      expect(controller.isFieldTouched(nameField), false);
      expect(controller.isTouched, false);
    });

    test('reset clears isSubmitted', () {
      final controller = _makeController();

      controller.markSubmitted();
      expect(controller.isSubmitted, true);

      controller.reset();
      expect(controller.isSubmitted, false);
    });

    test('reset without initialValues restores to null', () {
      final controller = _makeController();
      const nameField = _NameField();

      controller.register(nameField);
      controller.setValue(nameField, 'Bob');

      controller.reset();

      expect(controller.getValue(nameField), isNull);
    });
  });
}
