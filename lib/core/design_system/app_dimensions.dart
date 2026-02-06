import 'package:flutter/widgets.dart';

class AppDimensions {
  AppDimensions._();

  static const double touchTargetMin = 44;
  static const double buttonHeight = 48;

  static const double iconSm = 16;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 48;
  static const double iconXxl = 64;

  static const double radiusSm = 8;
  static const double radiusMd = 14;
  static const double radiusLg = 20;
  static const double radiusXl = 28;

  static final BorderRadius cardRadius = BorderRadius.circular(radiusMd);
  static final BorderRadius buttonRadius = BorderRadius.circular(radiusSm);
}
