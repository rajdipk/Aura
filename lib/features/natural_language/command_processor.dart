class CommandProcessor {
  Future<void> processCommand(String input, CommandSource source) async {
    // 1. Normalize input
    final normalizedInput = input.toLowerCase().trim();
    
    // 2. Intent classification
    final intent = await classifyIntent(normalizedInput);
    
    // 3. Entity extraction
    final entities = await extractEntities(normalizedInput);
    
    // 4. Execute command
    await executeCommand(intent, entities);
  }
  
  Future<String> classifyIntent(String input) async {
    // Implement intent classification
    return '';
  }
  
  Future<Map<String, dynamic>> extractEntities(String input) async {
    // Implement entity extraction
    return {};
  }
  
  Future<void> executeCommand(String intent, Map<String, dynamic> entities) async {
    // Implement command execution
  }
}

enum CommandSource {
  voice,
  text
}
