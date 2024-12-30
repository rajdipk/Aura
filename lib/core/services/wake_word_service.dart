import 'package:flutter_riverpod/flutter_riverpod.dart';

class WakeWordService {
  static const List<String> wakeWords = [
    'hey aura',
    'aura',
    'wake-up aura',
    'you there aura'
  ];
  
  Future<void> initialize() async {
    // Initialize wake word detection
  }

  void startListening() {
    // Start listening implementation
  }

  void stopListening() {
    // Stop listening implementation
  }
}

final wakeWordServiceProvider = Provider((ref) => WakeWordService());
