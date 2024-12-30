// ignore_for_file: avoid_print

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'nlp_service.dart';

// Command types enumeration
enum CommandType {
  SEND_MESSAGE,
  GET_RESPONSE,
  // Add more command types as needed
}

class CommandProcessor {
  final NLPService nlpService;

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
    return "I understand you're trying to have a conversation. I'm learning to be more interactive!";
  }
}

final commandProcessorProvider = Provider((ref) {
  final nlpService = ref.watch(nlpServiceProvider);
  return CommandProcessor(nlpService);
});
