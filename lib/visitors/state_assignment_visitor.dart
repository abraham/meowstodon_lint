import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class StateAssignmentVisitor extends RecursiveAstVisitor<void> {
  bool hasStateAssignment = false;

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    if (node.leftHandSide.toString() == 'state') {
      hasStateAssignment = true;
    }
    super.visitAssignmentExpression(node);
  }
}
