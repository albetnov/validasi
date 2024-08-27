class GroupError extends Error {
  final String message;

  GroupError(this.message);

  @override
  String toString() => message;
}
