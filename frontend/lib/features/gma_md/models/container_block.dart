import 'block_definition.dart';

class ContainerBlock {
  final BlockDefinition? definition;
  final String typeName;
  final String title;
  final String content;
  final Map<String, String> attributes;

  const ContainerBlock({
    this.definition,
    required this.typeName,
    required this.title,
    required this.content,
    this.attributes = const {},
  });
}
