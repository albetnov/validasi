import 'package:test/test.dart';
import 'package:validasi/src/engine/state.dart';
import 'package:validasi/src/rules/string/ip.dart';

void main() {
  group('Ipv4 (String)', () {
    test('should pass with valid IPv4', () {
      final rule = Ipv4();
      final state = ValidationState();

      rule.apply('192.168.1.1', state);

      expect(state.errors, isEmpty);
    });

    test('should pass with 0.0.0.0', () {
      final rule = Ipv4();
      final state = ValidationState();

      rule.apply('0.0.0.0', state);

      expect(state.errors, isEmpty);
    });

    test('should pass with 255.255.255.255', () {
      final rule = Ipv4();
      final state = ValidationState();

      rule.apply('255.255.255.255', state);

      expect(state.errors, isEmpty);
    });

    test('should fail with out of range octets', () {
      final rule = Ipv4();
      final state = ValidationState();

      rule.apply('256.1.1.1', state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('Ipv4'));
      expect(
          state.errors.first.message, equals('Must be a valid IPv4 address'));
    });

    test('should fail with leading zeros', () {
      final rule = Ipv4();
      final state = ValidationState();

      rule.apply('192.168.01.1', state);

      expect(state.errors.length, equals(1));
    });

    test('should fail with too few octets', () {
      final rule = Ipv4();
      final state = ValidationState();

      rule.apply('192.168.1', state);

      expect(state.errors.length, equals(1));
    });

    test('should fail with too many octets', () {
      final rule = Ipv4();
      final state = ValidationState();

      rule.apply('192.168.1.1.1', state);

      expect(state.errors.length, equals(1));
    });

    test('should use custom message', () {
      final rule = Ipv4(message: 'Invalid IP!');
      final state = ValidationState();

      rule.apply('invalid', state);

      expect(state.errors.first.message, equals('Invalid IP!'));
    });

    test('should skip null values', () {
      final rule = Ipv4();
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors, isEmpty);
    });
  });

  group('Ipv6 (String)', () {
    test('should pass with valid IPv6 full', () {
      final rule = Ipv6();
      final state = ValidationState();

      rule.apply('2001:0db8:85a3:0000:0000:8a2e:0370:7334', state);

      expect(state.errors, isEmpty);
    });

    test('should pass with compressed IPv6', () {
      final rule = Ipv6();
      final state = ValidationState();

      rule.apply('2001:db8::1', state);

      expect(state.errors, isEmpty);
    });

    test('should pass with loopback', () {
      final rule = Ipv6();
      final state = ValidationState();

      rule.apply('::1', state);

      expect(state.errors, isEmpty);
    });

    test('should pass with all zeros', () {
      final rule = Ipv6();
      final state = ValidationState();

      rule.apply('::', state);

      expect(state.errors, isEmpty);
    });

    test('should fail with invalid characters', () {
      final rule = Ipv6();
      final state = ValidationState();

      rule.apply('2001:db8::g', state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('Ipv6'));
      expect(
          state.errors.first.message, equals('Must be a valid IPv6 address'));
    });

    test('should fail with too many groups without compression', () {
      final rule = Ipv6();
      final state = ValidationState();

      rule.apply('2001:db8:85a3:0:0:8a2e:370:7334:extra', state);

      expect(state.errors.length, equals(1));
    });

    test('should use custom message', () {
      final rule = Ipv6(message: 'Invalid IPv6!');
      final state = ValidationState();

      rule.apply('invalid', state);

      expect(state.errors.first.message, equals('Invalid IPv6!'));
    });

    test('should skip null values', () {
      final rule = Ipv6();
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors, isEmpty);
    });
  });

  group('Ip (String)', () {
    test('should pass with valid IPv4', () {
      final rule = Ip();
      final state = ValidationState();

      rule.apply('192.168.1.1', state);

      expect(state.errors, isEmpty);
    });

    test('should pass with valid IPv6', () {
      final rule = Ip();
      final state = ValidationState();

      rule.apply('::1', state);

      expect(state.errors, isEmpty);
    });

    test('should fail with invalid IP', () {
      final rule = Ip();
      final state = ValidationState();

      rule.apply('invalid', state);

      expect(state.errors.length, equals(1));
      expect(state.errors.first.rule, equals('Ip'));
      expect(state.errors.first.message, equals('Must be a valid IP address'));
    });

    test('should use custom message', () {
      final rule = Ip(message: 'Invalid IP!');
      final state = ValidationState();

      rule.apply('invalid', state);

      expect(state.errors.first.message, equals('Invalid IP!'));
    });

    test('should skip null values', () {
      final rule = Ip();
      final state = ValidationState();

      rule.apply(null, state);

      expect(state.errors, isEmpty);
    });
  });
}
