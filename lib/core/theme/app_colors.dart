import 'package:flutter/material.dart';

class AppColors {
  // Brand + accent (Instagram-inspired, bright and social)
  static const Color primary = Color(0xFFE1306C);
  static const Color primaryDark = Color(0xFFC72B5D);
  static const Color primaryMuted = Color(0x1FE1306C);
  static const Color primarySubtle = Color(0x10E1306C);

  static const Color secondary = Color(0xFF833AB4);
  static const Color secondaryDark = Color(0xFF5E2B97);
  static const Color secondaryMuted = Color(0x1F833AB4);

  static const Color accent = Color(0xFFFCAF45);
  static const Color accentDark = Color(0xFFF29938);
  static const Color accentGlow = Color(0xFFFFD56A);
  static const Color accentMuted = Color(0x29FCAF45);

  // Surfaces
  static const Color background = Color(0xFFF7F8FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF2F5FA);
  static const Color surfaceBright = Color(0xFFE8ECF5);
  static const Color card = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF9CA3AF);

  // Glass / strokes
  static const Color glassFill = Color(0xDBFFFFFF);
  static const Color glassBorder = Color(0xFFEBEEF5);
  static const Color glassHighlight = Color(0xF2FFFFFF);

  // Semantic
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFF87171);
  static const Color info = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFF60A5FA);

  // Skill levels
  static const Color beginner = Color(0xFF16A34A);
  static const Color intermediate = Color(0xFF2563EB);
  static const Color advanced = Color(0xFFF59E0B);
  static const Color professional = Color(0xFFDB2777);

  // Ranking tiers
  static const Color bronze = Color(0xFFCD7F32);
  static const Color silver = Color(0xFF9CA3AF);
  static const Color gold = Color(0xFFFBBF24);
  static const Color platinum = Color(0xFF94A3B8);
  static const Color diamond = Color(0xFF38BDF8);

  // Solid fill tokens (no visual gradients in the app)
  static const Color heroBackground = Color(0xFFF7F8FB);
  static const Color cardSurface = surface;
  static const Color darkOverlaySurface = surface;

  // Status
  static const Color confirmed = success;
  static const Color pending = warning;
  static const Color cancelled = error;
  static const Color completed = info;

  static Color getSkillColor(String level) {
    switch (level.toLowerCase()) {
      case 'iniciante':
      case 'beginner':
        return beginner;
      case 'intermedio':
      case 'intermediate':
        return intermediate;
      case 'avancado':
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
      case 'concluido':
        return completed;
      default:
        return textMuted;
    }
  }
}
