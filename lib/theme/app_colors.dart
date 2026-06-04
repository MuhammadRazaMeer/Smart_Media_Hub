import 'package:flutter/material.dart';

class AppColors {
  static const Color purplePrimary = Color(0xFF7C3AED);
  static const Color purpleNeon = Color(0xFFA855F7);
  static const Color blue = Color(0xFF3B82F6);
  static const Color pink = Color(0xFFEC4899);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color green = Color(0xFF10B981);
  static const Color orange = Color(0xFFF97316);
  static const Color red = Color(0xFFEF4444);
  static const Color amber = Color(0xF59E0B);
  
  static const Color darkBG = Color(0xFF0A0A0A);
  static const Color darkCard = Color(0xFF121212);
  static const Color lightBG = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  
  static const Color darkMutedText = Color(0xFFB3B3B3);
  static const Color lightMutedText = Color(0xFF717182);

  static const LinearGradient purplePink = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purpleNeon, pink],
  );

  static const LinearGradient purpleBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purplePrimary, blue],
  );

  static const LinearGradient blueCyan = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blue, cyan],
  );

  static const LinearGradient greenBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [green, blue],
  );

  static const LinearGradient orangeRed = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [orange, red],
  );

  static const LinearGradient splashBG = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFF3B82F6), Color(0xFF8B5CF6)],
  );
}
