import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class SheetNameLintRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'sheet_name_lint',
    'Classes using showModalBottomSheet must end in "Sheet" but not "BottomSheet"',
    correctionMessage:
        'Rename the class to end with "Sheet" instead of "BottomSheet"',
  );

  SheetNameLintRule()
    : super(
        name: 'sheet_name_lint',
        description:
            'Enforces that classes using showModalBottomSheet end with "Sheet" but not "BottomSheet".',
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

    // Find the enclosing class declaration
    AstNode? current = node.parent;
    ClassDeclaration? enclosingClass;

    while (current != null) {
      if (current is ClassDeclaration) {
        enclosingClass = current;
        break;
      }
      current = current.parent;
    }

    // If not in a class, skip (this shouldn't happen in practice)
    if (enclosingClass == null) {
      return;
    }

    final className = enclosingClass.name.lexeme;

    // Check if the class name ends with "Sheet" but not "BottomSheet"
    if (!className.endsWith('Sheet') || className.endsWith('BottomSheet')) {
      rule.reportAtToken(enclosingClass.name);
    }
  }
}
