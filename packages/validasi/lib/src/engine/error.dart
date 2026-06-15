class ValidationError {
  ValidationError({
    required this.rule,
    required this.message,
    this.details,
    List<String>? path,
  }) : _path = path;

  final String rule;
  final String message;
  final Map<String, dynamic>? details;
  List<String>? _path;

  List<String>? get path => _path;

  void prefix(String segment) {
    if (_path != null) {
      _path!.insert(0, segment);
    } else {
      _path = [segment];
    }
  }
}
