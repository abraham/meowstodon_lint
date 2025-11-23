import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class FreezedModelsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'freezed_models',
    'Models should use @freezed annotation',
    correctionMessage: 'Add @freezed annotation to this model class',
  );

  FreezedModelsRule()
    : super(
        name: 'freezed_models',
        description:
            'Enforces that model classes in lib/models/ use the @freezed annotation for immutability.',
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
    // Check if this file is in the models directory
    final filePath = context.currentUnit?.file.path ?? '';
    if (!filePath.contains('/lib/models/') ||
        filePath.contains('.g.dart') ||
        filePath.contains('.freezed.dart')) {
      return;
    }

    // Skip certain types of classes that shouldn't use freezed
    if (_shouldSkipClass(node)) {
      return;
    }

    // Check if the class has @freezed annotation
    if (!_hasFreezedAnnotation(node)) {
      rule.reportAtToken(node.name);
    }
  }

  bool _shouldSkipClass(ClassDeclaration node) {
    final className = node.name.lexeme;

    // Skip classes that extend other classes (except Object implicitly)
    // Freezed doesn't work with inheritance
    if (node.extendsClause != null) {
      return true;
    }

    // Skip abstract base classes that are just for inheritance
    if (node.abstractKeyword != null && _isInheritanceOnlyClass(node)) {
      return true;
    }

    // Skip classes that are clearly state/utility classes
    if (_isUtilityOrStateClass(className, node)) {
      return true;
    }

    // Skip enums-like classes (const constructors only)
    if (_isConstantsOnlyClass(node)) {
      return true;
    }

    return false;
  }

  bool _isInheritanceOnlyClass(ClassDeclaration node) {
    // Check if it's an abstract class with only abstract members/getters
    if (node.abstractKeyword == null) return false;

    final hasConcreteImplementation = node.members.any((member) {
      if (member is MethodDeclaration) {
        return member.body is! EmptyFunctionBody;
      }
      if (member is FieldDeclaration) {
        return !member.isStatic;
      }
      return false;
    });

    return !hasConcreteImplementation;
  }

  bool _isUtilityOrStateClass(String className, ClassDeclaration node) {
    // Classes that are clearly state or utility classes
    const statePatterns = ['State', 'RemoteState', 'Flags'];
    return statePatterns.any((pattern) => className.contains(pattern));
  }

  bool _isConstantsOnlyClass(ClassDeclaration node) {
    // Check if all constructors are const and all fields are static const
    final constructors = node.members.whereType<ConstructorDeclaration>();
    final fields = node.members.whereType<FieldDeclaration>();

    // If it has non-const constructors, it's not a constants-only class
    if (constructors.any((c) => c.constKeyword == null)) {
      return false;
    }

    // If it has non-static fields, it's not a constants-only class
    if (fields.any((f) => !f.isStatic)) {
      return false;
    }

    // If it only has static const fields and const constructors, skip it
    return fields.isNotEmpty && fields.every((f) => f.isStatic);
  }

  bool _hasFreezedAnnotation(ClassDeclaration node) {
    for (final annotation in node.metadata) {
      final name = annotation.name.name;
      if (name == 'freezed' || name == 'Freezed') {
        return true;
      }
    }
    return false;
  }
}
