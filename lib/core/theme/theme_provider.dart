import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(AppTheme.darkTheme);

  bool get isDarkMode => state == AppTheme.darkTheme;

  void toggleTheme() {
    state = isDarkMode ? AppTheme.lightTheme : AppTheme.darkTheme;
  }
}