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

ValidasiFormController<String> _makeController() {
  return ValidasiFormController<String>(
    assembler: (ctrl) => '',
  );
}

void main() {
  group('foot-gun: validate() with async formValidator', () {
    test('throws StateError with clear message', () {
      final controller = ValidasiFormController<String>(
        assembler: (ctrl) => '',
        formValidator: (ctrl) async => ValidasiResult(
          errors: [],
          isValid: true,
        ),
      );

      expect(
        () => controller.validate(),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('async'),
          ),
        ),
      );
    });

    test('validateField works regardless of formValidator', () {
      final controller = ValidasiFormController<String>(
        assembler: (ctrl) => '',
        formValidator: (ctrl) async =>
            const ValidasiResult(errors: [], isValid: true),
      );
      const field = _TestKey('field');

      controller.setValue(field, 'x');
      expect(controller.validateField(field), isTrue);
    });
  });

  group('foot-gun: calling methods after dispose', () {
    test('getValue throws StateError', () {
      final controller = _makeController();
      const field = _TestKey('gone');

      controller.register(field);
      controller.dispose();

      expect(
        () => controller.getValue(field),
        throwsA(isA<StateError>()),
      );
    });

    test('setValue throws StateError', () {
      final controller = _makeController();
      const field = _TestKey('gone');

      controller.register(field);
      controller.dispose();

      expect(
        () => controller.setValue(field, 'x'),
        throwsA(isA<StateError>()),
      );
    });

    test('validateField throws StateError', () {
      final controller = _makeController();
      const field = _TestKey('gone');

      controller.register(field);
      controller.dispose();

      expect(
        () => controller.validateField(field),
        throwsA(isA<StateError>()),
      );
    });

    test('all getters throw StateError', () {
      final controller = _makeController();
      controller.dispose();

      expect(() => controller.isSubmitted, throwsA(isA<StateError>()));
      expect(() => controller.isDirty, throwsA(isA<StateError>()));
      expect(() => controller.isTouched, throwsA(isA<StateError>()));
      expect(() => controller.isValid, throwsA(isA<StateError>()));
      expect(() => controller.isPristine, throwsA(isA<StateError>()));
    });

    test('setError throws StateError', () {
      final controller = _makeController();
      const field = _TestKey('gone');

      controller.register(field);
      controller.dispose();

      expect(
        () => controller.setError(field, 'err'),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('foot-gun: setValue behavior', () {
    test('setValue on unregistered field auto-registers', () {
      final controller = _makeController();
      const field = _TestKey('auto');

      controller.setValue(field, 'injected');

      expect(controller.isFieldDirty(field), isTrue);
      expect(controller.getValue(field), 'injected');
    });

    test('setValue with null clears the value', () {
      final controller = _makeController();
      const field = _TestKey('nullify');

      controller.setValue(field, 'something');
      controller.setValue(field, null);

      expect(controller.getValue(field), isNull);
    });
  });

  group('foot-gun: setError on unregistered field', () {
    test('setError silently fails on unregistered field', () {
      final controller = _makeController();
      const field = _TestKey('err-before');

      controller.setError(field, 'silent');

      expect(controller.getFieldController(field).syncErrors, isEmpty);
    });
  });

  group('foot-gun: setFieldDisabled on unregistered field', () {
    test('auto-registers then disables', () {
      final controller = _makeController();
      const field = _TestKey('disable-auto');

      controller.setFieldDisabled(field, true);

      expect(controller.getFieldController(field).disabled, isTrue);
    });
  });

  group('foot-gun: validate() with registered fields', () {
    test('validate() passes for valid fields', () {
      final controller = _makeController();
      const field = _TestKey('valid');

      controller.setValue(field, 'ok');
      expect(controller.validate(), isTrue);
    });

    test('validateField on unregistered field returns true (no rules)', () {
      final controller = _makeController();
      const field = _TestKey('unreg');

      expect(controller.validateField(field), isTrue);
    });
  });
}
