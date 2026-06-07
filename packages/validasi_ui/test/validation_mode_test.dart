import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:validasi_ui/validasi_ui.dart';

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

Widget _buildForm({
  required ValidasiFormController<String> controller,
  ValidationMode mode = ValidationMode.onSubmit,
  ReValidationMode reValidateMode = ReValidationMode.onChange,
  ValidationMode? fieldMode,
  ReValidationMode? fieldReValidateMode,
  void Function(ValidasiFieldState<String> state)? onState,
}) {
  return MaterialApp(
    home: Scaffold(
      body: ValidasiForm<String>(
        controller: controller,
        mode: mode,
        reValidateMode: reValidateMode,
        child: Column(
          children: [
            ValidasiFormField<String, String>(
              field: const _TestKey(),
              mode: fieldMode,
              reValidateMode: fieldReValidateMode,
              builder: (context, state) {
                onState?.call(state);
                return TextField(
                  onChanged: state.onChanged,
                  decoration: InputDecoration(
                    errorText: state.errorText,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  group('ValidasiFormController - isSubmitted', () {
    test('isSubmitted starts as false', () {
      final controller = ValidasiFormController<String>();
      expect(controller.isSubmitted, false);
    });

    test('markSubmitted sets isSubmitted to true', () {
      final controller = ValidasiFormController<String>();
      controller.markSubmitted();
      expect(controller.isSubmitted, true);
    });

    test('reset clears isSubmitted', () {
      final controller = ValidasiFormController<String>();
      controller.markSubmitted();
      expect(controller.isSubmitted, true);

      controller.reset();
      expect(controller.isSubmitted, false);
    });
  });

  group('ValidationMode.onSubmit (default)', () {
    testWidgets('does not validate on onChanged', (tester) async {
      final controller = ValidasiFormController<String>();
      await tester.pumpWidget(_buildForm(controller: controller));

      final textField = find.byType(TextField);
      await tester.enterText(textField, '');
      await tester.pump();

      expect(controller.getErrors(const _TestKey()), isEmpty);
    });

    testWidgets('validates on explicit controller.validate()', (tester) async {
      final controller = ValidasiFormController<String>();
      await tester.pumpWidget(_buildForm(controller: controller));

      final result = controller.validate();
      expect(result, false);
      expect(controller.getErrors(const _TestKey()).length, 1);
    });

    testWidgets('validates on explicit controller.validateField()', (
      tester,
    ) async {
      final controller = ValidasiFormController<String>();
      await tester.pumpWidget(_buildForm(controller: controller));

      final result = controller.validateField(const _TestKey());
      expect(result, false);
      expect(controller.getErrors(const _TestKey()).length, 1);
    });
  });

  group('ValidationMode.onChange', () {
    testWidgets('validates after every onChanged call', (tester) async {
      final controller = ValidasiFormController<String>();
      await tester.pumpWidget(
        _buildForm(controller: controller, mode: ValidationMode.onChange),
      );

      final textField = find.byType(TextField);

      await tester.enterText(textField, 'a');
      await tester.pump();
      expect(controller.getErrors(const _TestKey()), isEmpty);

      await tester.enterText(textField, '');
      await tester.pump();
      expect(controller.getErrors(const _TestKey()).length, 1);

      await tester.enterText(textField, 'hello');
      await tester.pump();
      expect(controller.getErrors(const _TestKey()), isEmpty);
    });
  });

  group('ValidationMode.onBlur', () {
    testWidgets('does not validate on onChanged', (tester) async {
      final controller = ValidasiFormController<String>();
      await tester.pumpWidget(
        _buildForm(controller: controller, mode: ValidationMode.onBlur),
      );

      final textField = find.byType(TextField);
      await tester.enterText(textField, '');
      await tester.pump();

      expect(controller.getErrors(const _TestKey()), isEmpty);
    });

    testWidgets('validates when focus is lost', (tester) async {
      final controller = ValidasiFormController<String>();
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidasiForm<String>(
              controller: controller,
              mode: ValidationMode.onBlur,
              child: Column(
                children: [
                  ValidasiFormField<String, String>(
                    field: const _TestKey(),
                    builder: (context, state) {
                      return Focus(
                        focusNode: focusNode,
                        onFocusChange: state.onFocusChange,
                        child: TextField(
                          onChanged: state.onChanged,
                          decoration:
                              InputDecoration(errorText: state.errorText),
                        ),
                      );
                    },
                  ),
                  const TextField(),
                ],
              ),
            ),
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pump();

      final textField = find.byType(TextField).first;
      await tester.enterText(textField, '');
      await tester.pump();

      expect(controller.getErrors(const _TestKey()), isEmpty);

      final secondField = find.byType(TextField).last;
      await tester.tap(secondField);
      await tester.pump();

      expect(controller.getErrors(const _TestKey()).length, 1);
    });
  });

  group('Field-level mode override', () {
    testWidgets('field onChange overrides form onSubmit', (tester) async {
      final controller = ValidasiFormController<String>();
      await tester.pumpWidget(
        _buildForm(
          controller: controller,
          mode: ValidationMode.onSubmit,
          fieldMode: ValidationMode.onChange,
        ),
      );

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'a');
      await tester.pump();
      expect(controller.getErrors(const _TestKey()), isEmpty);

      await tester.enterText(textField, '');
      await tester.pump();
      expect(controller.getErrors(const _TestKey()).length, 1);
    });

    testWidgets('field onSubmit overrides form onChange', (tester) async {
      final controller = ValidasiFormController<String>();
      await tester.pumpWidget(
        _buildForm(
          controller: controller,
          mode: ValidationMode.onChange,
          fieldMode: ValidationMode.onSubmit,
        ),
      );

      final textField = find.byType(TextField);
      await tester.enterText(textField, '');
      await tester.pump();

      expect(controller.getErrors(const _TestKey()), isEmpty);
    });
  });

  group('ReValidationMode after submit', () {
    testWidgets('onChange reValidation validates on change after submit', (
      tester,
    ) async {
      final controller = ValidasiFormController<String>();
      await tester.pumpWidget(
        _buildForm(
          controller: controller,
          mode: ValidationMode.onSubmit,
          reValidateMode: ReValidationMode.onChange,
        ),
      );

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'ok');
      await tester.pump();

      expect(controller.getErrors(const _TestKey()), isEmpty);

      controller.markSubmitted();
      await tester.pump();

      await tester.enterText(textField, '');
      await tester.pump();

      expect(controller.getErrors(const _TestKey()).length, 1);
    });

    testWidgets('onBlur reValidation validates on blur after submit', (
      tester,
    ) async {
      final controller = ValidasiFormController<String>();
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidasiForm<String>(
              controller: controller,
              mode: ValidationMode.onSubmit,
              reValidateMode: ReValidationMode.onBlur,
              child: Column(
                children: [
                  ValidasiFormField<String, String>(
                    field: const _TestKey(),
                    builder: (context, state) {
                      return Focus(
                        focusNode: focusNode,
                        onFocusChange: state.onFocusChange,
                        child: TextField(
                          onChanged: state.onChanged,
                          decoration:
                              InputDecoration(errorText: state.errorText),
                        ),
                      );
                    },
                  ),
                  const TextField(),
                ],
              ),
            ),
          ),
        ),
      );

      controller.markSubmitted();
      await tester.pump();

      focusNode.requestFocus();
      await tester.pump();

      final secondField = find.byType(TextField).last;
      await tester.tap(secondField);
      await tester.pump();

      expect(controller.getErrors(const _TestKey()).length, 1);
    });

    testWidgets('reverts to original mode after reset', (tester) async {
      final controller = ValidasiFormController<String>();
      await tester.pumpWidget(
        _buildForm(
          controller: controller,
          mode: ValidationMode.onSubmit,
          reValidateMode: ReValidationMode.onChange,
        ),
      );

      controller.markSubmitted();
      await tester.pump();

      controller.reset();
      await tester.pump();

      expect(controller.isSubmitted, false);

      final textField = find.byType(TextField);
      await tester.enterText(textField, '');
      await tester.pump();

      expect(controller.getErrors(const _TestKey()), isEmpty);
    });
  });

  group('ReValidationMode field-level override', () {
    testWidgets('field reValidateMode overrides form reValidateMode', (
      tester,
    ) async {
      final controller = ValidasiFormController<String>();
      await tester.pumpWidget(
        _buildForm(
          controller: controller,
          mode: ValidationMode.onSubmit,
          reValidateMode: ReValidationMode.onChange,
          fieldReValidateMode: ReValidationMode.onBlur,
        ),
      );

      controller.markSubmitted();
      await tester.pump();

      final textField = find.byType(TextField);
      await tester.enterText(textField, '');
      await tester.pump();

      expect(controller.getErrors(const _TestKey()), isEmpty);
    });
  });

  group('ValidasiFieldState.onFocusChange', () {
    testWidgets('is provided in field state', (tester) async {
      ValidasiFieldState<String>? capturedState;
      final controller = ValidasiFormController<String>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidasiForm<String>(
              controller: controller,
              child: ValidasiFormField<String, String>(
                field: const _TestKey(),
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
      expect(capturedState!.onFocusChange, isNotNull);
    });
  });
}
