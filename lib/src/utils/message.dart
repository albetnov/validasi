/// A class that represents a message.
///
/// The [Message] class is used to represent a message that can be parsed
/// with a [path] and a [_fallback] message.
class Message {
  final String path;
  final String? _message;
  final String _fallback;

  const Message(this.path,
      {String fallback = ':name is not valid', String? message})
      : _message = message,
        _fallback = fallback;

  /// The [parse] getter return parsed `message`
  /// if not null or `fallback` if `message` is null.
  String get parse => _message != null
      ? _message.replaceAll(':name', path)
      : _fallback.replaceAll(':name', path);
}
