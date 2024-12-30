import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

final voiceServiceProvider = Provider((ref) => VoiceService());

class VoiceService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  bool isListening = false;

  Future<void> _initializeSpeech() async {
    if (!_isInitialized) {
      _isInitialized = await _speech.initialize();
    }
  }

  Future<void> startListening({
    required Function(String) onResult,
    required Function() onListenComplete,
  }) async {
    await _initializeSpeech();
    if (_isInitialized) {
      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
            onListenComplete();
          }
        },
      );
      isListening = true;
    }
  }

  Future<void> stopListening() async {
    await _speech.stop();
    isListening = false;
  }
}