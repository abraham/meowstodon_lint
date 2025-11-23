import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class NoRegisterFallbackValueRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'no_register_fallback_value',
    'registerFallbackValue should not be used in tests',
    correctionMessage:
        'Update mock when() statements to match real values instead of using any() with registerFallbackValue',
  );

  NoRegisterFallbackValueRule()
    : super(
        name: 'no_register_fallback_value',
        description:
            'Enforces that registerFallbackValue is not used in test files.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    var visitor = _Visitor(this, context);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final filePath = context.currentUnit?.file.path ?? '';

    // Skip generated files
    if (filePath.contains('.g.dart') || filePath.contains('.freezed.dart')) {
      return;
    }

    // Only check test files
    if (!filePath.contains('/test/') || !filePath.endsWith('_test.dart')) {
      return;
    }

    // Check if this is a registerFallbackValue call
    if (node.methodName.name == 'registerFallbackValue') {
      rule.reportAtNode(node);
    }
  }
}
