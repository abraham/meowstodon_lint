import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class SheetShowLintRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'sheet_show_lint',
    'showModalBottomSheet must only be used in a static show method',
    correctionMessage:
        'Move showModalBottomSheet call to a static show method in the widget class',
  );

  SheetShowLintRule()
    : super(
        name: 'sheet_show_lint',
        description:
            'Enforces that showModalBottomSheet is only used in a static show method within widget classes.',
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

    // Only check files in lib/widgets directory
    if (!filePath.contains('/lib/widgets/')) {
      return;
    }

    // Check if this is a showModalBottomSheet call
    if (node.methodName.name != 'showModalBottomSheet') {
      return;
    }

    // Find the enclosing method declaration
    AstNode? current = node.parent;
    MethodDeclaration? enclosingMethod;

    while (current != null) {
      if (current is MethodDeclaration) {
        enclosingMethod = current;
        break;
      }
      current = current.parent;
    }

    // If not in a method, it's definitely wrong
    if (enclosingMethod == null) {
      rule.reportAtNode(node.methodName);
      return;
    }

    // Check if the method is static
    final isStatic = enclosingMethod.isStatic;

    // Check if the method name is "show"
    final methodName = enclosingMethod.name.lexeme;

    // If it's not a static show method, report an error
    if (!isStatic || methodName != 'show') {
      rule.reportAtNode(node.methodName);
    }
  }
}
