import 'dart:async';

import 'package:validasi/src/validators/validator.dart';
import 'package:validasi/src/custom_rule.dart';

class ValidatorStub extends Validator<String> {
  @override
  ValidatorStub custom(CustomCallback<String> callback) {
    return super.custom(callback);
  }

  @override
  ValidatorStub customFor(CustomRule<String> customRule) {
    return super.customFor(customRule);
  }

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
