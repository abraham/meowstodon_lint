import 'package:test/test.dart';

import 'package:meowstodon_lint/sheet_name_lint_rule.dart';

void main() {
  group('SheetNameLintRule', () {
    late SheetNameLintRule rule;

    setUp(() {
      rule = SheetNameLintRule();
    });

    test('should have correct rule name', () {
      expect(rule.name, equals('sheet_name_lint'));
    });

    test('should have correct diagnostic code', () {
      expect(rule.diagnosticCode.name, equals('sheet_name_lint'));
    });

    test('should have correct problem message', () {
      expect(
        rule.diagnosticCode.problemMessage,
        equals(
          'Classes using showModalBottomSheet must end in "Sheet" but not "BottomSheet"',
        ),
      );
    });

    test('should have correct correction message', () {
      expect(
        rule.diagnosticCode.correctionMessage,
        equals('Rename the class to end with "Sheet" instead of "BottomSheet"'),
      );
    });

    test('should have description', () {
      expect(rule.description, isNotEmpty);
      expect(rule.description, contains('showModalBottomSheet'));
    });
  });
}
