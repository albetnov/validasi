abstract class Rule<T> {
  const Rule(this.name, {this.message});

  final String name;
  final String? message;

  ValidateResult validate(T? value);
}

class ValidateResult {
  final bool isValid;
  final String? message;
  final bool isStop;
  final Map<String, String>? details;

  const ValidateResult({
    required this.isValid,
    this.message,
    this.isStop = false,
    this.details,
  });

  factory ValidateResult.success() => const ValidateResult(isValid: true);

  factory ValidateResult.stop({Map<String, String>? details}) =>
      ValidateResult(isValid: true, isStop: true, details: details);

  factory ValidateResult.failure(String message,
          {bool isStop = false, Map<String, String>? details}) =>
      ValidateResult(
          isValid: false, message: message, isStop: isStop, details: details);
}
