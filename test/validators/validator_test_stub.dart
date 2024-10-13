import 'dart:async';

import 'package:mockito/annotations.dart';
import 'package:validasi/src/custom_rule.dart';
import 'package:validasi/src/validators/validator.dart';

@GenerateNiceMocks([MockSpec<Validator>()])
import 'validator_test_stub.mocks.dart';

class ValidatorStub extends Validator<String> {
  ValidatorStub({super.transformer});

  @override
  ValidatorStub nullable() => super.nullable();

  @override
  ValidatorStub custom(CustomCallback<String> callback) =>
      super.custom(callback);

  @override
  ValidatorStub customFor(CustomRule<String> customRule) =>
      super.customFor(customRule);

  void addRuleTest(String name, bool shouldPass, String message) {
    addRule(name: name, test: (value) => shouldPass, message: message);
  }

  @override
  void runCustom(String? value, String path) {
    super.runCustom(value, path);
  }

  @override
  Future<void> runCustomAsync(String? value, String path) {
    return super.runCustomAsync(value, path);
  }
}
