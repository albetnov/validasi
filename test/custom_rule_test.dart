import 'dart:async';

import 'package:test/test.dart';
import 'package:validasi/src/custom_rule.dart';

class CustomRuleStub extends CustomRule<String> {
  @override
  FutureOr<bool> handle(String? value, FailFn fail) {
    throw UnimplementedError();
  }
}

void main() {
  group('Custom Rule Test', () {
    test('verify "FailFn" signature is correct', () {
      // ignore: prefer_function_declarations_over_variables
      FailFn fn = (message) {
        return false;
      };

      expect(fn, isA<bool Function(String message)>());
    });

    test('verify "CustomCallback" is similar to "handle" signature', () {
      var stub = CustomRuleStub();

      expect(stub.handle, isA<CustomCallback>());
    });
  });
}
