import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  final GenerativeModel _model;

  AiService(String apiKey) 
      : _model = GenerativeModel(
          model: 'gemini-pro',
          apiKey: apiKey,
        );

  Future<String> generateResponse(String prompt) async {
    const systemPrompt = "You are Aura, a helpful AI assistant.Like JARVIS"
                        "Always respond naturally and keep responses concise. "
                        "Never mention being Gemini or Google AI.";
    final content = [
      Content.text(systemPrompt),
      Content.text(prompt)
    ];
    final response = await _model.generateContent(content);
    return response.text ?? 'I could not generate a response';
  }
}

final aiServiceProvider = Provider((ref) {
  const apiKey = String.fromEnvironment('GOOGLE_API_KEY'); // Replace with your API key
  return AiService(apiKey);
});