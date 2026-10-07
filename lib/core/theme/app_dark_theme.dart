import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_raduis.dart';
import 'app_typography.dart';

abstract final class AppDarkTheme {
  static ThemeData dark = ThemeData(
    useMaterial3: true,
    fontFamily: AppTypography.fontFamily,
    brightness: Brightness.dark,

    scaffoldBackgroundColor: AppColors.backgroundDark,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceDark,
      error: AppColors.error,
    ),

    textTheme: AppTypography.dark,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: AppColors.textPrimaryDark,
      elevation: 0,
    ),

    cardTheme: CardThemeData(
      color: AppColors.surfaceDark,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(AppRadius.lg),
        ),
        side: const BorderSide(
          color: AppColors.borderDark,
        ),
      ),
    ),
  );
}