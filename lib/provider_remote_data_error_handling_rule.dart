import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:meowstodon_lint/visitors/remote_state_assignment_visitor.dart';
import 'package:meowstodon_lint/visitors/state_outside_try_visitor.dart';
import 'package:meowstodon_lint/visitors/try_catch_visitor.dart';

class ProviderRemoteDataErrorHandlingRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'provider_remote_data_error_handling',
    'Providers returning RemoteState should have try-catch blocks that set error state',
    correctionMessage:
        'Wrap async operations in try-catch and call RemoteState.error() or set state to an error value in the catch block',
  );

  ProviderRemoteDataErrorHandlingRule()
    : super(
        name: 'provider_remote_data_error_handling',
        description:
            'Enforces that providers returning RemoteState have proper try-catch blocks with error handling.',
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
    // Check if this file is in the providers directory
    final filePath = context.currentUnit?.file.path ?? '';
    if (!filePath.contains('/lib/providers/') ||
        filePath.contains('.g.dart') ||
        filePath.contains('.freezed.dart')) {
      return;
    }

    if (!_isRemoteStateProvider(node)) {
      return;
    }

    _checkMethodsForErrorHandling(node);
  }

  bool _isRemoteStateProvider(ClassDeclaration node) {
    final extendsClause = node.extendsClause;
    if (extendsClause == null) return false;

    final buildMethod = node.members
        .whereType<MethodDeclaration>()
        .where((m) => m.name.lexeme == 'build')
        .firstOrNull;

    if (buildMethod == null) return false;

    final returnType = buildMethod.returnType?.toString() ?? '';

    return returnType.contains('RemoteState') || returnType.contains('State');
  }

  void _checkMethodsForErrorHandling(ClassDeclaration node) {
    for (final member in node.members) {
      if (member is! MethodDeclaration) continue;

      if (member.name.lexeme == 'build') continue;

      if (!member.isAbstract && _needsErrorHandling(member)) {
        if (!_hasTryCatchWithErrorHandling(member)) {
          rule.reportAtNode(member);
        }
      }
    }
  }

  bool _needsErrorHandling(MethodDeclaration method) {
    final visitor = RemoteStateAssignmentVisitor();
    method.body.visitChildren(visitor);

    // Method needs error handling if it has state assignments AND
    // at least one of those assignments is outside a try-catch
    return visitor.hasRemoteStateAssignment &&
        _hasStateAssignmentOutsideTryCatch(method);
  }

  bool _hasStateAssignmentOutsideTryCatch(MethodDeclaration method) {
    final visitor = StateOutsideTryVisitor();
    method.body.visitChildren(visitor);
    return visitor.hasStateOutsideTry;
  }

  bool _hasTryCatchWithErrorHandling(MethodDeclaration method) {
    final visitor = TryCatchVisitor();
    method.body.visitChildren(visitor);
    return visitor.hasTryCatchWithErrorHandling;
  }
}
