import 'package:test/test.dart';

import 'package:meowstodon_lint/one_riverpod_per_file_rule.dart';

void main() {
  group('OneRiverpodPerFileRule', () {
    late OneRiverpodPerFileRule rule;

    setUp(() {
      rule = OneRiverpodPerFileRule();
    });

    test('should have correct rule name', () {
      expect(rule.name, equals('one_riverpod_per_file'));
    });

    test('should have correct diagnostic code', () {
      expect(rule.diagnosticCode.name, equals('one_riverpod_per_file'));
    });

    test('should have correct problem message', () {
      expect(
        rule.diagnosticCode.problemMessage,
        equals('Each file should contain at most one @Riverpod annotation'),
      );
    });

    test('should have correct correction message', () {
      expect(
        rule.diagnosticCode.correctionMessage,
        equals('Move additional @Riverpod annotations to separate files'),
      );
    });

    test('should have description', () {
      expect(rule.description, isNotEmpty);
      expect(rule.description, contains('at most one @Riverpod annotation'));
    });
  });
}
