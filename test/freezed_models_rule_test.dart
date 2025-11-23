import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:meowstodon_lint/freezed_models_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(FreezedModelsRuleTest);
  });
}

@reflectiveTest
class FreezedModelsRuleTest extends AnalysisRuleTest {
  @override
  String get analysisRule => 'freezed_models';

  @override
  void setUp() {
    // Register the rule if not already registered
    if (!Registry.ruleRegistry.any((r) => r.name == analysisRule)) {
      Registry.ruleRegistry.registerLintRule(FreezedModelsRule());
    }
    super.setUp();
  }

  void testNonFreezedModelInModelsDirReportsLint() async {
    var testFilePath = '$testPackageLibPath/models/user.dart';
    newFile(testFilePath, r'''
class User {
  final String id;
  final String name;

  const User({required this.id, required this.name});
}
''');

    await assertDiagnosticsInFile(testFilePath, [lint(6, 4)]);
  }

  void testFreezedModelInModelsDirNoDiagnostics() async {
    var testFilePath = '$testPackageLibPath/models/user.dart';
    newFile(testFilePath, r'''
const freezed = null;

@freezed
class User {
  const User();
}
''');

    // Should not report because @freezed annotation is present
    await assertNoDiagnosticsInFile(testFilePath);
  }

  void testAbstractClassInModelsDirNoDiagnostics() async {
    var testFilePath = '$testPackageLibPath/models/base_model.dart';
    newFile(testFilePath, r'''
abstract class BaseModel {
  String get id;
}
''');

    await assertNoDiagnosticsInFile(testFilePath);
  }

  void testClassWithExtendsNoDiagnostics() async {
    var testFilePath = '$testPackageLibPath/models/special_user.dart';
    newFile(testFilePath, r'''
class BaseClass {}

class SpecialUser extends BaseClass {
  SpecialUser();
}
''');

    // SpecialUser has extends clause, so should be skipped
    // BaseClass doesn't extend, so should be reported
    await assertDiagnosticsInFile(testFilePath, [lint(6, 9)]);
  }

  void testConstantsOnlyClassInModelsDirNoDiagnostics() async {
    var testFilePath = '$testPackageLibPath/models/constants.dart';
    newFile(testFilePath, r'''
class Constants {
  static const String version = '1.0.0';
  static const int maxRetries = 3;

  const Constants._();
}
''');

    await assertNoDiagnosticsInFile(testFilePath);
  }

  void testStateClassInModelsDirNoDiagnostics() async {
    var testFilePath = '$testPackageLibPath/models/user_state.dart';
    newFile(testFilePath, r'''
class UserState {
  final bool isLoading;
  final String? error;

  const UserState({this.isLoading = false, this.error});
}
''');

    await assertNoDiagnosticsInFile(testFilePath);
  }

  void testRemoteStateClassInModelsDirNoDiagnostics() async {
    var testFilePath = '$testPackageLibPath/models/user_remote_state.dart';
    newFile(testFilePath, r'''
class UserRemoteState {
  final bool isLoading;
  final String? error;

  const UserRemoteState({this.isLoading = false, this.error});
}
''');

    await assertNoDiagnosticsInFile(testFilePath);
  }

  void testNonFreezedModelOutsideModelsDirNoDiagnostics() async {
    var testFilePath = '$testPackageLibPath/utils/helper.dart';
    newFile(testFilePath, r'''
class Helper {
  final String value;
  const Helper(this.value);
}
''');

    await assertNoDiagnosticsInFile(testFilePath);
  }

  void testGeneratedFileInModelsDirNoDiagnostics() async {
    var testFilePath = '$testPackageLibPath/models/user.g.dart';
    newFile(testFilePath, r'''
class User {
  final String id;
  const User(this.id);
}
''');

    await assertNoDiagnosticsInFile(testFilePath);
  }

  void testFreezedGeneratedFileInModelsDirNoDiagnostics() async {
    var testFilePath = '$testPackageLibPath/models/user.freezed.dart';
    newFile(testFilePath, r'''
class User {
  final String id;
  const User(this.id);
}
''');

    await assertNoDiagnosticsInFile(testFilePath);
  }
}
