import 'package:test/test.dart';

import 'package:meowstodon_lint/no_pump_const_duration_rule.dart';

void main() {
  group('NoPumpConstDurationRule', () {
    late NoPumpConstDurationRule rule;

    setUp(() {
      rule = NoPumpConstDurationRule();
    });

    test('should have correct rule name', () {
      expect(rule.name, equals('no_pump_const_duration'));
    });

    test('should have correct diagnostic code', () {
      expect(rule.diagnosticCode.name, equals('no_pump_const_duration'));
    });

    test('should have correct problem message', () {
      expect(
        rule.diagnosticCode.problemMessage,
        equals('pump() should not be called with const Duration()'),
      );
    });

    test('should have correct correction message', () {
      expect(
        rule.diagnosticCode.correctionMessage,
        equals(
          'Use pump() without arguments or pumpAndSettle() instead of pump(const Duration())',
        ),
      );
    });

    test('should have description', () {
      expect(rule.description, isNotEmpty);
      expect(rule.description, contains('pump()'));
    });
  });
}
