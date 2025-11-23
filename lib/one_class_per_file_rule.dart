import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class OneClassPerFileRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'one_class_per_file',
    'Each file should contain at most one class (excluding State and Visitor classes)',
    correctionMessage: 'Move additional classes to separate files',
  );

  OneClassPerFileRule()
    : super(
        name: 'one_class_per_file',
        description:
            'Enforces that each file contains at most one class (excluding State and Visitor classes).',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    var visitor = _Visitor(this, context);
    registry.addCompilationUnit(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    final filePath = context.currentUnit?.file.path ?? '';

    // Skip generated files
    if (filePath.contains('.g.dart') || filePath.contains('.freezed.dart')) {
      return;
    }

    // Skip files outside lib/ directory
    if (!filePath.contains('/lib/')) {
      return;
    }

    final publicClasses = <ClassDeclaration>[];
    final privateClasses = <ClassDeclaration>[];

    // Find all classes in the compilation unit
    for (final declaration in node.declarations) {
      if (declaration is ClassDeclaration) {
        if (declaration.name.lexeme.startsWith('_')) {
          privateClasses.add(declaration);
        } else {
          publicClasses.add(declaration);
        }
      }
    }

    // Report error if we have more than one public class
    if (publicClasses.length > 1) {
      for (int i = 1; i < publicClasses.length; i++) {
        rule.reportAtToken(publicClasses[i].name);
      }
    }

    // Report error for private classes that are not state classes or visitor classes
    for (final privateClass in privateClasses) {
      final className = privateClass.name.lexeme;
      if (!className.endsWith('State') && !className.endsWith('Visitor')) {
        rule.reportAtToken(privateClass.name);
      }
    }
  }
}
