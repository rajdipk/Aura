// ignore_for_file: avoid_print

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'nlp_service.dart';
import 'weather_service.dart';
import 'search_service.dart';
import 'recipe_service.dart';
import 'music_service.dart';
import 'smart_home_service.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

// Command types enumeration
enum CommandType {
  SEND_MESSAGE,
  GET_RESPONSE,
  // Add more command types as needed
}

class CommandProcessor {
  final NLPService nlpService;
  final WeatherService _weatherService = WeatherService();
  final SearchService _searchService = SearchService();
  final RecipeService _recipeService = RecipeService();
  final MusicService _musicService = MusicService();
  final SmartHomeService _smartHomeService = SmartHomeService();

  CommandProcessor(this.nlpService);

  Future<String> processCommand(String input) async {
    print("Processing command: $input"); // Debugging output

    // Determine command type
    CommandType? commandType;

    if (input.startsWith('/send ')) {
      commandType = CommandType.SEND_MESSAGE;
    } else if (input.startsWith('/get ')) {
      commandType = CommandType.GET_RESPONSE;
    }

    // Process based on command type
    try {
      switch (commandType) {
        case CommandType.SEND_MESSAGE:
          print("Detected SEND_MESSAGE command."); // Debugging output
          return await _handleSendMessage(
              input.substring(6)); // Extract message
        case CommandType.GET_RESPONSE:
          print("Detected GET_RESPONSE command."); // Debugging output
          return await _handleGetResponse(input.substring(6)); // Extract query
        default:
          print("Unknown command: $input"); // Debugging output
          return await _handleConversation(input); // Handle as a conversation
      }
    } catch (e) {
      print("Error processing command: $e"); // Log the error
      return "I'm currently unable to process your request, please try again.";
    }
  }

  // Handle sending messages
  Future<String> _handleSendMessage(String message) async {
    try {
      // Integrate with message handler provider
      // Example: ref.read(messageHandlerProvider.notifier).processUserMessage(message);
      return 'Sending message: $message'; // Placeholder for actual implementation
    } catch (e) {
      return 'Error sending message: $e';
    }
  }

  // Handle getting responses
  Future<String> _handleGetResponse(String query) async {
    try {
      // Integrate with API to get response
      return 'Getting response for query: $query'; // Placeholder for actual implementation
    } catch (e) {
      return 'Error getting response: $e';
    }
  }

  // Default to conversation
  Future<String> _handleConversation(String input) async {
    print("\n=== Command Processor: Starting Conversation Handler ===");
    print("Input received: '$input'");

    if (input.contains('weather')) {
      final city = extractCity(input); // Implement this method
      try {
        final weatherData = await _weatherService.getWeather(city);
        return formatWeatherResponse(weatherData); // Implement this method
      } catch (e) {
        return 'Sorry, I couldn\'t fetch the weather information.';
      }
    } else if (input.contains('search')) {
      final query = extractQuery(input); // Implement this method
      try {
        final searchData = await _searchService.search(query);
        return formatSearchResponse(searchData); // Implement this method
      } catch (e) {
        return 'Sorry, I couldn\'t perform the search.';
      }
    } else if (input.contains('recipe')) {
      final query = extractQuery(input); // Implement this method
      try {
        final recipeData = await _recipeService.getRecipe(query);
        return formatRecipeResponse(recipeData); // Implement this method
      } catch (e) {
        return 'Sorry, I couldn\'t fetch the recipe information.';
      }
    } else if (input.toLowerCase().contains('play')) {
      print("\n=== Starting Spotify Flow ===");
      try {
        final trackName = extractTrackUri(input);
        print("1. Track name extracted: '$trackName'");

        print("2. Getting access token...");
        final accessToken = await _musicService.getAccessToken();
        print("3. Searching for track...");
        final trackId = await _musicService.searchTrack(accessToken, trackName);
        print("4. Playing track...");
        await _musicService.playTrack(accessToken, trackId);
        return 'Now playing "$trackName" on Spotify. If playback doesn\'t start automatically, please ensure Spotify is open and a device is active.';
      } catch (e, stackTrace) {
        print("ERROR in Spotify flow: $e");
        print("Stack trace: $stackTrace");
        return 'I encountered an issue while playing the music. Please make sure you have an active Spotify device and are logged in. Error: $e';
      }
    } else if (input.contains('control home')) {
      // Implement smart home command processing
      final deviceCommand =
          extractDeviceCommand(input); // Implement this method
      try {
        final client = await _smartHomeService.authenticate();
        await _smartHomeService.controlDevice(client, deviceCommand);
        return 'Executing command: $deviceCommand';
      } catch (e) {
        return 'Sorry, I couldn\'t control the device.';
      }
    }
    // Process other types of commands...
    return "I understand you're trying to have a conversation. I'm learning to be more interactive!";
  }

  String extractCity(String input) {
    // Implement logic to extract city from input
    return 'SampleCity';
  }

  String extractQuery(String input) {
    // Implement logic to extract query from input
    return 'SampleQuery';
  }

  String extractTrackUri(String input) {
    // Remove "play" and "on spotify" from the input, case-insensitive
    final cleanedInput = input.toLowerCase()
        .replaceAll(RegExp(r'play\s+', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+on\s+spotify\s*$', caseSensitive: false), '')
        .trim();
    print("Cleaned track name: '$cleanedInput'");
    return cleanedInput;
  }

  String extractDeviceCommand(String input) {
    // Implement logic to extract device command from input
    return 'turn on the lights';
  }

  String formatWeatherResponse(Map<String, dynamic> weatherData) {
    // Implement logic to format weather response
    return 'Weather: ${weatherData['weather'][0]['description']}';
  }

  String formatSearchResponse(Map<String, dynamic> searchData) {
    // Implement logic to format search response
    return 'Search results: ${searchData['items'][0]['title']}';
  }

  String formatRecipeResponse(Map<String, dynamic> recipeData) {
    // Implement logic to format recipe response
    return 'Recipe: ${recipeData['results'][0]['title']}';
  }
}

final commandProcessorProvider = Provider((ref) {
  final nlpService = ref.watch(nlpServiceProvider);
  return CommandProcessor(nlpService);
});
