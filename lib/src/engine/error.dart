class ValidationError {
  const ValidationError({
    required this.rule,
    required this.message,
    this.details,
  });

  final String rule;
  final String message;
  final Map<String, dynamic>? details;
}
