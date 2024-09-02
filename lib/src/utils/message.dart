/// [Message] is an validation message processor to parse template like `:name`
/// or maybe other (in the future?). The [Message] takes [path], [message], and
/// [fallback].
///
/// The [message] is optional. If the [message] is [null] then [fallback] will be
/// used instead.
///
/// The [parse] getter return parsed [message] or [fallback] based on above
/// description.
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
