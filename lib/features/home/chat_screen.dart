//chat_screen.dart

// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';
import '../models/formatted_message.dart';
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
  late FocusNode _focusNode = FocusNode();
  late AnimationController _fadeController;
  bool _isInputLocked = false;
  bool _isSpeaking = false;
  Message? _currentlySpokenMessage;
  bool _isInputFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _initTts();
    if (!kIsWeb) {
      _focusNode.addListener(_handleFocusChange);
    }
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isInputFocused = _focusNode.hasFocus;
        });
        if (_isInputFocused) {
          _scrollToBottom();
        }
      }
    });
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messageHandlerProvider);
    final voiceService = ref.watch(voiceServiceProvider);
    final theme = ref.watch(themeProvider);
    final isDark = theme.brightness == Brightness.dark;

    return FocusScope(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
            ),
            title: Text(
              'Aura',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..shader = LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary
                    ],
                  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
              ),
              IconButton(
                icon: Icon(
                  voiceService.isListening ? Icons.mic : Icons.mic_none,
                  color: voiceService.isListening
                      ? theme.colorScheme.primary
                      : null,
                ),
                onPressed: _handleVoiceInput,
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surface.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: messages.isEmpty
                      ? const Center(
                          child: Text('No messages yet. Start chatting!'))
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(
                              top: 100, left: 8, right: 8, bottom: 8),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            if (index == messages.length - 1 &&
                                _isInputLocked) {}
                            return _ChatBubble(
                              message: messages[index],
                              onTap: () => _speakMessage(messages[index]),
                              isSpeaking: _isSpeaking &&
                                  messages[index] == _currentlySpokenMessage,
                            );
                          },
                        ),
                ),
                _buildInputArea(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: _isInputFocused
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Theme.of(context).colorScheme.surface,
              ),
              onSubmitted: _handleSubmitted,
              onTap: () {
                setState(() {
                  _isInputFocused = true;
                });
                _scrollToBottom();
              },
              enabled: !_isInputLocked,
            ),
          ),
          IconButton(
            icon:
                Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
            onPressed: _isInputLocked
                ? null
                : () => _handleSubmitted(_textController.text),
          ),
        ],
      ),
    );
  }

  void _handleVoiceInput() {
    final voiceService = ref.read(voiceServiceProvider);
    if (voiceService.isListening) {
      setState(() {
        _isInputLocked = false;
      });
      _fadeController.reverse();
      voiceService.stopListening();
    } else {
      setState(() {
        _isInputLocked = true;
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
                _isInputLocked = false;
              });
              _focusNode.requestFocus();
            }
          });
        },
        onError: (error) {
          setState(() {
            _isInputLocked = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Voice recognition failed. Please try again.')),
          );
        },
      );
    }
  }

  Future<void> _handleSubmitted(String text) async {
    print("\n=== ChatScreen: Handling Submitted Text ===");
    print("Text received: '$text'");

    if (text.trim().isEmpty) return;

    setState(() {
      _isInputLocked = true;
    });

    _textController.clear();
    FocusScope.of(context).unfocus();

    try {
      final commandProcessor = ref.read(commandProcessorProvider);
      print("Processing text through CommandProcessor...");
      final response = await commandProcessor.processCommand(text);
      print("Command processor response: '$response'");
      
      await ref
          .read(messageHandlerProvider.notifier)
          .processUserMessage(response);
      
    } catch (e, stackTrace) {
      print("Error in _handleSubmitted: $e");
      print("Stack trace: $stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isInputLocked = false;
        });
      }
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

  Future<void> _speakMessage(Message message) async {
    if (_isSpeaking) {
      await flutterTts.stop();
      setState(() {
        _isSpeaking = false;
        _currentlySpokenMessage = null;
      });
      return;
    }

    try {
      setState(() {
        _isSpeaking = true;
        _currentlySpokenMessage = message;
      });
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(0.9); // Slightly lower pitch for a deeper tone.
      await flutterTts.setSpeechRate(0.85); // Slower rate for clarity.
      var result = await flutterTts.speak(message.text);
      if (result == 1) {
        debugPrint('Message spoken successfully');
      } else {
        debugPrint('Error speaking message');
      }
    } catch (e) {
      debugPrint('Error in text-to-speech: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to speak the message. Please try again.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      setState(() {
        _isSpeaking = false;
        _currentlySpokenMessage = null;
      });
    }
  }
}

class _ChatBubble extends StatefulWidget {
  final Message message;
  final VoidCallback onTap;
  final bool isSpeaking;

  const _ChatBubble({
    required this.message,
    required this.onTap,
    this.isSpeaking = false,
  });

  @override
  __ChatBubbleState createState() => __ChatBubbleState();
}

class __ChatBubbleState extends State<_ChatBubble> {
  bool _isAnimationFinished = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUserMessage = widget.message.isUser;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: () {
        if (!isUserMessage) {
          Clipboard.setData(ClipboardData(text: widget.message.text));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message copied to clipboard')),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              decoration: BoxDecoration(
                color: isUserMessage
                    ? theme.colorScheme.primary.withOpacity(0.8)
                    : theme.colorScheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12.0),
                  topRight: const Radius.circular(12.0),
                  bottomLeft:
                      isUserMessage ? const Radius.circular(12.0) : Radius.zero,
                  bottomRight:
                      isUserMessage ? Radius.zero : const Radius.circular(12.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withAlpha((0.1 * 255).round()),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: isUserMessage
                  ? FormattedMessage(
                      text: widget.message.text,
                      textColor: theme.colorScheme.onPrimary,
                      fontSize: 16.0,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!_isAnimationFinished)
                          AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText(
                                widget.message.text,
                                textStyle: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontSize: 16.0,
                                ),
                                speed: const Duration(milliseconds: 50),
                              ),
                            ],
                            isRepeatingAnimation: false,
                            totalRepeatCount: 1,
                            onFinished: () {
                              setState(() {
                                _isAnimationFinished = true;
                              });
                            },
                          )
                        else
                          FormattedMessage(
                            text: widget.message.text,
                            textColor: theme.colorScheme.onSurface,
                            fontSize: 16.0,
                          ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.copy, size: 16),
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: widget.message.text));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Message copied to clipboard')),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.volume_up, size: 16),
                              onPressed: widget.onTap,
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
            if (widget.isSpeaking)
              const Positioned(
                top: 4,
                right: 4,
                child: Icon(
                  Icons.volume_up,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
