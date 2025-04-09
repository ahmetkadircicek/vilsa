import 'package:flutter/material.dart';
import 'package:vilsa/core/constants/color_constants.dart';

class LightTheme {
  LightTheme._();

  static ThemeData theme = ThemeData(
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceContainer: AppColors.surfaceContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
    ),
    dividerTheme: DividerThemeData(
      indent: 80,
      endIndent: 80,
      color: AppColors.secondary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(letterSpacing: 1),
      filled: true,
      fillColor: AppColors.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.formBorder, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.tertiary, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.formBorder, width: 1.0),
      ),
    ),
  );
}
