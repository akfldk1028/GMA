import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../ocr_backend.dart';

/// Default Ollama server URL.
const kDefaultOllamaUrl = 'http://localhost:11434';

/// Default vision model for OCR.
const kDefaultOllamaModel = 'llava';

/// Default OCR prompt (Korean + English).
const kDefaultOcrPrompt =
    '이 이미지의 텍스트를 정확히 읽어서 그대로 출력해주세요. '
    'Extract all text from this image exactly as written.';

/// Ollama LLaVA backend — local vision model for OCR.
///
/// Uses POST /api/generate with base64-encoded image.
class OllamaBackend extends OcrBackend {
  @override
  String get id => 'ollama';

  @override
  String get label => 'Ollama (LLaVA)';

  @override
  Future<bool> isAvailable({String? baseUrl}) async {
    final url = baseUrl ?? kDefaultOllamaUrl;
    try {
      final response = await http
          .get(Uri.parse('$url/api/tags'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> recognize(
    Uint8List imageBytes, {
    String? baseUrl,
    String? model,
    String? prompt,
  }) async {
    final url = baseUrl ?? kDefaultOllamaUrl;
    final modelName = model ?? kDefaultOllamaModel;
    final ocrPrompt = prompt ?? kDefaultOcrPrompt;

    final base64Image = base64Encode(imageBytes);

    final response = await http
        .post(
          Uri.parse('$url/api/generate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'model': modelName,
            'prompt': ocrPrompt,
            'images': [base64Image],
            'stream': false,
          }),
        )
        .timeout(const Duration(seconds: 120));

    if (response.statusCode != 200) {
      throw Exception(
        'Ollama API error ${response.statusCode}: ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final text = json['response'] as String? ?? '';
    return text.trim();
  }
}
