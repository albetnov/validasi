abstract class Rule<T> {
  int get opcode;
}

abstract class StringRule implements Rule<String> {}

abstract class ListRule implements Rule<List> {}
