import 'package:test/test.dart';

import 'package:meowstodon_lint/provider_remote_data_error_handling_rule.dart';

void main() {
  group('ProviderRemoteDataErrorHandlingRule', () {
    late ProviderRemoteDataErrorHandlingRule rule;

    setUp(() {
      rule = ProviderRemoteDataErrorHandlingRule();
    });

    test('should have correct rule name', () {
      expect(rule.name, equals('provider_remote_data_error_handling'));
    });

    test('should have correct diagnostic code', () {
      expect(
        rule.diagnosticCode.name,
        equals('provider_remote_data_error_handling'),
      );
    });

    test('should have correct problem message', () {
      expect(
        rule.diagnosticCode.problemMessage,
        contains(
          'Providers returning RemoteState should have try-catch blocks',
        ),
      );
    });

    test('should have correct correction message', () {
      expect(
        rule.diagnosticCode.correctionMessage,
        contains('Wrap async operations in try-catch'),
      );
      expect(
        rule.diagnosticCode.correctionMessage,
        contains('RemoteState.error()'),
      );
    });

    test('should have description', () {
      expect(rule.description, isNotEmpty);
      expect(rule.description, contains('RemoteState'));
    });
  });
}
