import 'package:validasi_annotation/validasi_annotation.dart';

@ValidateClass()
@RequiredAny(['email', 'phone'])
@DependsOn(field: 'password', dependsOn: 'passwordConfirmation')
@MatchesField(field: 'password', matchesField: 'passwordConfirmation')
class SignupForm {
  @Validate<String>([MinLength(1)])
  final String name;

  final String? email;
  final String? phone;
  final String? password;
  final String? passwordConfirmation;

  const SignupForm({
    required this.name,
    this.email,
    this.phone,
    this.password,
    this.passwordConfirmation,
  });
}

@ValidateClass()
@MutuallyExclusive('legacyId', 'newId')
@RequiredOneOf(['legacyId', 'newId'])
class IdMigration {
  @Validate<String>([MinLength(1)])
  final String name;

  final String? legacyId;
  final String? newId;

  const IdMigration({
    required this.name,
    this.legacyId,
    this.newId,
  });
}

@ValidateClass()
@RequiredAll(['start', 'end'])
class DateRange {
  @Validate<String>([MinLength(1)])
  final String name;

  final String? start;
  final String? end;

  const DateRange({required this.name, this.start, this.end});
}

@ValidateClass(generateFields: false, generateSchema: false)
@RequiredAny(['email', 'phone'])
class ContactOnly {
  final String? email;
  final String? phone;

  const ContactOnly({this.email, this.phone});
}
