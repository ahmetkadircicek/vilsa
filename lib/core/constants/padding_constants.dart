import 'package:flutter/material.dart';

class PaddingConstants {
  static const EdgeInsets zeroPadding = EdgeInsets.zero;

  static EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 16.0) + EdgeInsets.only(top: 16.0, bottom: 80.0);

  static const EdgeInsets allSmall = EdgeInsets.all(12.0);
  static const EdgeInsets allMedium = EdgeInsets.all(16.0);
  static const EdgeInsets allLarge = EdgeInsets.all(24.0);

  static const EdgeInsets symmetricHorizontalSmall = EdgeInsets.symmetric(horizontal: 12.0);
  static const EdgeInsets symmetricHorizontalMedium = EdgeInsets.symmetric(horizontal: 16.0);
  static const EdgeInsets symmetricHorizontalLarge = EdgeInsets.symmetric(horizontal: 24.0);

  static const EdgeInsets symmetricVerticalSmall = EdgeInsets.symmetric(vertical: 12.0);
  static const EdgeInsets symmetricVerticalMedium = EdgeInsets.symmetric(vertical: 16.0);
  static const EdgeInsets symmetricVerticalLarge = EdgeInsets.symmetric(vertical: 24.0);

  static const EdgeInsets onlyTopSmall = EdgeInsets.only(top: 12.0);
  static const EdgeInsets onlyTopMedium = EdgeInsets.only(top: 16.0);
  static const EdgeInsets onlyTopLarge = EdgeInsets.only(top: 24.0);

  static const EdgeInsets onlyBottomSmall = EdgeInsets.only(bottom: 12.0);
  static const EdgeInsets onlyBottomMedium = EdgeInsets.only(bottom: 16.0);
  static const EdgeInsets onlyBottomLarge = EdgeInsets.only(bottom: 24.0);

  static const EdgeInsets onlyLeftSmall = EdgeInsets.only(left: 12.0);
  static const EdgeInsets onlyLeftMedium = EdgeInsets.only(left: 16.0);
  static const EdgeInsets onlyLeftLarge = EdgeInsets.only(left: 24.0);

  static const EdgeInsets onlyRightSmall = EdgeInsets.only(right: 12.0);
  static const EdgeInsets onlyRightMedium = EdgeInsets.only(right: 16.0);
  static const EdgeInsets onlyRightLarge = EdgeInsets.only(right: 24.0);
}
