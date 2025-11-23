import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class SheetLayoutLintRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'sheet_layout_lint',
    'Sheet widgets must return BottomSheetLayout from build method',
    correctionMessage: 'Wrap the return value in BottomSheetLayout',
  );

  SheetLayoutLintRule()
    : super(
        name: 'sheet_layout_lint',
        description:
            'Enforces that sheet widgets return BottomSheetLayout from their build method.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    var visitor = _Visitor(this, context);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    // Check if this file is in the widgets directory
    final filePath = context.currentUnit?.file.path ?? '';
    if (!filePath.contains('/lib/widgets/') ||
        filePath.contains('.g.dart') ||
        filePath.contains('.freezed.dart')) {
      return;
    }

    final className = node.name.lexeme;

    // Check if the class name ends with "Sheet"
    if (!className.endsWith('Sheet')) {
      return;
    }

    // Check if it extends StatelessWidget or ConsumerWidget or is a State class
    final extendsClause = node.extendsClause;
    if (extendsClause == null) {
      return;
    }

    final superclassName = extendsClause.superclass.name.lexeme;
    final isWidgetClass =
        superclassName == 'StatelessWidget' ||
        superclassName == 'ConsumerWidget';
    final isStateClass =
        superclassName == 'State' || superclassName == 'ConsumerState';

    if (!isWidgetClass && !isStateClass) {
      return;
    }

    // Find the build method
    MethodDeclaration? buildMethod;
    for (final member in node.members) {
      if (member is MethodDeclaration && member.name.lexeme == 'build') {
        buildMethod = member;
        break;
      }
    }

    if (buildMethod == null) {
      return;
    }

    // Check the return statement(s) in the build method
    final body = buildMethod.body;
    if (body is! BlockFunctionBody && body is! ExpressionFunctionBody) {
      return;
    }

    bool hasBottomSheetLayoutReturn = false;

    if (body is ExpressionFunctionBody) {
      // For => syntax, check the expression directly
      hasBottomSheetLayoutReturn = _isBottomSheetLayout(body.expression);
    } else if (body is BlockFunctionBody) {
      // For block body, check all return statements
      hasBottomSheetLayoutReturn = _checkBlockForBottomSheetLayout(body.block);
    }

    if (!hasBottomSheetLayoutReturn) {
      rule.reportAtToken(buildMethod.name);
    }
  }

  bool _isBottomSheetLayout(Expression expr) {
    // Handle instance creation expressions
    if (expr is InstanceCreationExpression) {
      final typeName = expr.constructorName.type.name.lexeme;
      return typeName == 'BottomSheetLayout';
    }
    return false;
  }

  bool _checkBlockForBottomSheetLayout(Block block) {
    // Recursively check all return statements in the block
    for (final statement in block.statements) {
      if (statement is ReturnStatement) {
        final expr = statement.expression;
        if (expr != null && _isBottomSheetLayout(expr)) {
          return true;
        }
      }
      // Check nested blocks (if statements, etc.)
      if (statement is IfStatement) {
        if (statement.thenStatement is Block) {
          if (_checkBlockForBottomSheetLayout(
            statement.thenStatement as Block,
          )) {
            return true;
          }
        } else if (statement.thenStatement is ReturnStatement) {
          final expr = (statement.thenStatement as ReturnStatement).expression;
          if (expr != null && _isBottomSheetLayout(expr)) {
            return true;
          }
        }
        if (statement.elseStatement != null) {
          if (statement.elseStatement is Block) {
            if (_checkBlockForBottomSheetLayout(
              statement.elseStatement as Block,
            )) {
              return true;
            }
          } else if (statement.elseStatement is ReturnStatement) {
            final expr =
                (statement.elseStatement as ReturnStatement).expression;
            if (expr != null && _isBottomSheetLayout(expr)) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }
}
