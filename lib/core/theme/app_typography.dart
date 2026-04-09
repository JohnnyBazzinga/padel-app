import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // === DISPLAY (Hero sections, large numbers) ===
  static TextStyle get displayLarge => GoogleFonts.spaceGrotesk(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        height: 1.1,
        color: AppColors.textPrimary,
      );

  static TextStyle get displayMedium => GoogleFonts.spaceGrotesk(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        height: 1.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get displaySmall => GoogleFonts.spaceGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
        color: AppColors.textPrimary,
      );

  // === HEADINGS (Section titles) ===
  static TextStyle get h1 => GoogleFonts.spaceGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get h2 => GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: AppColors.textPrimary,
      );

  static TextStyle get h3 => GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get h4 => GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  // === BODY (Content text - Inter for readability) ===
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppColors.textMuted,
      );

  // === LABELS (UI elements, buttons) ===
  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: AppColors.textMuted,
      );

  // === SPECIAL STYLES ===
  static TextStyle get statNumber => GoogleFonts.spaceGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
        color: AppColors.textPrimary,
      );

  static TextStyle get statNumberLarge => GoogleFonts.spaceGrotesk(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -2,
        color: AppColors.textPrimary,
      );

  static TextStyle get buttonText => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: AppColors.textMuted,
      );

  static TextStyle get overline => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: AppColors.textMuted,
      );

  // === HELPER: Apply color to any style ===
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
}
