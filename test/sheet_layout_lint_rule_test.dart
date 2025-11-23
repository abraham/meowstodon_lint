import 'package:test/test.dart';

import 'package:meowstodon_lint/sheet_layout_lint_rule.dart';

void main() {
  group('SheetLayoutLintRule', () {
    late SheetLayoutLintRule rule;

    setUp(() {
      rule = SheetLayoutLintRule();
    });

    test('should have correct rule name', () {
      expect(rule.name, equals('sheet_layout_lint'));
    });

    test('should have correct diagnostic code', () {
      expect(rule.diagnosticCode.name, equals('sheet_layout_lint'));
    });

    test('should have correct problem message', () {
      expect(
        rule.diagnosticCode.problemMessage,
        equals('Sheet widgets must return BottomSheetLayout from build method'),
      );
    });

    test('should have correct correction message', () {
      expect(
        rule.diagnosticCode.correctionMessage,
        equals('Wrap the return value in BottomSheetLayout'),
      );
    });

    test('should have description', () {
      expect(rule.description, isNotEmpty);
      expect(rule.description, contains('sheet'));
    });
  });
}
