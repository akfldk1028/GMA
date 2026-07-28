import 'dart:typed_data';

/// Role of a message in the conversation.
enum AiRole { system, user, assistant }

/// Type of content within a message.
enum AiContentType { text, image, audio }

/// A single piece of content (text, image, or audio).
class AiContent {
  AiContent.text(String t)
      : type = AiContentType.text,
        text = t,
        bytes = null,
        mimeType = null;

  AiContent.image(Uint8List b, {String mime = 'image/png'})
      : type = AiContentType.image,
        text = null,
        bytes = b,
        mimeType = mime;

  AiContent.audio(Uint8List b, {String mime = 'audio/wav'})
      : type = AiContentType.audio,
        text = null,
        bytes = b,
        mimeType = mime;

  final AiContentType type;
  final String? text;
  final Uint8List? bytes;
  final String? mimeType;
}

/// A message in the conversation, supporting multimodal content.
class AiMessage {
  AiMessage.text(this.role, String text) : parts = [AiContent.text(text)];
  AiMessage.multimodal(this.role, this.parts);

  final AiRole role;
  final List<AiContent> parts;

  /// Extract concatenated text from all text parts.
  String get textContent => parts
      .where((p) => p.type == AiContentType.text)
      .map((p) => p.text ?? '')
      .join();

  /// Whether this message contains any image parts.
  bool get hasImages => parts.any((p) => p.type == AiContentType.image);

  /// Whether this message contains any audio parts.
  bool get hasAudio => parts.any((p) => p.type == AiContentType.audio);
}
