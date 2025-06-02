import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFF3B30); // Kırmızı vurgu
  static const Color backgroundDark = Color(0xFF121212);
  static const Color backgroundLight = Color(0xFFF2F2F2);
  static const Color textDark = Color(0xFFFFFFFF);
  static const Color textLight = Color(0xFF1C1C1E);
  static const Color secondary = Color(0xFF3A3A3C);
  static const Color inputFillDark = Color(0xFF1E1E1E);
}

class AppTextStyles {
  static const TextStyle headline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const TextStyle subhead = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  static const TextStyle input = TextStyle(
    fontSize: 16,
    color: AppColors.textDark,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );
}

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.backgroundDark,
  primaryColor: AppColors.primary,
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.inputFillDark,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.secondary),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    hintStyle: TextStyle(color: AppColors.secondary),
  ),
  textTheme: const TextTheme(
    bodyLarge: AppTextStyles.input,
    titleLarge: AppTextStyles.headline,
    bodyMedium: AppTextStyles.subhead,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      textStyle: AppTextStyles.button,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
);
