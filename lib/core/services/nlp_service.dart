import 'package:flutter_riverpod/flutter_riverpod.dart';

class NLPService {
  Future<CommandIntent> analyzeIntent(String input) async {
    final String normalizedInput = input.toLowerCase().trim();
    
    if (normalizedInput.contains('weather')) {
      return CommandIntent.weather;
    } else if (normalizedInput.contains('play') || normalizedInput.contains('music')) {
      return CommandIntent.music;
    } else if (normalizedInput.contains('reminder') || normalizedInput.contains('schedule')) {
      return CommandIntent.reminder;
    } else if (normalizedInput.contains('search')) {
      return CommandIntent.search;
    }
    
    return CommandIntent.conversation;
  }

  Map<String, dynamic> extractEntities(String input) {
    final entities = <String, dynamic>{};
    // Basic entity extraction logic
    final timePattern = RegExp(r'\d{1,2}:\d{2}');
    final datePattern = RegExp(r'\d{2,4}[-/]\d{1,2}[-/]\d{1,2}');
    
    if (timePattern.hasMatch(input)) {
      entities['time'] = timePattern.firstMatch(input)?.group(0);
    }
    
    if (datePattern.hasMatch(input)) {
      entities['date'] = datePattern.firstMatch(input)?.group(0);
    }
    
    return entities;
  }
}

enum CommandIntent {
  weather,
  music,
  reminder,
  search,
  conversation
}

final nlpServiceProvider = Provider((ref) => NLPService());
