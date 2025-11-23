import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:meowstodon_lint/freezed_models_rule.dart';
import 'package:meowstodon_lint/no_pump_const_duration_rule.dart';
import 'package:meowstodon_lint/one_class_per_file_rule.dart';
import 'package:meowstodon_lint/no_register_fallback_value_rule.dart';
import 'package:meowstodon_lint/one_riverpod_per_file_rule.dart';
import 'package:meowstodon_lint/provider_remote_data_error_handling_rule.dart';
import 'package:meowstodon_lint/sheet_layout_lint_rule.dart';
import 'package:meowstodon_lint/sheet_name_lint_rule.dart';
import 'package:meowstodon_lint/sheet_show_lint_rule.dart';
import 'package:meowstodon_lint/riverpod_providers_rule.dart';

final plugin = MeowstodonLintPlugin();

class MeowstodonLintPlugin extends Plugin {
  @override
  void register(PluginRegistry registry) {
    registry.registerWarningRule(FreezedModelsRule());
    registry.registerWarningRule(NoPumpConstDurationRule());
    registry.registerWarningRule(OneClassPerFileRule());
    registry.registerWarningRule(NoRegisterFallbackValueRule());
    registry.registerWarningRule(OneRiverpodPerFileRule());
    registry.registerWarningRule(ProviderRemoteDataErrorHandlingRule());
    registry.registerWarningRule(SheetLayoutLintRule());
    registry.registerWarningRule(SheetNameLintRule());
    registry.registerWarningRule(SheetShowLintRule());
    registry.registerWarningRule(RiverpodProvidersRule());
  }

  @override
  String get name => 'MeowstodonLintPlugin';
}
