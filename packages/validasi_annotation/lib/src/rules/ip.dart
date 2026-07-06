import 'package:validasi_annotation/src/base.dart';

class Ipv4<T> extends Rule<T> {
  const Ipv4({super.message});
}

class Ipv6<T> extends Rule<T> {
  const Ipv6({super.message});
}

class Ip<T> extends Rule<T> {
  const Ip({super.message});
}
