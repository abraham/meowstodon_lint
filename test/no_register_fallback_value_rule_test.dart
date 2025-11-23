import 'package:test/test.dart';

import 'package:meowstodon_lint/no_register_fallback_value_rule.dart';

void main() {
  group('NoRegisterFallbackValueRule', () {
    late NoRegisterFallbackValueRule rule;

    setUp(() {
      rule = NoRegisterFallbackValueRule();
    });

    test('should have correct rule name', () {
      expect(rule.name, equals('no_register_fallback_value'));
    });

    test('should have correct diagnostic code', () {
      expect(rule.diagnosticCode.name, equals('no_register_fallback_value'));
    });

    test('should have correct problem message', () {
      expect(
        rule.diagnosticCode.problemMessage,
        equals('registerFallbackValue should not be used in tests'),
      );
    });

    test('should have correct correction message', () {
      expect(
        rule.diagnosticCode.correctionMessage,
        equals(
          'Update mock when() statements to match real values instead of using any() with registerFallbackValue',
        ),
      );
    });

    test('should have description', () {
      expect(rule.description, isNotEmpty);
      expect(rule.description, contains('registerFallbackValue'));
    });
  });
}
