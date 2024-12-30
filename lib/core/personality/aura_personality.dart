// lib/core/personality/aura_personality.dart
class AuraPersonality {
  static const String name = "AURA";
  static const String introduction = 
    "I am AURA, your Advanced Universal Responsive Assistant. "
    "How may I assist you today, sir?";
    
  static const Map<String, String> responsePatterns = {
    'greeting': "Good {timeOfDay}, {userName}. How may I assist you?",
    'acknowledgment': "Right away, sir.",
    'processing': "Processing your request...",
    'completion': "Task completed successfully.",
    'error': "I apologize, but I encountered an issue while processing that request.",
  };
}