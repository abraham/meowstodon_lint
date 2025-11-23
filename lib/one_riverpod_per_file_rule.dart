import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class OneRiverpodPerFileRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'one_riverpod_per_file',
    'Each file should contain at most one @Riverpod annotation',
    correctionMessage:
        'Move additional @Riverpod annotations to separate files',
  );

  OneRiverpodPerFileRule()
    : super(
        name: 'one_riverpod_per_file',
        description:
            'Enforces that each file contains at most one @Riverpod annotation.',
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

    final riverpodAnnotations = <Annotation>[];

    // Find all @Riverpod annotations in the compilation unit
    for (final declaration in node.declarations) {
      List<Annotation>? metadata;

      if (declaration is FunctionDeclaration) {
        metadata = declaration.metadata;
      } else if (declaration is ClassDeclaration) {
        metadata = declaration.metadata;
      }

      if (metadata != null) {
        for (final annotation in metadata) {
          final name = annotation.name.name;
          if (name == 'Riverpod' || name == 'riverpod') {
            riverpodAnnotations.add(annotation);
          }
        }
      }
    }

    // Check if we have more than one @Riverpod annotation
    if (riverpodAnnotations.length > 1) {
      // Report error on the second and subsequent @Riverpod annotations
      for (int i = 1; i < riverpodAnnotations.length; i++) {
        rule.reportAtNode(riverpodAnnotations[i]);
      }
    }
  }
}
