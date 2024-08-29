class Message {
  final String path;
  final String? message;
  final String fallback;

  const Message(this.path,
      {this.fallback = ':name is not valid', this.message});

  String get parse => message != null
      ? message!.replaceAll(':name', path)
      : fallback.replaceAll(':name', path);
}
