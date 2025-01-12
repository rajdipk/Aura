import 'package:aura_assistant/features/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/config/api_keys.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  await dotenv.load(fileName: ".env");

  // Verify API keys are loaded
  print("\n=== Checking API Keys ===");
  try {
    print("Spotify Client ID: ${ApiKeys.spotifyClientId.substring(0, 5)}...");
    print(
        "Spotify Client Secret: ${ApiKeys.spotifyClientSecret.substring(0, 5)}...");
    print("API Keys loaded successfully");
  } catch (e) {
    print("Error loading API keys: $e");
  }

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
      home: const HomeScreen(),
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
