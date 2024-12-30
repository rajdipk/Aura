import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/ai_service.dart';

class CommandProcessor {
  final AiService _aiService;

  CommandProcessor(this._aiService);

  Future<String> processCommand(String command) async {
    // Basic command handling
    switch (command.toLowerCase()) {
      case '/help':
        return 'Available commands:\n/help - Show this help message\n/clear - Clear chat history';
      case '/clear':
        return 'Chat history cleared';
      default:
        // Process unknown commands through AI
        return _aiService.generateResponse('Command: $command. Please help with this command or explain if it\'s invalid.');
    }
  }
}

final commandProcessorProvider = Provider((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return CommandProcessor(aiService);
});
