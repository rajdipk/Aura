// lib/core/constants/api_constants.template.dart
class ApiConstants {
  static const String apiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const String googleApiKey = String.fromEnvironment('GOOGLE_API_KEY');
  static const String openAiEndpoint = 'https://api.openai.com/v1/chat/completions';
  // Add other API-related constants here
}