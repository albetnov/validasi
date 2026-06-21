import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:validasi/validasi.dart';
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

ValidasiFormController<String> _makeController() {
  return ValidasiFormController<String>(
    assembler: (ctrl) => ctrl.getValue(const _TestKey()) ?? '',
  );
}

void main() {
  group('async validation', () {
    group('controller-level', () {
      test('setFieldValidator stores validator and returns async error',
          () async {
        final controller = _makeController();
        const field = _TestKey();

        controller.register(field, initialValue: 'test');
        controller.setFieldValidator(
          field,
          (value) async => value == 'taken' ? 'Already taken' : null,
          debounce: Duration.zero,
        );

        await controller.triggerAsyncValidation(field);
        await Future<void>.delayed(Duration.zero);

        expect(controller.getErrors(field), isEmpty);
      });

      test('async validation sets error when validator returns message',
          () async {
        final controller = _makeController();
        const field = _TestKey();

        controller.register(field, initialValue: 'taken');
        controller.setFieldValidator(
          field,
          (value) async => value == 'taken' ? 'Already taken' : null,
          debounce: Duration.zero,
        );

        await controller.triggerAsyncValidation(field);
        await Future<void>.delayed(Duration.zero);

        expect(controller.getErrors(field).length, 1);
        expect(controller.getErrors(field).first.message, 'Already taken');
      });

      test('async validation result is discarded when value changes', () async {
        final controller = _makeController();
        const field = _TestKey();
        String? lastValue;

        controller.register(field, initialValue: 'first');
        controller.setFieldValidator(
          field,
          (value) async {
            lastValue = value;
            await Future<void>.delayed(Duration.zero);
            return value == 'error' ? 'Error' : null;
          },
          debounce: Duration.zero,
        );

        controller.triggerAsyncValidation(field);
        await Future<void>.delayed(Duration.zero);
        expect(lastValue, 'first');

        controller.setValue(field, 'error');
        await controller.triggerAsyncValidation(field);
        await Future<void>.delayed(Duration.zero);

        expect(lastValue, 'error');
        expect(controller.getErrors(field), isEmpty);
      });

      test('async errors persist across sync validate()', () async {
        final controller = _makeController();
        const field = _TestKey();

        controller.register(field, initialValue: 'taken');
        controller.setFieldValidator(
          field,
          (value) async => value == 'taken' ? 'Already taken' : null,
          debounce: Duration.zero,
        );

        await controller.triggerAsyncValidation(field);
        await Future<void>.delayed(Duration.zero);
        expect(controller.getErrors(field).length, 1);

        controller.validate();
        expect(controller.getErrors(field).length, 1);
        expect(controller.getErrors(field).first.message, 'Already taken');
      });

      test('clearErrors clears both sync and async errors', () async {
        final controller = _makeController();
        const field = _TestKey();

        controller.register(field, initialValue: '');
        controller.validate();
        expect(controller.getErrors(field).length, 1);

        controller.setFieldValidator(
          field,
          (value) async => 'Async error',
          debounce: Duration.zero,
        );

        await controller.triggerAsyncValidation(field);
        await Future<void>.delayed(Duration.zero);
        expect(controller.getErrors(field).length, 2);

        controller.clearErrors(field);
        expect(controller.getErrors(field), isEmpty);
      });

      test('clearAllErrors clears both sync and async errors', () async {
        final controller = _makeController();
        const field = _TestKey();

        controller.register(field, initialValue: '');
        controller.validate();
        controller.setFieldValidator(
          field,
          (value) async => 'Async error',
          debounce: Duration.zero,
        );

        await controller.triggerAsyncValidation(field);
        await Future<void>.delayed(Duration.zero);

        controller.clearAllErrors();
        expect(controller.getErrors(field), isEmpty);
      });

      test('reset clears async errors', () async {
        final controller = _makeController();
        const field = _TestKey();

        controller.register(field, initialValue: 'taken');
        controller.setFieldValidator(
          field,
          (value) async => 'Async error',
          debounce: Duration.zero,
        );

        await controller.triggerAsyncValidation(field);
        await Future<void>.delayed(Duration.zero);
        expect(controller.getErrors(field).length, 1);

        controller.reset();
        expect(controller.getErrors(field), isEmpty);
      });

      test('disabled field skips async validation', () async {
        final controller = _makeController();
        const field = _TestKey();

        controller.register(field, initialValue: 'test');
        controller.setFieldValidator(
          field,
          (value) async => 'Should not run',
          debounce: Duration.zero,
        );

        controller.getFieldController<String>(field).disabled = true;
        await controller.triggerAsyncValidation(field);
        await Future<void>.delayed(Duration.zero);

        expect(controller.getErrors(field), isEmpty);
      });

      test('isValid considers async errors', () async {
        final controller = _makeController();
        const field = _TestKey();

        controller.register(field, initialValue: 'valid');
        controller.setFieldValidator(
          field,
          (value) async => 'Async error',
          debounce: Duration.zero,
        );

        expect(controller.isValid, isTrue);

        await controller.triggerAsyncValidation(field);
        await Future<void>.delayed(Duration.zero);

        expect(controller.isValid, isFalse);
      });

      test('validator set to null clears async error', () async {
        final controller = _makeController();
        const field = _TestKey();

        controller.register(field, initialValue: 'test');
        controller.setFieldValidator(
          field,
          (value) async => 'Async error',
          debounce: Duration.zero,
        );

        await controller.triggerAsyncValidation(field);
        await Future<void>.delayed(Duration.zero);
        expect(controller.getErrors(field).length, 1);

        controller.setFieldValidator(field, null);
        expect(controller.getErrors(field), isEmpty);
      });

      test('isValidating is set during async validation', () async {
        final controller = _makeController();
        const field = _TestKey();
        final completer = Completer<String?>();

        controller.register(field, initialValue: 'test');
        controller.setFieldValidator(
          field,
          (value) async => await completer.future,
          debounce: Duration.zero,
        );

        controller.triggerAsyncValidation(field);
        await Future<void>.delayed(Duration.zero);

        expect(
          controller.getFieldController<String>(field).isValidating,
          isTrue,
        );

        completer.complete('Error');
        await Future<void>.delayed(Duration.zero);

        expect(
          controller.getFieldController<String>(field).isValidating,
          isFalse,
        );
      });

      test('setError does not duplicate async error', () async {
        final controller = _makeController();
        const field = _TestKey();

        controller.register(field, initialValue: 'test');
        controller.setFieldValidator(
          field,
          (value) async => 'Async error',
          debounce: Duration.zero,
        );

        await controller.triggerAsyncValidation(field);
        await Future<void>.delayed(Duration.zero);
        expect(controller.getErrors(field).length, 1);

        controller.setError(field, 'Manual error');
        expect(controller.getErrors(field).length, 2);
        expect(
          controller.getErrors(field).where((e) => e.rule == 'async').length,
          1,
        );
      });

      test('setFieldValidator null clears async error and syncs', () async {
        final controller = _makeController();
        const field = _TestKey();

        controller.register(field, initialValue: 'test');
        controller.setFieldValidator(
          field,
          (value) async => 'Async error',
          debounce: Duration.zero,
        );

        await controller.triggerAsyncValidation(field);
        await Future<void>.delayed(Duration.zero);
        expect(controller.fieldErrors.first.errors.length, 1);

        controller.setFieldValidator(field, null);
        expect(controller.getErrors(field), isEmpty);
        expect(controller.fieldErrors.first.errors, isEmpty);
      });

      test('disabling field clears async error', () async {
        final controller = _makeController();
        const field = _TestKey();

        controller.register(field, initialValue: 'test');
        controller.setFieldValidator(
          field,
          (value) async => 'Async error',
          debounce: Duration.zero,
        );

        await controller.triggerAsyncValidation(field);
        await Future<void>.delayed(Duration.zero);
        expect(controller.getErrors(field).length, 1);

        controller.setFieldDisabled(field, true);
        expect(controller.getErrors(field), isEmpty);
      });

      test('setInitialValues cancels pending async validation', () async {
        final controller = _makeController();
        const field = _TestKey();
        final completer = Completer<String?>();
        var callCount = 0;

        controller.register(field, initialValue: 'first');
        controller.setFieldValidator(
          field,
          (value) async {
            callCount++;
            return await completer.future;
          },
          debounce: Duration.zero,
        );

        controller.triggerAsyncValidation(field);
        await Future<void>.delayed(Duration.zero);
        expect(controller.getFieldController<String>(field).isValidating, true);

        controller.setInitialValues('second');
        expect(
            controller.getFieldController<String>(field).isValidating, false);

        completer.complete('Error');
        await Future<void>.delayed(Duration.zero);

        expect(callCount, 1);
        expect(controller.getErrors(field), isEmpty);
      });
    });
  });
}
