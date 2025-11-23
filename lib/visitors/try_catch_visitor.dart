import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:meowstodon_lint/visitors/state_assignment_visitor.dart';
import 'package:meowstodon_lint/visitors/error_state_visitor.dart';

class TryCatchVisitor extends RecursiveAstVisitor<void> {
  bool hasTryCatchWithErrorHandling = false;

  @override
  void visitTryStatement(TryStatement node) {
    final hasStateAssignmentInTry = _hasStateAssignmentInBlock(node.body);

    if (hasStateAssignmentInTry) {
      for (final catchClause in node.catchClauses) {
        if (_hasErrorStateInCatch(catchClause.body)) {
          hasTryCatchWithErrorHandling = true;
          return;
        }
      }
    }

    super.visitTryStatement(node);
  }

  bool _hasStateAssignmentInBlock(Block block) {
    final visitor = StateAssignmentVisitor();
    block.visitChildren(visitor);
    return visitor.hasStateAssignment;
  }

  bool _hasErrorStateInCatch(Block catchBlock) {
    final visitor = ErrorStateVisitor();
    catchBlock.visitChildren(visitor);
    return visitor.hasErrorState;
  }
}
