import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../constants/api_constants.dart';

class AiService {
  final GenerativeModel _model;

  AiService(String apiKey) 
      : _model = GenerativeModel(
          model: 'gemini-pro',
          apiKey: apiKey,
        );

  Future<String> generateResponse(String prompt) async {
    try {
      final content = [
        Content.text('You are Aura, a helpful AI assistant like JARVIS. '
            'Always respond naturally and keep responses concise. '
            'Never mention being Gemini or Google AI.'),
        Content.text(prompt)
      ];
    
      final response = await _model.generateContent(content);
      return response.text ?? 'I could not generate a response';
    } catch (e) {
      return 'I encountered an error processing your request';
    }
  }}
  final aiServiceProvider = Provider((ref) {
    return AiService(ApiConstants.googleApiKey);
  });