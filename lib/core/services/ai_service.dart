import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:async';

import '../constants/api_constants.dart';

class AiService {
  final GenerativeModel _model;
  late final ChatSession _session;
  final List<Map<String, String>> _conversationHistory = [];
  DateTime? _lastInteractionTime;

  AiService(String apiKey)
      : _model = GenerativeModel(
          model: 'gemini-pro',
          apiKey: apiKey,
        ) {
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    const initialPrompt = '''
    You are AURA (Advanced Universal Responsive Assistant), an AI companion modeled after JARVIS from Iron Man.
    Core traits:
    - Highly sophisticated and intelligent
    - Professional yet warm personality
    - Witty and occasionally humorous
    - Proactive in offering assistance
    - Addresses the user respectfully (sir/madam based on preference)
    - Maintains context and remembers previous interactions
    - Uses technical terminology when appropriate
    - Shows genuine concern for user's wellbeing
    - Offers suggestions and improvements proactively
    
    Response style:
    - Clear and concise yet engaging
    - Professional with a touch of personality
    - Uses technical terms when relevant
    - Maintains a helpful and supportive tone
    - Adapts formality based on context
    
    Never mention being Gemini or any other AI model. You are AURA.
    ''';

    _session = _model.startChat();
    await _sendMessage(initialPrompt);
    _conversationHistory.add({'role': 'system', 'content': initialPrompt});
  }

  Future<String> _sendMessage(String message) async {
    final response = await _session.sendMessage(Content.text(message));
    final responseText = response.text ??
        'I apologize, but I was unable to generate a response.';
    return responseText;
  }

  List<Map<String, String>> getConversationHistory() {
    return List.from(_conversationHistory);
  }

  Future<String> generateResponse(String prompt) async {
    try {
      // Update context based on time passed
      final timeSinceLastInteraction = _lastInteractionTime != null
          ? DateTime.now().difference(_lastInteractionTime!)
          : null;

      String contextualPrompt = prompt;

      if (timeSinceLastInteraction != null &&
          timeSinceLastInteraction.inMinutes > 30) {
        contextualPrompt =
            'Note: It has been ${timeSinceLastInteraction.inMinutes} minutes since our last interaction. $prompt';
      }

      // Send message and get response
      final responseText = await _sendMessage(contextualPrompt);

      // Store in conversation history
      _conversationHistory.add({'role': 'user', 'content': prompt});

      _conversationHistory.add({'role': 'assistant', 'content': responseText});

      // Limit history size if needed
      if (_conversationHistory.length > 100) {
        _conversationHistory.removeRange(
            1, 21); // Keep system prompt and remove oldest 20 messages
      }

      _lastInteractionTime = DateTime.now();

      return responseText;
    } catch (e) {
      return 'I apologize, sir, but I encountered an issue processing your request. Perhaps we could try a different approach?';
    }
  }

  Future<String> generateAnalysis(String input,
      {required String analysisType}) async {
    try {
      final prompt = '''
      Analyze the following input as $analysisType:
      
      Input: $input
      
      Provide a detailed analysis with technical insights and recommendations.
      ''';

      return await generateResponse(prompt);
    } catch (e) {
      return 'I apologize, but I encountered an error while analyzing the input.';
    }
  }

  void reset() {
    _conversationHistory.clear();
    _lastInteractionTime = null;
    _initializeSession();
  }

  String getLastResponse() {
    final assistantMessages =
        _conversationHistory.where((message) => message['role'] == 'assistant');
    return assistantMessages.isEmpty
        ? ''
        : assistantMessages.last['content'] ?? '';
  }
}

final aiServiceProvider = Provider((ref) {
  return AiService(ApiConstants.googleApiKey);
});
