import 'package:flutter/material.dart';

/// Uygulamanın tüm renklerini içeren sınıf
class AppColors {
  AppColors._();

  // Ana renkler
  static const Color primary = Color(0xFF5F17E6);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFFD5D7DF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color tertiary = Color(0xFFEEEEEE);
  static const Color onTertiary = Color(0xFF1A1A1A);

  // Yüzey renkleri
  static const Color surface = Color(0xFFFAFAFA);
  static const Color onSurface = Color(0xFF1A1A1A);
  static const Color surfaceContainer = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFEFEFEF);
  static const Color onSecondaryContainer = Color(0xFF5F17E6);

  // Hata renkleri
  static const Color error = Color(0xFFD32F2F);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFCDD2);

  // Ortak kullanılan renkler
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // Gri tonları
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Siyah tonları
  static const Color black87 = Color(0xDD000000); // %87 opaklık
  static const Color black54 = Color(0x8A000000); // %54 opaklık
  static const Color black45 = Color(0x73000000); // %45 opaklık
  static const Color black38 = Color(0x61000000); // %38 opaklık
  static const Color black26 = Color(0x42000000); // %26 opaklık
  static const Color black12 = Color(0x1F000000); // %12 opaklık

  // Grafik renkleri
  static const Color chartLine = Color(0XFF534BE6);
  static const Color chartGradientStart = Color(0XFF534BE6);

  // Temettü renkleri
  static const Color dividendGreen = Color(0xFF388E3C); // green700

  // Form alan renkleri
  static const Color formBorder = Color(0xFFAC1CF5);
}
