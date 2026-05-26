import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // Headings
  static TextStyle get displayLarge => GoogleFonts.poppins(
        fontSize: 46,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        height: 1.08,
        color: AppColors.textPrimary,
      );

  static TextStyle get displayMedium => GoogleFonts.poppins(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        height: 1.1,
        color: AppColors.textPrimary,
      );

  static TextStyle get displaySmall => GoogleFonts.poppins(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        height: 1.12,
        color: AppColors.textPrimary,
      );

  static TextStyle get h1 => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        height: 1.15,
        color: AppColors.textPrimary,
      );

  static TextStyle get h2 => GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get h3 => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get h4 => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  // Body
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: AppColors.textMuted,
      );

  // Labels
  static TextStyle get labelLarge => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.25,
        color: AppColors.textMuted,
      );

  // Special
  static TextStyle get statNumber => GoogleFonts.poppins(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: AppColors.textPrimary,
      );

  static TextStyle get statNumberLarge => GoogleFonts.poppins(
        fontSize: 46,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        color: AppColors.textPrimary,
      );

  static TextStyle get buttonText => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: AppColors.textPrimary,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 10.5,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        color: AppColors.textMuted,
      );

  static TextStyle get overline => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: AppColors.textMuted,
      );

  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
}
