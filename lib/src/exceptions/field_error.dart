class FieldError extends Error {
  final String name;
  final String path;
  final String message;
  late final String parent;
  late final String field;
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
