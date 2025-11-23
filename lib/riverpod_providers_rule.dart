import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class RiverpodProvidersRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'riverpod_providers',
    'Providers should use @riverpod or @Riverpod annotation',
    correctionMessage: 'Add @riverpod or @Riverpod annotation to this provider',
  );

  RiverpodProvidersRule()
    : super(
        name: 'riverpod_providers',
        description:
            'Enforces that provider functions and classes in lib/providers/ use the @riverpod or @Riverpod annotation.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    var visitor = _Visitor(this, context);
    registry.addFunctionDeclaration(this, visitor);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _checkProvider(node);
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    _checkProvider(node);
  }

  void _checkProvider(AstNode node) {
    // Check if this file is in the providers directory
    final filePath = context.currentUnit?.file.path ?? '';
    if (!filePath.contains('/lib/providers/') ||
        filePath.contains('.g.dart') ||
        filePath.contains('.freezed.dart')) {
      return;
    }

    Token? nameToken;
    String? name;
    List<Annotation>? metadata;

    if (node is FunctionDeclaration) {
      nameToken = node.name;
      name = node.name.lexeme;
      metadata = node.metadata;
    } else if (node is ClassDeclaration) {
      nameToken = node.name;
      name = node.name.lexeme;
      metadata = node.metadata;
    }

    if (nameToken == null || name == null || metadata == null) {
      return;
    }

    // Skip if this is not a provider (doesn't have 'provider' in the name or isn't a notifier)
    if (!_isProvider(name, node)) {
      return;
    }

    // Check if it has @riverpod or @Riverpod annotation
    if (!_hasRiverpodAnnotation(metadata)) {
      rule.reportAtToken(nameToken);
    }
  }

  bool _isProvider(String name, AstNode node) {
    // For functions, only consider them providers if they don't start with underscore
    // and are not obvious helper functions
    if (node is FunctionDeclaration) {
      // Skip private functions (starting with underscore)
      if (name.startsWith('_')) {
        return false;
      }

      // Skip functions that are clearly not providers
      if (name.contains('helper') ||
          name.contains('util') ||
          name.contains('fallback') ||
          name.contains('default')) {
        return false;
      }

      // In providers directory, public functions are likely providers
      return true;
    }

    // For classes, check if they extend a notifier or have provider-like patterns
    if (node is ClassDeclaration) {
      // Check if it extends a notifier class
      final extendsClause = node.extendsClause;
      if (extendsClause != null) {
        final superclass = extendsClause.superclass.name.lexeme;
        if (superclass.contains('Notifier') ||
            superclass.contains('Provider')) {
          return true;
        }
      }

      // If class name suggests it's a provider/notifier
      return name.toLowerCase().contains('provider') ||
          name.toLowerCase().contains('notifier');
    }

    return false;
  }

  bool _hasRiverpodAnnotation(List<Annotation> metadata) {
    for (final annotation in metadata) {
      final name = annotation.name.name;
      if (name == 'riverpod' || name == 'Riverpod') {
        return true;
      }
    }
    return false;
  }
}
