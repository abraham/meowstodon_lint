import 'package:test/test.dart';

import 'package:meowstodon_lint/riverpod_providers_rule.dart';

void main() {
  group('RiverpodProvidersRule', () {
    late RiverpodProvidersRule rule;

    setUp(() {
      rule = RiverpodProvidersRule();
    });

    test('should have correct rule name', () {
      expect(rule.name, equals('riverpod_providers'));
    });

    test('should have correct diagnostic code', () {
      expect(rule.diagnosticCode.name, equals('riverpod_providers'));
    });

    test('should have correct problem message', () {
      expect(
        rule.diagnosticCode.problemMessage,
        equals('Providers should use @riverpod or @Riverpod annotation'),
      );
    });

    test('should have correct correction message', () {
      expect(
        rule.diagnosticCode.correctionMessage,
        equals('Add @riverpod or @Riverpod annotation to this provider'),
      );
    });

    test('should have description', () {
      expect(rule.description, isNotEmpty);
      expect(rule.description, contains('provider'));
    });
  });
}
