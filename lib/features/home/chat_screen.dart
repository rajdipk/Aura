import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';
import '../models/message.dart';
import '../text_interface/message_handler.dart';
import '../voice_interface/voice_service.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../core/services/command_processor.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterTts flutterTts = FlutterTts();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _fadeController;
  bool _isInputLocked = false;


  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _initTts();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    flutterTts.stop();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      // Handle focus gained (optional for visual cues or actions)
    } else {
      // Handle focus lost (optional for cleanup)
    }
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messageHandlerProvider);
    final commandProcessor = ref.watch(commandProcessorProvider);
    final voiceService = ref.watch(voiceServiceProvider);
    final theme = ref.watch(themeProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Aura',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          AnimatedBuilder(
            animation: _fadeController,
            builder: (context, child) {
              return IconButton(
                icon: Icon(
                  voiceService.isListening ? Icons.mic : Icons.mic_none,
                  color: voiceService.isListening
                      ? theme.colorScheme.primary
                      : null,
                ),
                onPressed: _handleVoiceInput,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _ChatBubble(
                  message: messages[index],
                  onTap: () => _speakMessage(messages[index].text),
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _textController,
                focusNode: _focusNode,
                enabled: !_isInputLocked, // This controls the input lock
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                ),
                onFieldSubmitted: _handleSubmitted,
              ),
            ),            const SizedBox(width: 8.0),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => _handleSubmitted(_textController.text),
            ),
          ],
        ),
      ),
    );
  }

  void _handleVoiceInput() {
    final voiceService = ref.read(voiceServiceProvider);
    if (voiceService.isListening) {
      setState(() {
        _isInputLocked = false; // Unlock when voice input stops
      });
      _fadeController.reverse();
      voiceService.stopListening();
    } else {
      setState(() {
        _isInputLocked = true; // Lock when voice input starts
      });

      if (_focusNode.hasFocus) {
        _focusNode.unfocus();
      }

      _fadeController.forward();
      voiceService.startListening(
        onResult: _handleSubmitted,
        onListenComplete: () {
          _fadeController.reverse();
          Future.delayed(const Duration(milliseconds: 150), () {
            if (mounted) {
              setState(() {
                _isInputLocked = false; // Unlock when voice input completes
              });
              _focusNode.requestFocus();
            }
          });
        },
      );
    }
  }


  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _isInputLocked = true; // Lock input when processing starts
    });

    _textController.clear();
    _focusNode.unfocus();

    if (text.startsWith('/')) {
      final commandProcessor = ref.read(commandProcessorProvider);
      final response = await commandProcessor.processCommand(text);
      ref.read(messageHandlerProvider.notifier).processUserMessage(response);
    } else {
      ref.read(messageHandlerProvider.notifier).processUserMessage(text);
    }

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            setState(() {
              _isInputLocked = false; // Unlock input after processing
            });
            FocusScope.of(context).requestFocus(_focusNode);
          }
        });
      });
    }
  }
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _speakMessage(String text) async {
    await flutterTts.speak(text);
  }
}

class _ChatBubble extends StatelessWidget {
  final Message message;
  final VoidCallback onTap;

  const _ChatBubble({
    required this.message,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final isUserMessage = message.isUser;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              decoration: BoxDecoration(
                color: isUserMessage
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12.0),
                  topRight: const Radius.circular(12.0),
                  bottomLeft:
                      isUserMessage ? const Radius.circular(12.0) : Radius.zero,
                  bottomRight:
                      isUserMessage ? Radius.zero : const Radius.circular(12.0),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUserMessage
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                  fontSize: 16.0,
                ),
              ),
            ),
            if (!isUserMessage && message.isAnimated)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      message.text,
                      textStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16.0,
                      ),
                      speed: const Duration(milliseconds: 50),
                    ),
                  ],
                  isRepeatingAnimation: false,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
