import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'nlp_service.dart';

class CommandProcessor {
  final NLPService _nlpService;

  CommandProcessor(this._nlpService);

Future<String> processCommand(String input) async {
  final intent = await _nlpService.analyzeIntent(input);
  final entities = _nlpService.extractEntities(input);

  // Weather specific handling
  if (intent == CommandIntent.weather) {
      final location = entities['location'] ?? 'current location';
      return "Let me check the current weather in $location for you. I'll have real-time weather data integration soon!";
  }
    
  // Default to conversation
  return await _handleConversation(input);
}

  Future<String> _handleWeatherCommand(Map<String, dynamic> entities) async {
    return "I'll check the weather for you. This feature will be implemented soon!";
  }

  Future<String> _handleMusicCommand(Map<String, dynamic> entities) async {
    return "I'll play some music for you. This feature will be implemented soon!";
  }

  Future<String> _handleReminderCommand(Map<String, dynamic> entities) async {
    return "I'll set a reminder for you. This feature will be implemented soon!";
  }

  Future<String> _handleSearchCommand(String query) async {
    return "I'll search that for you. This feature will be implemented soon!";
  }

  Future<String> _handleConversation(String input) async {
    return "I understand you're trying to have a conversation. I'm learning to be more interactive!";
  }
}

final commandProcessorProvider = Provider((ref) {
  final nlpService = ref.watch(nlpServiceProvider);
  return CommandProcessor(nlpService);
});
