import 'package:flutter/material.dart';

class AppColors {
  // Static class to prevent instantiation
  AppColors._();

  // Primary Backgrounds
  // "Deep dark surface" from screenshot
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color card = Color(0xFF252525);

  // Accents (Gradient tokens)
  static const Color midnightStart = Color(0xFF2C3E50);
  static const Color midnightEnd = Color(0xFF000000);

  static const Color royalStart = Color(0xFF514A9D);
  static const Color royalEnd = Color(0xFF24C6DC);

  static const Color sunsetStart = Color(0xFFFF512F);
  static const Color sunsetEnd = Color(0xFFDD2476);

  // Diamond FAB Gradient
  static const Color fabGradientStart = Color(0xFF4FACFE); // Light Blue
  static const Color fabGradientEnd = Color(0xFF00F2FE); // Cyan/Teal

  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color accent = Color(0xFF7F5AF0); // Example purple accent

  // Functional
  static const Color error = Color(0xFFCF6679);
  static const Color success = Color(0xFF00C851);
}
