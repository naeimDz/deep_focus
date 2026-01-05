import 'package:flutter/material.dart';

class AppColors {
  // Deep Dark Theme (Premium)
  static const Color darkBackground = Color(0xFF0F0F13);
  static const Color darkSurface = Color(0xFF1C1C23);
  static const Color darkText = Color(0xFFF2F2F7);
  static const Color darkTextSecondary = Color(0xFF8E8E93);

  // Light Theme (Clean)
  static const Color lightBackground = Color(0xFFF2F2F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xFF8E8E93);

  // Accents
  static const Color primary = Color(0xFF7F5AF0); // Vibrant Purple
  static const Color primaryGlow = Color(0xFF9F83F5); // Lighter for glow
  static const Color secondary = Color(0xFF2CB67D); // Success Green for breaks
  static const Color accent = Color(0xFF2CB67D);

  // Gradients
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F0F13), Color(0xFF1A1A24)],
  );

  static const LinearGradient lightBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF9F9F9), Color(0xFFE5E5EA)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7F5AF0), Color(0xFF6246EA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppDimensions {
  static const double borderRadius = 24.0;
  static const double timerRadius = 150.0;
}
