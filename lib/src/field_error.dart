class FieldError extends Error {
  final String name;
  final String path;
  final String message;
  late final String parent;
  late final String field;

  FieldError({required this.name, required this.message, required this.path}) {
    if (!path.contains('.')) {
      parent = path;
      field = path;

      return;
    }

    var paths = path.split('.');
    parent = paths.first;
    field = paths.last;
  }

  @override
  String toString() {
    return message;
  }
}
