import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDecorations {
  // === BORDER RADIUS ===
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 100;

  // === BORDER RADIUS OBJECTS ===
  static BorderRadius get borderRadiusXs => BorderRadius.circular(radiusXs);
  static BorderRadius get borderRadiusSm => BorderRadius.circular(radiusSm);
  static BorderRadius get borderRadiusMd => BorderRadius.circular(radiusMd);
  static BorderRadius get borderRadiusLg => BorderRadius.circular(radiusLg);
  static BorderRadius get borderRadiusXl => BorderRadius.circular(radiusXl);
  static BorderRadius get borderRadiusFull => BorderRadius.circular(radiusFull);

  // === SHADOWS ===
  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> shadowGlow(Color color, {double intensity = 0.3}) => [
        BoxShadow(
          color: color.withOpacity(intensity),
          blurRadius: 20,
          spreadRadius: -4,
        ),
      ];

  static List<BoxShadow> shadowGlowStrong(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.4),
          blurRadius: 30,
          spreadRadius: -2,
        ),
      ];

  // === CARD DECORATIONS ===
  static BoxDecoration get glassCard => BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: borderRadiusLg,
        border: Border.all(color: AppColors.glassBorder, width: 1),
      );

  static BoxDecoration get glassCardBright => BoxDecoration(
        color: AppColors.glassHighlight,
        borderRadius: borderRadiusLg,
        border: Border.all(color: AppColors.glassBorder, width: 1),
      );

  static BoxDecoration get gradientCard => BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: borderRadiusLg,
        border: Border.all(color: AppColors.glassBorder, width: 1),
      );

  static BoxDecoration get surfaceCard => BoxDecoration(
        color: AppColors.surface,
        borderRadius: borderRadiusLg,
        border: Border.all(color: AppColors.glassBorder, width: 1),
      );

  static BoxDecoration get elevatedCard => BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: borderRadiusLg,
        boxShadow: shadowMd,
      );

  // === BUTTON DECORATIONS ===
  static BoxDecoration get primaryButton => BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: borderRadiusMd,
        boxShadow: shadowGlow(AppColors.primary),
      );

  static BoxDecoration get secondaryButton => BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: borderRadiusMd,
        border: Border.all(color: AppColors.glassBorder, width: 1),
      );

  static BoxDecoration get ghostButton => BoxDecoration(
        color: Colors.transparent,
        borderRadius: borderRadiusMd,
        border: Border.all(color: AppColors.primary, width: 1.5),
      );

  static BoxDecoration get accentButton => BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: borderRadiusMd,
        boxShadow: shadowGlow(AppColors.accent),
      );

  // === INPUT DECORATIONS ===
  static BoxDecoration inputDefault = BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: borderRadiusMd,
        border: Border.all(color: Colors.transparent, width: 2),
      );

  static BoxDecoration inputFocused = BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: borderRadiusMd,
        border: Border.all(color: AppColors.primary, width: 2),
      );

  static BoxDecoration inputError = BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: borderRadiusMd,
        border: Border.all(color: AppColors.error, width: 2),
      );

  // === CHIP/BADGE DECORATIONS ===
  static BoxDecoration get chipDefault => BoxDecoration(
        color: AppColors.surfaceBright,
        borderRadius: borderRadiusFull,
      );

  static BoxDecoration get chipPrimary => BoxDecoration(
        color: AppColors.primaryMuted,
        borderRadius: borderRadiusFull,
      );

  static BoxDecoration get chipSuccess => BoxDecoration(
        color: AppColors.success.withOpacity(0.15),
        borderRadius: borderRadiusFull,
      );

  static BoxDecoration get chipWarning => BoxDecoration(
        color: AppColors.warning.withOpacity(0.15),
        borderRadius: borderRadiusFull,
      );

  static BoxDecoration get chipError => BoxDecoration(
        color: AppColors.error.withOpacity(0.15),
        borderRadius: borderRadiusFull,
      );

  // === AVATAR DECORATIONS ===
  static BoxDecoration avatarGradient({double size = 48}) => BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: shadowGlow(AppColors.primary, intensity: 0.2),
      );

  static BoxDecoration get avatarSurface => BoxDecoration(
        color: AppColors.surfaceLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.glassBorder, width: 2),
      );

  // === DIVIDERS ===
  static BoxDecoration get divider => BoxDecoration(
        color: AppColors.glassBorder,
      );

  // === ICON CONTAINER ===
  static BoxDecoration iconContainer(Color color) => BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: borderRadiusSm,
      );

  // === NAV BAR ===
  static BoxDecoration get bottomNavBar => BoxDecoration(
        color: AppColors.surface,
        borderRadius: borderRadiusXl,
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: shadowMd,
      );

  // === BLUR FILTER (for glass effects) ===
  static ImageFilter get blurFilter => ImageFilter.blur(sigmaX: 10, sigmaY: 10);
  static ImageFilter get blurFilterLight => ImageFilter.blur(sigmaX: 5, sigmaY: 5);
  static ImageFilter get blurFilterHeavy => ImageFilter.blur(sigmaX: 20, sigmaY: 20);
}
