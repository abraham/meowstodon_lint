import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class ErrorStateVisitor extends RecursiveAstVisitor<void> {
  bool hasErrorState = false;

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    if (node.leftHandSide.toString() == 'state') {
      final rightSide = node.rightHandSide.toString();
      if (rightSide.contains('RemoteState.error') ||
          rightSide.contains('State.error')) {
        hasErrorState = true;
      }
    }
    super.visitAssignmentExpression(node);
  }
}
