/// [FieldError] used for stuff related to rules errors.
class FieldError extends Error {
  /// The name of failed rule.
  final String name;

  /// The path/key of failed validation.
  final String path;

  /// The error message
  final String message;

  /// The parent field (for nested based validation)
  late final String parent;

  /// The current field name
  late final String field;

  /// The full paths to the field (for nested based validation)
  late final List<String> paths;

  FieldError({required this.name, required this.message, required this.path}) {
    if (!path.contains('.')) {
      parent = path;
      field = path;
      paths = [path];

      return;
    }

    paths = path.split('.');
    parent = paths.first;
    field = paths.last;
  }

  @override
  String toString() {
    return message;
  }
}
