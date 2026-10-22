import 'package:flutter_test/flutter_test.dart';
import 'package:easydial/utils/phone_utils.dart';

void main() {
  group('validatePhoneNumber', () {
    test('accepts common number formats', () {
      expect(validatePhoneNumber('+44 20 7946 0958'), isNull);
      expect(validatePhoneNumber('(555) 010-1234'), isNull);
      expect(validatePhoneNumber('5550101234'), isNull);
    });

    test('rejects empty input', () {
      expect(validatePhoneNumber(''), isNotNull);
      expect(validatePhoneNumber(null), isNotNull);
    });

    test('rejects letters', () {
      expect(validatePhoneNumber('call mary'), isNotNull);
    });

    test('rejects numbers that are too short or too long', () {
      expect(validatePhoneNumber('12345'), isNotNull);
      expect(validatePhoneNumber('1234567890123456'), isNotNull);
    });
  });

  group('toDialNumber', () {
    test('strips formatting but keeps the leading plus', () {
      expect(toDialNumber('+44 (20) 7946-0958'), '+442079460958');
    });

    test('strips formatting from national numbers', () {
      expect(toDialNumber(' (555) 010-1234 '), '5550101234');
    });
  });
}
