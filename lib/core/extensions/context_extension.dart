import 'package:flutter/material.dart';

extension BuildContextExtension<T> on BuildContext {
  // Size Extensions
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;
  Size get size => MediaQuery.of(this).size;

  // Color Extensions
  Color get primaryColor => Theme.of(this).primaryColor;
  Color get primaryColorDark => Theme.of(this).primaryColorDark;
  Color get primaryColorLight => Theme.of(this).primaryColorLight;
  Color get primary => Theme.of(this).colorScheme.primary;
  Color get onPrimary => Theme.of(this).colorScheme.onPrimary;
  Color get secondary => Theme.of(this).colorScheme.secondary;
  Color get onSecondary => Theme.of(this).colorScheme.onSecondary;
  Color get tertiary => Theme.of(this).colorScheme.tertiary;
  Color get onTertiary => Theme.of(this).colorScheme.onTertiary;
  Color get cardColor => Theme.of(this).cardColor;
  Color get error => Theme.of(this).colorScheme.error;
  Color get onError => Theme.of(this).colorScheme.onError;
  Color get errorContainer => Theme.of(this).colorScheme.errorContainer;
  Color get surface => Theme.of(this).colorScheme.surface;
  Color get onSurface => Theme.of(this).colorScheme.onSurface;
  Color get surfaceContainer => Theme.of(this).colorScheme.surfaceContainer;
  Color get surfaceContainerHigh =>
      Theme.of(this).colorScheme.surfaceContainerHigh;
  Color get onSecondaryContainer =>
      Theme.of(this).colorScheme.onSecondaryContainer;

  // Spacer
  Widget spacerHeight(double percentage) {
    final height = MediaQuery.of(this).size.height * (percentage / 100);
    return SizedBox(height: height);
  }

  Widget spacerWidth(double percentage) {
    final width = MediaQuery.of(this).size.width * (percentage / 100);
    return SizedBox(width: width);
  }

// Spacer with fixed height in pixels
  Widget spacerHeightFixed(double height) {
    return SizedBox(height: height);
  }

// Spacer with fixed width in pixels
  Widget spacerWidthFixed(double width) {
    return SizedBox(width: width);
  }
}
