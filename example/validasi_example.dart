import 'package:validasi/src/utils/message.dart';

class Example {
  final String message;
  const Example(this.message);
}

void main() {
  var example = Example(Message('path', 'fallback', 'original').message);

  for (var i = 0; i < 10; i++) {
    print(example.message);
  }
}
