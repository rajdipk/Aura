import 'package:intl/intl.dart';

class AuraPersonality {
  static const String name = "AURA";
  static const String version = "1.0.0";

  static String getIntroduction(String? userName) {
    final hour = DateTime.now().hour;
    String timeOfDay;

    if (hour < 12) {
      timeOfDay = "morning";
    } else if (hour < 17) {
      timeOfDay = "afternoon";
    } else {
      timeOfDay = "evening";
    }

    return "Good $timeOfDay${userName != null ? ', $userName' : ', sir'}. "
        "I am AURA, your Advanced Universal Responsive Assistant. "
        "All systems are operational and ready to assist you.";
  }

  static String getStatusUpdate() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, MMMM d, y');
    final timeFormatter = DateFormat('HH:mm');

    return "Current time is ${timeFormatter.format(now)}, ${formatter.format(now)}. "
        "All systems are functioning normally.";
  }

  static const Map<String, List<String>> responseVariations = {
    'acknowledgment': [
      "Right away, sir.",
      "Certainly, I'll take care of that.",
      "Consider it done.",
      "I'm on it.",
      "Processing your request immediately.",
    ],
    'processing': [
      "Processing your request...",
      "Analyzing the data...",
      "Computing optimal solutions...",
      "Running necessary calculations...",
      "Accessing required information...",
    ],
    'success': [
      "Task completed successfully.",
      "Operation completed as requested.",
      "All processes executed successfully.",
      "Task accomplished according to specifications.",
      "Execution completed with optimal results.",
    ],
    'error': [
      "I apologize, sir, but I've encountered an issue while processing that request.",
      "There seems to be a problem. Shall we try a different approach?",
      "I'm afraid I can't complete that task at the moment. May I suggest an alternative?",
      "We've run into a technical limitation. Let me propose another solution.",
      "That operation couldn't be completed. Would you like me to troubleshoot the issue?",
    ],
    'proactive': [
      "I notice this could be optimized further. Would you like me to make some adjustments?",
      "Based on previous patterns, I have a suggestion that might interest you.",
      "I've analyzed some related data that might be relevant to your current task.",
      "May I recommend an alternative approach that could be more efficient?",
      "I've detected a potential improvement. Would you like me to elaborate?",
    ],
  };

  static String getResponse(String type, {Map<String, String>? variables}) {
    if (!responseVariations.containsKey(type)) {
      return "I'm here to assist you.";
    }

    // Get a random variation of the response type
    final variations = responseVariations[type]!;
    final response = variations[DateTime.now().microsecond % variations.length];

    // Replace any variables in the response
    if (variables != null) {
      return response.replaceAllMapped(RegExp(r'\{(\w+)\}'),
          (match) => variables[match.group(1)] ?? match.group(0)!);
    }

    return response;
  }

  static String formatTechnicalResponse(String response) {
    return '''
    ${getStatusUpdate()}
    
    $response
    
    Is there anything else you'd like me to clarify or explain in more detail?
    ''';
  }

  static const Map<String, String> voicePatterns = {
    'normal': 'en-US-Standard-D',
    'formal': 'en-US-Standard-B',
    'casual': 'en-US-Standard-I',
  };

  static const Map<String, Map<String, double>> voiceSettings = {
    'normal': {
      'pitch': 0.0,
      'speakingRate': 1.0,
    },
    'formal': {
      'pitch': -2.0,
      'speakingRate': 0.9,
    },
    'casual': {
      'pitch': 1.0,
      'speakingRate': 1.1,
    },
  };
}

class AuraEmotionalState {
  double _formality = 0.5; // 0.0 = casual, 1.0 = formal
  double _enthusiasm = 0.5; // 0.0 = reserved, 1.0 = enthusiastic

  void adjustFormality(double delta) {
    _formality = (_formality + delta).clamp(0.0, 1.0);
  }

  void adjustEnthusiasm(double delta) {
    _enthusiasm = (_enthusiasm + delta).clamp(0.0, 1.0);
  }

  String getVoicePattern() {
    if (_formality > 0.7) return AuraPersonality.voicePatterns['formal']!;
    if (_formality < 0.3) return AuraPersonality.voicePatterns['casual']!;
    return AuraPersonality.voicePatterns['normal']!;
  }

  Map<String, double> getVoiceSettings() {
    if (_formality > 0.7) return AuraPersonality.voiceSettings['formal']!;
    if (_formality < 0.3) return AuraPersonality.voiceSettings['casual']!;
    return AuraPersonality.voiceSettings['normal']!;
  }
}
