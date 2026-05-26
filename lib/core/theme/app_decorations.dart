import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDecorations {
  // Radius
  static const double radiusXs = 6;
  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 20;
  static const double radiusXl = 28;
  static const double radiusFull = 999;

  // Radius objects
  static BorderRadius get borderRadiusXs => BorderRadius.circular(radiusXs);
  static BorderRadius get borderRadiusSm => BorderRadius.circular(radiusSm);
  static BorderRadius get borderRadiusMd => BorderRadius.circular(radiusMd);
  static BorderRadius get borderRadiusLg => BorderRadius.circular(radiusLg);
  static BorderRadius get borderRadiusXl => BorderRadius.circular(radiusXl);
  static BorderRadius get borderRadiusFull => BorderRadius.circular(radiusFull);

  // Elevations
  static List<BoxShadow> get shadowXs => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> shadowGlow(Color color, {double intensity = 0.24}) => [
        BoxShadow(
          color: color.withValues(alpha: intensity),
          blurRadius: 18,
          spreadRadius: -4,
        ),
      ];

  static List<BoxShadow> shadowGlowStrong(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.3),
          blurRadius: 24,
          spreadRadius: -2,
        ),
      ];

  // Card decorations
  static BoxDecoration get glassCard => BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: borderRadiusLg,
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: shadowXs,
      );

  static BoxDecoration get glassCardBright => BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadiusLg,
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: shadowSm,
      );

  static BoxDecoration get gradientCard => BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: borderRadiusLg,
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: shadowSm,
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

  // Buttons
  static BoxDecoration get primaryButton => BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: borderRadiusMd,
        boxShadow: shadowGlow(AppColors.primary, intensity: 0.28),
      );

  static BoxDecoration get secondaryButton => BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: borderRadiusMd,
        border: Border.all(color: AppColors.glassBorder, width: 1),
      );

  static BoxDecoration get ghostButton => BoxDecoration(
        color: Colors.transparent,
        borderRadius: borderRadiusMd,
        border: Border.all(color: AppColors.glassBorder, width: 1.2),
      );

  static BoxDecoration get accentButton => BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: borderRadiusMd,
        boxShadow: shadowGlow(AppColors.accent),
      );

  // Input
  static BoxDecoration inputDefault = BoxDecoration(
        color: AppColors.surface,
        borderRadius: borderRadiusMd,
        border: Border.all(color: AppColors.glassBorder, width: 1.2),
      );

  static BoxDecoration inputFocused = BoxDecoration(
        color: AppColors.surface,
        borderRadius: borderRadiusMd,
        border: Border.all(color: AppColors.primary, width: 1.5),
      );

  static BoxDecoration inputError = BoxDecoration(
        color: AppColors.surface,
        borderRadius: borderRadiusMd,
        border: Border.all(color: AppColors.error, width: 1.5),
      );

  // Chips / badges
  static BoxDecoration get chipDefault => BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: borderRadiusFull,
      );

  static BoxDecoration get chipPrimary => BoxDecoration(
        color: AppColors.primaryMuted,
        borderRadius: borderRadiusFull,
      );

  static BoxDecoration get chipSuccess => BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: borderRadiusFull,
      );

  static BoxDecoration get chipWarning => BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: borderRadiusFull,
      );

  static BoxDecoration get chipError => BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: borderRadiusFull,
      );

  // Avatar
  static BoxDecoration avatarGradient({double size = 48}) => BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: shadowGlow(AppColors.primary, intensity: 0.22),
      );

  static BoxDecoration get avatarSurface => BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.glassBorder, width: 2),
      );

  // Misc
  static BoxDecoration get bottomNavBar => BoxDecoration(
        color: AppColors.surface,
        borderRadius: borderRadiusXl,
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: shadowMd,
      );

  // Filters
  static ImageFilter get blurFilter => ImageFilter.blur(sigmaX: 10, sigmaY: 10);
  static ImageFilter get blurFilterLight => ImageFilter.blur(sigmaX: 5, sigmaY: 5);
  static ImageFilter get blurFilterHeavy => ImageFilter.blur(sigmaX: 20, sigmaY: 20);
}
