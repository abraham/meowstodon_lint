import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class StateOutsideTryVisitor extends RecursiveAstVisitor<void> {
  bool hasStateOutsideTry = false;
  bool _insideTry = false;

  @override
  void visitTryStatement(TryStatement node) {
    final wasTry = _insideTry;
    _insideTry = true;
    node.body.visitChildren(this);
    _insideTry = wasTry;

    // Visit catch clauses with _insideTry = false (they're outside try)
    for (final catchClause in node.catchClauses) {
      catchClause.body.visitChildren(this);
    }

    // Visit finally with _insideTry = false (it's outside try)
    node.finallyBlock?.visitChildren(this);
  }

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    if (!_insideTry && node.leftHandSide.toString() == 'state') {
      final rightSide = node.rightHandSide.toString();
      if (rightSide.contains('RemoteState.loading') ||
          rightSide.contains('RemoteState.success') ||
          rightSide.contains('State.loading') ||
          rightSide.contains('State.success')) {
        hasStateOutsideTry = true;
      }
    }
    super.visitAssignmentExpression(node);
  }
}
