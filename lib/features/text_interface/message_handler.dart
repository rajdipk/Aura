// lib/features/text_interface/message_handler.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import '../../core/services/ai_service.dart';

class MessageHandler extends StateNotifier<List<Message>> {
  final AiService _aiService;
  
  MessageHandler(this._aiService) : super([]);

  Future<void> processUserMessage(String text) async {
    // Add user message
    state = [...state, Message(text: text, isUser: true)];
    
    // Get AI response
    final response = await _aiService.generateResponse(text);
    
    // Add AI response
    state = [...state, Message(text: response, isUser: false)];
  }
}

final messageHandlerProvider = StateNotifierProvider<MessageHandler, List<Message>>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return MessageHandler(aiService);
});
