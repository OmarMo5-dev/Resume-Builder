import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_raduis.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    fontFamily: AppTypography.fontFamily,
    brightness: Brightness.light,

    scaffoldBackgroundColor: AppColors.backgroundLight,

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceLight,
      error: AppColors.error,
    ),

    textTheme: AppTypography.light,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
    ),

    cardTheme: CardThemeData(
      color: AppColors.surfaceLight,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(AppRadius.lg),
        ),
        side: BorderSide(
          color: AppColors.borderLight,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(
          color: AppColors.borderLight,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(
          color: AppColors.borderLight,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
    ),
  );
}