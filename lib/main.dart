import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/home/chat_screen.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  await dotenv.load();  // Will look for .env by default
  runApp(const ProviderScope(child: AuraAssistant()));
}
class AuraAssistant extends ConsumerWidget {
  const AuraAssistant({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    
    return MaterialApp(
      title: 'Aura Assistant',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const ChatScreen(),
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(
            physics: const BouncingScrollPhysics(),
          ),
          child: child!,
        );
      },
    );
  }
}