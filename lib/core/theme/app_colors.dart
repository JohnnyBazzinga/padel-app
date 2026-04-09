import 'package:flutter/material.dart';

class AppColors {
  // === PRIMARY (Electric Cyan - Energetic, Modern) ===
  static const Color primary = Color(0xFF00F5D4);
  static const Color primaryDark = Color(0xFF00C4A7);
  static Color get primaryMuted => primary.withOpacity(0.15);
  static Color get primarySubtle => primary.withOpacity(0.08);

  // === SECONDARY (Electric Purple - Premium feel) ===
  static const Color secondary = Color(0xFF9B5DE5);
  static const Color secondaryDark = Color(0xFF7B4BC2);
  static Color get secondaryMuted => secondary.withOpacity(0.15);

  // === ACCENT (Neon Orange - Energy, Sports) ===
  static const Color accent = Color(0xFFFF6B35);
  static const Color accentGlow = Color(0xFFFF8C5A);
  static Color get accentMuted => accent.withOpacity(0.15);

  // === BACKGROUNDS (Layered depth - Navy tones) ===
  static const Color background = Color(0xFF0A0E17);
  static const Color surface = Color(0xFF141B2D);
  static const Color surfaceLight = Color(0xFF1C2541);
  static const Color surfaceBright = Color(0xFF243B55);
  static const Color card = Color(0xFF1A2235);

  // === TEXT (Better contrast) ===
  static const Color textPrimary = Color(0xFFF8F9FA);
  static const Color textSecondary = Color(0xFFADB5BD);
  static const Color textMuted = Color(0xFF6C757D);
  static const Color textDisabled = Color(0xFF495057);

  // === GLASS EFFECT ===
  static Color get glassFill => Colors.white.withOpacity(0.08);
  static Color get glassBorder => Colors.white.withOpacity(0.12);
  static Color get glassHighlight => Colors.white.withOpacity(0.15);

  // === SEMANTIC ===
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);

  // === SKILL LEVELS ===
  static const Color beginner = Color(0xFF10B981);
  static const Color intermediate = Color(0xFF3B82F6);
  static const Color advanced = Color(0xFFF59E0B);
  static const Color professional = Color(0xFFEF4444);

  // === RANKING TIERS ===
  static const Color bronze = Color(0xFFCD7F32);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color gold = Color(0xFFFFD700);
  static const Color platinum = Color(0xFFE5E4E2);
  static const Color diamond = Color(0xFFB9F2FF);

  // === GRADIENTS ===
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00F5D4), Color(0xFF00B4D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF9B5DE5), Color(0xFF7B4BC2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8C5A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1C2541), Color(0xFF141B2D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF00F5D4), Color(0xFF9B5DE5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkOverlay = LinearGradient(
    colors: [Colors.transparent, Color(0xFF0A0E17)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient surfaceGradient = LinearGradient(
    colors: [surfaceLight, surface],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // === STATUS COLORS ===
  static const Color confirmed = success;
  static const Color pending = warning;
  static const Color cancelled = error;
  static const Color completed = info;

  // === HELPER METHODS ===
  static Color getSkillColor(String level) {
    switch (level.toLowerCase()) {
      case 'iniciante':
      case 'beginner':
        return beginner;
      case 'intermédio':
      case 'intermediate':
        return intermediate;
      case 'avançado':
      case 'advanced':
        return advanced;
      case 'profissional':
      case 'professional':
        return professional;
      default:
        return textMuted;
    }
  }

  static Color getRankColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'bronze':
        return bronze;
      case 'silver':
      case 'prata':
        return silver;
      case 'gold':
      case 'ouro':
        return gold;
      case 'platinum':
      case 'platina':
        return platinum;
      case 'diamond':
      case 'diamante':
        return diamond;
      default:
        return textMuted;
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'confirmado':
        return confirmed;
      case 'pending':
      case 'pendente':
        return pending;
      case 'cancelled':
      case 'cancelado':
        return cancelled;
      case 'completed':
      case 'concluído':
        return completed;
      default:
        return textMuted;
    }
  }
}
