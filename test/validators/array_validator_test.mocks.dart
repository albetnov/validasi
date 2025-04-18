// Mocks generated by Mockito 5.4.4 from annotations
// in validasi/test/validators/array_validator_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i7;

import 'package:mockito/mockito.dart' as _i1;
import 'package:validasi/src/custom_rule.dart' as _i5;
import 'package:validasi/src/result.dart' as _i2;
import 'package:validasi/src/transformers/transformer.dart' as _i6;
import 'package:validasi/src/validator_rule.dart' as _i4;
import 'package:validasi/src/validators/validator.dart' as _i3;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeResult_0<T1> extends _i1.SmartFake implements _i2.Result<T1> {
  _FakeResult_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [Validator].
///
/// See the documentation for Mockito's code generation for more information.
class MockValidator<T> extends _i1.Mock implements _i3.Validator<T> {
  @override
  Map<String, _i4.ValidatorRule<T>> get rules => (super.noSuchMethod(
        Invocation.getter(#rules),
        returnValue: <String, _i4.ValidatorRule<T>>{},
        returnValueForMissingStub: <String, _i4.ValidatorRule<T>>{},
      ) as Map<String, _i4.ValidatorRule<T>>);

  @override
  set customCallback(_i5.CustomCallback<T?>? _customCallback) =>
      super.noSuchMethod(
        Invocation.setter(
          #customCallback,
          _customCallback,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set transformer(_i6.Transformer<T>? _transformer) => super.noSuchMethod(
        Invocation.setter(
          #transformer,
          _transformer,
        ),
        returnValueForMissingStub: null,
      );

  @override
  void addRule({
    required String? name,
    required bool Function(T)? test,
    required String? message,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #addRule,
          [],
          {
            #name: name,
            #test: test,
            #message: message,
          },
        ),
        returnValueForMissingStub: null,
      );

  @override
  dynamic custom(_i5.CustomCallback<T>? callback) => super.noSuchMethod(
        Invocation.method(
          #custom,
          [callback],
        ),
        returnValueForMissingStub: null,
      );

  @override
  dynamic customFor(_i5.CustomRule<T>? customRule) => super.noSuchMethod(
        Invocation.method(
          #customFor,
          [customRule],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void runCustom(
    T? value,
    String? path,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #runCustom,
          [
            value,
            path,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i7.Future<void> runCustomAsync(
    T? value,
    String? path,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #runCustomAsync,
          [
            value,
            path,
          ],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i2.Result<T> tryParse(
    dynamic value, {
    String? path = r'field',
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #tryParse,
          [value],
          {#path: path},
        ),
        returnValue: _FakeResult_0<T>(
          this,
          Invocation.method(
            #tryParse,
            [value],
            {#path: path},
          ),
        ),
        returnValueForMissingStub: _FakeResult_0<T>(
          this,
          Invocation.method(
            #tryParse,
            [value],
            {#path: path},
          ),
        ),
      ) as _i2.Result<T>);

  @override
  _i7.Future<_i2.Result<T>> tryParseAsync(
    dynamic value, {
    String? path = r'field',
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #tryParseAsync,
          [value],
          {#path: path},
        ),
        returnValue: _i7.Future<_i2.Result<T>>.value(_FakeResult_0<T>(
          this,
          Invocation.method(
            #tryParseAsync,
            [value],
            {#path: path},
          ),
        )),
        returnValueForMissingStub:
            _i7.Future<_i2.Result<T>>.value(_FakeResult_0<T>(
          this,
          Invocation.method(
            #tryParseAsync,
            [value],
            {#path: path},
          ),
        )),
      ) as _i7.Future<_i2.Result<T>>);

  @override
  _i2.Result<T> parse(
    dynamic value, {
    String? path = r'field',
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #parse,
          [value],
          {#path: path},
        ),
        returnValue: _FakeResult_0<T>(
          this,
          Invocation.method(
            #parse,
            [value],
            {#path: path},
          ),
        ),
        returnValueForMissingStub: _FakeResult_0<T>(
          this,
          Invocation.method(
            #parse,
            [value],
            {#path: path},
          ),
        ),
      ) as _i2.Result<T>);

  @override
  _i7.Future<_i2.Result<T>> parseAsync(
    dynamic value, {
    String? path = r'field',
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #parseAsync,
          [value],
          {#path: path},
        ),
        returnValue: _i7.Future<_i2.Result<T>>.value(_FakeResult_0<T>(
          this,
          Invocation.method(
            #parseAsync,
            [value],
            {#path: path},
          ),
        )),
        returnValueForMissingStub:
            _i7.Future<_i2.Result<T>>.value(_FakeResult_0<T>(
          this,
          Invocation.method(
            #parseAsync,
            [value],
            {#path: path},
          ),
        )),
      ) as _i7.Future<_i2.Result<T>>);
}
