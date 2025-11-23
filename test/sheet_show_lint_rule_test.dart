import 'package:test/test.dart';

import 'package:meowstodon_lint/sheet_show_lint_rule.dart';

void main() {
  group('SheetShowLintRule', () {
    late SheetShowLintRule rule;

    setUp(() {
      rule = SheetShowLintRule();
    });

    test('should have correct rule name', () {
      expect(rule.name, equals('sheet_show_lint'));
    });

    test('should have correct diagnostic code', () {
      expect(rule.diagnosticCode.name, equals('sheet_show_lint'));
    });

    test('should have correct problem message', () {
      expect(
        rule.diagnosticCode.problemMessage,
        equals(
          'showModalBottomSheet must only be used in a static show method',
        ),
      );
    });

    test('should have correct correction message', () {
      expect(
        rule.diagnosticCode.correctionMessage,
        equals(
          'Move showModalBottomSheet call to a static show method in the widget class',
        ),
      );
    });

    test('should have description', () {
      expect(rule.description, isNotEmpty);
      expect(rule.description, contains('showModalBottomSheet'));
    });
  });
}
