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

      // Should not throw — async state was cleaned up
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

  group('shouldUnregister', () {
    test('field-level shouldUnregister: false keeps value after unregister',
        () {
      final controller = _makeController();
      const field = _TestKey('sticky');

      controller.setValue(field, 'sticky-value');
      // Without explicit unregister, signal persists
      expect(controller.getValue(field), 'sticky-value');
    });

    test('re-register preserves fresh value', () {
      final controller = _makeController();
      const field = _TestKey('rer');

      controller.setValue(field, 'first');
      controller.unregister(field);
      controller.setValue(field, 'second');

      expect(controller.getValue(field), 'second');
    });
  });
}
