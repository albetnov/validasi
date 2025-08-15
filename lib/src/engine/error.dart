class ValidationError {
  const ValidationError({
    required this.rule,
    required this.message,
    this.details,
    this.prefix,
  });

  final String rule;
  final String message;
  final Map<String, dynamic>? details;
  final List<String>? prefix;

  ValidationError withPrefix(String prefix) {
    return ValidationError(
      rule: rule,
      message: message,
      details: details,
      prefix: [...?this.prefix, prefix],
    );
  }
}
