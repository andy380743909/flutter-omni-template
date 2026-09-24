import 'package:flutter/material.dart';

/// Centralized theme definitions for light and dark modes.
class AppTheme {
  /// Material 3 light theme seeded from a brand color.
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
      );

  /// Material 3 dark theme seeded from the same brand color.
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      );
}
