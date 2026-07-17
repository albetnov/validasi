import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:validasi_ui/validasi_ui.dart';
import 'package:validasi/validasi.dart';

class _TestKey extends ValidasiField<String, String> {
  const _TestKey() : super();

  @override
  String get name => 'test';

  @override
  String? extract(String owner) => owner;

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

class _SecondKey extends ValidasiField<String, String> {
  const _SecondKey() : super();

  @override
  String get name => 'second';

  @override
  String? extract(String owner) => owner;

  @override
  ValidasiResult<String> validate(String? value) =>
      ValidasiResult.success(value);
}

class _AsyncKey extends ValidasiField<String, String> {
  const _AsyncKey() : super();

  @override
  String get name => 'async';

  @override
  String? extract(String owner) => owner;

  @override
  ValidasiResult<String> validate(String? value) =>
      ValidasiResult.success(value);

  @override
  Future<ValidasiResult<String>> validateAsync(String? value) async {
    await Future<void>.delayed(Duration.zero);
    return ValidasiResult.error(
      ValidationError(rule: 'Async', message: 'Async error'),
    );
  }
}

const _stringSchema = _StringSchema();

class _StringSchema extends ValidasiSchema<String> {
  const _StringSchema();
  @override
  String allocate(ValidasiFieldReader<String> reader) =>
      reader.getValue(const _TestKey()) ?? '';
}

ValidasiFormController<String> _makeController() {
  return ValidasiFormController(schema: _stringSchema);
}

void main() {
  group('disabled field state', () {
    group('controller-level', () {
      test('setValue is no-op for disabled field', () {
        final controller = _makeController();
        const field = _TestKey();

        controller.register(field, initialValue: 'hello');
        controller.getFieldController(field).disabled = true;
        controller.setValue(field, 'world');

        expect(controller.getValue(field), 'hello');
      });

      test('validate() skips disabled fields', () {
        final controller = _makeController();
        const field = _TestKey();

        controller.register(field);
        controller.getFieldController(field).disabled = true;
        controller.validate();

        expect(controller.getErrors(field), isEmpty);
        expect(controller.isValid, isTrue);
      });

      test('validateField() skips disabled field', () {
        final controller = _makeController();
        const field = _TestKey();

        controller.register(field);
        controller.getFieldController(field).disabled = true;
        final result = controller.validateField(field);

        expect(result, isTrue);
        expect(controller.getErrors(field), isEmpty);
      });

      test('getValues() omits disabled fields', () {
        final controller = _makeController();
        const field = _TestKey();
        const second = _SecondKey();

        controller.register(field, initialValue: 'hello');
        controller.register(second, initialValue: 'world');
        controller.getFieldController(field).disabled = true;

        final values = controller.getValues();
        expect(values.length, 1);
        expect(values.containsKey(field), isFalse);
        expect(values[second], 'world');
      });

      test('setError() skips disabled field', () {
        final controller = _makeController();
        const field = _TestKey();

        controller.register(field);
        controller.getFieldController(field).disabled = true;
        controller.setError(field, 'Manual error');

        expect(controller.getErrors(field), isEmpty);
      });

      test('clearErrors() skips disabled field', () {
        final controller = _makeController();
        const field = _TestKey();

        controller.register(field);
        controller.validate();
        expect(controller.getErrors(field).length, 1);

        controller.getFieldController(field).disabled = true;
        controller.clearErrors(field);

        expect(controller.getErrors(field).length, 1);
      });

      test('isDirty aggregate excludes disabled fields', () {
        final controller = _makeController();
        const field = _TestKey();
        const second = _SecondKey();

        controller.register(field, initialValue: 'hello');
        controller.register(second, initialValue: 'world');
        controller.getFieldController(field).disabled = true;

        controller.setValue(second, 'changed');
        expect(controller.isDirty, isTrue);
      });

      test('isDirty aggregate stays false when only disabled field changes',
          () {
        final controller = _makeController();
        const field = _TestKey();

        controller.register(field, initialValue: 'hello');
        final fc = controller.getFieldController(field);
        fc.disabled = true;
        fc.value = 'changed';

        expect(controller.isDirty, isFalse);
      });

      test('isTouched aggregate excludes disabled fields', () {
        final controller = _makeController();
        const field = _TestKey();

        controller.register(field);
        final fc = controller.getFieldController(field);
        fc.disabled = true;
        fc.markTouched();

        expect(controller.isTouched, isFalse);
      });

      test('isValid excludes disabled invalid fields', () {
        final controller = _makeController();
        const field = _TestKey();

        controller.register(field);
        controller.validate();
        expect(controller.isValid, isFalse);

        controller.getFieldController(field).disabled = true;
        expect(controller.isValid, isTrue);
      });

      test('validateAsync() skips disabled fields', () async {
        final controller = _makeController();
        const field = _AsyncKey();

        controller.register(field);
        controller.getFieldController(field).disabled = true;
        final result = await controller.validateAsync();

        expect(result, isTrue);
        expect(controller.getErrors(field), isEmpty);
      });

      test('getValue() still returns value for disabled field', () {
        final controller = _makeController();
        const field = _TestKey();

        controller.register(field, initialValue: 'hello');
        controller.getFieldController(field).disabled = true;

        expect(controller.getValue(field), 'hello');
      });
    });

    group('widget-level', () {
      testWidgets('ValidasiFormField.disabled=true passes disabled to state', (
        tester,
      ) async {
        ValidasiFieldState<String>? capturedState;
        final controller = _makeController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ValidasiForm(
                controller: controller,
                builder: (context, submit) => ValidasiFormField(
                  field: const _TestKey(),
                  disabled: true,
                  builder: (context, state) {
                    capturedState = state;
                    return TextField(onChanged: state.onChanged);
                  },
                ),
              ),
            ),
          ),
        );

        expect(capturedState, isNotNull);
        expect(capturedState!.disabled, isTrue);
      });

      testWidgets('onChanged is no-op when disabled', (tester) async {
        final controller = _makeController();
        const field = _TestKey();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ValidasiForm(
                controller: controller,
                builder: (context, submit) => ValidasiFormField(
                  field: field,
                  disabled: true,
                  builder: (context, state) {
                    return TextField(onChanged: state.onChanged);
                  },
                ),
              ),
            ),
          ),
        );

        final textField = find.byType(TextField);
        await tester.enterText(textField, 'new value');
        await tester.pump();

        expect(controller.getValue(const _TestKey()), isNull);
      });

      testWidgets('errors are cleared when field becomes disabled', (
        tester,
      ) async {
        final controller = _makeController();
        const field = _TestKey();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ValidasiForm(
                controller: controller,
                builder: (context, submit) => ValidasiFormField(
                  field: field,
                  disabled: false,
                  builder: (context, state) {
                    return TextField(onChanged: state.onChanged);
                  },
                ),
              ),
            ),
          ),
        );

        controller.validate();
        await tester.pump();
        expect(controller.getErrors(field).length, 1);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ValidasiForm(
                controller: controller,
                builder: (context, submit) => ValidasiFormField(
                  field: field,
                  disabled: true,
                  builder: (context, state) {
                    return TextField(onChanged: state.onChanged);
                  },
                ),
              ),
            ),
          ),
        );

        expect(controller.getErrors(field), isEmpty);
      });

      testWidgets('onFocusChange is null when disabled', (tester) async {
        ValidasiFieldState<String>? capturedState;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ValidasiForm(
                schema: _stringSchema,
                builder: (context, submit) => ValidasiFormField(
                  field: const _TestKey(),
                  disabled: true,
                  builder: (context, state) {
                    capturedState = state;
                    return TextField(onChanged: state.onChanged);
                  },
                ),
              ),
            ),
          ),
        );

        expect(capturedState!.onFocusChange, isNull);
      });

      testWidgets('setError is null when disabled', (tester) async {
        ValidasiFieldState<String>? capturedState;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ValidasiForm(
                schema: _stringSchema,
                builder: (context, submit) => ValidasiFormField(
                  field: const _TestKey(),
                  disabled: true,
                  builder: (context, state) {
                    capturedState = state;
                    return TextField(onChanged: state.onChanged);
                  },
                ),
              ),
            ),
          ),
        );

        expect(capturedState!.setError, isNull);
      });

      testWidgets('clearErrors is null when disabled', (tester) async {
        ValidasiFieldState<String>? capturedState;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ValidasiForm(
                schema: _stringSchema,
                builder: (context, submit) => ValidasiFormField(
                  field: const _TestKey(),
                  disabled: true,
                  builder: (context, state) {
                    capturedState = state;
                    return TextField(onChanged: state.onChanged);
                  },
                ),
              ),
            ),
          ),
        );

        expect(capturedState!.clearErrors, isNull);
      });
    });
  });
}
