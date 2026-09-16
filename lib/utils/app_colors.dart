import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF1E56A0);
  static const Color primaryDark = Color(0xFF163172);
  static const Color primaryLight = Color(0xFFD6E4F0);
  static const Color accent = Color(0xFFF6F6F6);

  // Status & Semantic Colors
  static const Color success = Color(0xFF2E7D32); // Positive balance / active
  static const Color warning = Color(0xFFF57C00); // Pending / Extra bills
  static const Color danger = Color(0xFFD32F2F);  // Due / High costs
  static const Color info = Color(0xFF0288D1);    // Info badges

  // Meals colors
  static const Color dayMeal = Color(0xFFFFA000);   // Sun color
  static const Color nightMeal = Color(0xFF3F51B5); // Moon/Night color

  // Neutral Colors (Light mode)
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color borderLight = Color(0xFFE0E0E0);

  // Neutral Colors (Dark mode)
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Color(0xFFEEEEEE);
  static const Color textSecondaryDark = Color(0xFFAAAAAA);
  static const Color borderDark = Color(0xFF2C2C2C);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E56A0), Color(0xFF163172)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFFA726), Color(0xFFF57C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFFC62828)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

