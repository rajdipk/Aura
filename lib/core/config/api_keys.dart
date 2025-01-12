import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiKeys {
  static String get openWeatherMap => _getKey('OPEN_WEATHER_MAP_API_KEY');
  static String get googleCustomSearch => _getKey('GOOGLE_CUSTOM_SEARCH_API_KEY');
  static String get googleSearchEngineId => _getKey('GOOGLE_SEARCH_ENGINE_ID');
  static String get spotifyClientId => _getKey('SPOTIFY_CLIENT_ID');
  static String get spotifyClientSecret => _getKey('SPOTIFY_CLIENT_SECRET');
  static String get homeAssistantToken => _getKey('HOME_ASSISTANT_TOKEN');
  static String get spoonacular => _getKey('SPOONACULAR_API_KEY');
  
  static String _getKey(String key) {
    final value = dotenv.env[key];
    if (value == null) {
      throw Exception('Missing API key for $key. Please check your .env file.');
    }
    return value;
  }
}
