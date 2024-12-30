// lib/features/text_interface/message_handler.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import '../../core/services/ai_service.dart';

final messageHandlerProvider =
    StateNotifierProvider<MessageHandler, List<Message>>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return MessageHandler(aiService);
});

class MessageHandler extends StateNotifier<List<Message>> {
  final AiService _aiService;

  MessageHandler(this._aiService) : super([]);

  void addMessage(Message message) {
    state = [...state, message];
  }

  Future<void> processUserMessage(String text) async {
    // Add user message
    addMessage(Message(
      text: text,
      isUser: true,
    ));

    try {
      final response = await _aiService.generateResponse(text);
      // Add AI response
      addMessage(Message(
        text: response,
        isUser: false,
      ));
    } catch (e) {
      // Add error message
      addMessage(Message(
        text: "I'm currently unable to process your request. Please try again.",
        isUser: false,
      ));
    }
  }
}