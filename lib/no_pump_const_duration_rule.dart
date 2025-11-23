import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class NoPumpConstDurationRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'no_pump_const_duration',
    'pump() should not be called with const Duration()',
    correctionMessage:
        'Use pump() without arguments or pumpAndSettle() instead of pump(const Duration())',
  );

  NoPumpConstDurationRule()
    : super(
        name: 'no_pump_const_duration',
        description:
            'Enforces that pump() is not called with const Duration() in test files.',
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

    // Check if this is a pump call
    if (node.methodName.name != 'pump') {
      return;
    }

    // Check if there's exactly one argument
    if (node.argumentList.arguments.length != 1) {
      return;
    }

    final argument = node.argumentList.arguments.first;

    // Check if the argument is an InstanceCreationExpression
    if (argument is! InstanceCreationExpression) {
      return;
    }

    // Check if it's a const expression
    if (argument.keyword?.lexeme != 'const') {
      return;
    }

    // Check if it's creating a Duration
    final type = argument.constructorName.type.name;
    if (type.lexeme != 'Duration') {
      return;
    }

    // Flag any const Duration() in pump calls
    rule.reportAtNode(node);
  }
}
