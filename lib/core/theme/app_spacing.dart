import 'package:flutter/material.dart';

class AppSpacing {
  // === BASE UNIT: 4px ===
  static const double unit = 4;

  // === SPACING SCALE ===
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double huge = 64;

  // === SCREEN PADDING ===
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets screenPaddingVertical = EdgeInsets.symmetric(vertical: 20);
  static const EdgeInsets screenPaddingAll = EdgeInsets.all(20);

  // === CARD PADDING ===
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets cardPaddingSmall = EdgeInsets.all(12);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(20);

  // === SECTION SPACING ===
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(vertical: 24);
  static const double sectionGap = 32;
  static const double sectionGapSmall = 24;

  // === COMPONENT GAPS ===
  static const double cardGap = 12;
  static const double itemGap = 8;
  static const double listGap = 16;
  static const double chipGap = 8;

  // === COMMON EDGE INSETS ===
  static EdgeInsets horizontal(double value) => EdgeInsets.symmetric(horizontal: value);
  static EdgeInsets vertical(double value) => EdgeInsets.symmetric(vertical: value);
  static EdgeInsets all(double value) => EdgeInsets.all(value);
  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);

  // === SIZED BOXES (for spacing between widgets) ===
  static const SizedBox verticalXxs = SizedBox(height: xxs);
  static const SizedBox verticalXs = SizedBox(height: xs);
  static const SizedBox verticalSm = SizedBox(height: sm);
  static const SizedBox verticalMd = SizedBox(height: md);
  static const SizedBox verticalLg = SizedBox(height: lg);
  static const SizedBox verticalXl = SizedBox(height: xl);
  static const SizedBox verticalXxl = SizedBox(height: xxl);
  static const SizedBox verticalXxxl = SizedBox(height: xxxl);

  static const SizedBox horizontalXxs = SizedBox(width: xxs);
  static const SizedBox horizontalXs = SizedBox(width: xs);
  static const SizedBox horizontalSm = SizedBox(width: sm);
  static const SizedBox horizontalMd = SizedBox(width: md);
  static const SizedBox horizontalLg = SizedBox(width: lg);
  static const SizedBox horizontalXl = SizedBox(width: xl);
  static const SizedBox horizontalXxl = SizedBox(width: xxl);
}
