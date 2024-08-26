class Message {
  final String path;
  final String? _message;
  final String fallback;

  const Message(this.path, this.fallback, String? message) : _message = message;

  String get message =>
      _message != null ? _message.replaceAll(':name', path) : fallback;
}
