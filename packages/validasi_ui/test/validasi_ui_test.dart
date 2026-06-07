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

void main() {
  group('ValidasiFormController', () {
    test('getValue and setValue are type-safe', () {
      final controller = ValidasiFormController<String>();
      const field = _TestKey();

      controller.register(field, initialValue: 'hello');

      final value = controller.getValue(field);
      expect(value, 'hello');

      controller.setValue(field, 'world');
      expect(controller.getValue(field), 'world');

      controller.reset();
      expect(controller.getValue(field), 'hello');
    });

    test('validateField runs the generated validator', () {
      final controller = ValidasiFormController<String>();
      const field = _TestKey();

      controller.register(field);
      expect(controller.validateField(field), false);
      expect(controller.getErrors(field).length, 1);

      controller.setValue(field, 'ok');
      expect(controller.validateField(field), true);
      expect(controller.getErrors(field), isEmpty);
    });

    test('validate runs all registered fields', () {
      final controller = ValidasiFormController<String>();
      const field = _TestKey();

      controller.register(field);
      expect(controller.validate(), false);

      controller.setValue(field, 'ok');
      expect(controller.validate(), true);
    });
  });
}
