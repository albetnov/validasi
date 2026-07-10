import 'package:validasi_annotation/validasi_annotation.dart';

@ValidateClass()
class StringRulesModel {
  @Validate<String>([Alpha()])
  final String alpha;

  @Validate<String>([Alphanumeric()])
  final String alphanumeric;

  @Validate<String>([Numeric()])
  final String numeric;

  @Validate<String>([Lowercase()])
  final String lowercase;

  @Validate<String>([Uppercase()])
  final String uppercase;

  @Validate<String>([StartsWith('foo')])
  final String startsWith;

  @Validate<String>([EndsWith('bar')])
  final String endsWith;

  @Validate<String>([Regex(r'^[a-z]+$')])
  final String regex;

  @Validate<String>([Ulid()])
  final String ulid;

  @Validate<String>([Uuid()])
  final String uuid;

  @Validate<String>([Url()])
  final String url;

  @Validate<String>([Ipv4()])
  final String ipv4;

  @Validate<String>([Ipv6()])
  final String ipv6;

  @Validate<String>([Ip()])
  final String ip;

  @Validate<String>([Email()])
  final String email;

  @Validate<String>([Contains('needle')])
  final String contains;

  const StringRulesModel({
    required this.alpha,
    required this.alphanumeric,
    required this.numeric,
    required this.lowercase,
    required this.uppercase,
    required this.startsWith,
    required this.endsWith,
    required this.regex,
    required this.ulid,
    required this.uuid,
    required this.url,
    required this.ipv4,
    required this.ipv6,
    required this.ip,
    required this.email,
    required this.contains,
  });
}
