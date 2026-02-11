import 'package:markdown/markdown.dart' as m;
import 'package:markdown_widget/markdown_widget.dart';

/// Abstract interface for self-contained markdown rendering plugins.
///
/// Each extension is a "node" (like n8n) that declares its own:
/// - Inline/block syntaxes (parsing)
/// - Node generators (rendering)
/// - Theme configs (styling)
///
/// Adding a new renderer = create a class implementing this + register it.
/// No need to touch the central markdown_config.dart.
///
/// Example:
/// ```dart
/// class MyExtension implements MarkdownExtension {
///   @override String get name => 'my-extension';
///   @override List<m.InlineSyntax> get inlineSyntaxes => [MySyntax()];
///   @override List<SpanNodeGeneratorWithTag> get generators => [myGenerator];
///   @override List<dynamic> get themeConfigs => [];
/// }
/// ```
abstract class MarkdownExtension {
  /// Unique name for this extension (for debugging/logging).
  String get name;

  /// Inline syntaxes this extension provides (parsed during markdown processing).
  List<m.InlineSyntax> get inlineSyntaxes => [];

  /// Block syntaxes this extension provides.
  List<m.BlockSyntax> get blockSyntaxes => [];

  /// Span node generators for rendering parsed elements into widgets.
  List<SpanNodeGeneratorWithTag> get generators => [];

  /// Theme configs to merge into MarkdownConfig (e.g., WikiLinkConfig for styling).
  /// Items should be instances of config classes like WikiLinkConfig, etc.
  List<dynamic> get themeConfigs => [];
}
