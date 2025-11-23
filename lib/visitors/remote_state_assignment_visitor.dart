import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class RemoteStateAssignmentVisitor extends RecursiveAstVisitor<void> {
  bool hasRemoteStateAssignment = false;

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    if (node.leftHandSide.toString() == 'state') {
      final rightSide = node.rightHandSide.toString();
      if (rightSide.contains('RemoteState.loading') ||
          rightSide.contains('RemoteState.success') ||
          rightSide.contains('State.loading') ||
          rightSide.contains('State.success')) {
        hasRemoteStateAssignment = true;
      }
    }
    super.visitAssignmentExpression(node);
  }
}
