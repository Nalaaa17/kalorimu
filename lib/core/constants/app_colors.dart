import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors - Golden/Yellow
  static const Color primary = Color(0xFF735C00);
  static const Color primaryContainer = Color(0xFFD4AF37); // Golden accent
  static const Color onPrimaryContainer = Color(0xFF554300);
  
  static const Color secondary = Color(0xFF7B5800);
  static const Color secondaryContainer = Color(0xFFFDC34D);

  static const Color tertiary = Color(0xFF5D5F5F);

  // Background & Surface - Light
  static const Color background = Color(0xFFFCF9F8); // Warm white
  static const Color surface = Color(0xFFFCF9F8);
  static const Color surfaceVariant = Color(0xFFDCD9D9);
  static const Color backgroundCard = Color(0xFFFFFFFF);
  static const Color backgroundCardLight = Color(0xFFEAE7E7); // surface-container-high
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1B1C1C);
  static const Color textSecondary = Color(0xFF4D4635);
  static const Color textHint = Color(0xFF7F7663); // outline color

  // Semantic Colors
  static const Color error = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFFDC34D); // secondary container
  static const Color info = Color(0xFF0288D1);

  // Macro Colors (Adjusted for light theme)
  static const Color protein = Color(0xFFD84315);
  static const Color carbs = Color(0xFF1565C0);
  static const Color fat = Color(0xFFD4AF37); // Gold

  // Meal Type Colors
  static const Color breakfast = Color(0xFFFFA000);
  static const Color lunch = Color(0xFFD4AF37);
  static const Color dinner = Color(0xFF5D5F5F);
  static const Color snack = Color(0xFF7B5800);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
