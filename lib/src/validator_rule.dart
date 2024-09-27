import 'package:validasi/src/exceptions/field_error.dart';
import 'package:validasi/src/utils/message.dart';

/// The [ValidatorRule] represent each of rules available for each
/// Validators.
class ValidatorRule<T> {
  /// The [test] function will run and expect [bool] for the return value
  /// to determine whatever it passes or not.
  final bool Function(T value) test;

  /// The [_isPassed] will then be changed based on return value of [test].
  bool _isPassed = false;

  /// Error message to be displayed
  final String message;

  /// The name of the rule
  final String name;

  ValidatorRule({
    required this.name,
    required this.test,
    required this.message,
  });

  /// The rule should be runned using [check] instead of [test]. So the [passed]
  /// value can be properly tracked.
  void check(T value) {
    var result = test(value);

    _isPassed = result;
  }

  /// This getter simply acts to return [_isPassed].
  bool get passed => _isPassed;

  /// Map the rule to [FieldError], should be executed when the rule
  /// is failing. [toFieldError] use [Message] under the hood to parse
  /// custom template.
  FieldError toFieldError(String path) => FieldError(
      path: path, name: name, message: Message(path, message: message).parse);
}
