import 'package:flutter/material.dart';

/// Centralized color palette for the CT Todo app.
/// Primary: Blue tones to complement the Caretutors logo.
class AppColors {
  AppColors._();

  // ── Primary Blue Palette ──────────────────────────────────────────────
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primarySurface = Color(0xFFE3F2FD);

  // ── Background & Surface ──────────────────────────────────────────────
  static const Color background = Color(0xFFF8FAFF);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;
  static const Color scaffoldBackground = Color(0xFFF5F7FB);

  // ── Text Colors ───────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1D26);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Colors.white;

  // ── Text Field ────────────────────────────────────────────────────────
  static const Color textFieldFill = Color(0xFFF3F4F6);
  static const Color textFieldBorder = Color(0xFFD1D5DB);
  static const Color textFieldFocusBorder = Color(0xFF1565C0);
  static const Color textFieldHint = Color(0xFF9CA3AF);

  // ── Status Colors (for todo statuses) ─────────────────────────────────
  static const Color pending = Color(0xFFF59E0B);
  static const Color pendingBg = Color(0xFFFEF3C7);
  static const Color inProgress = Color(0xFF3B82F6);
  static const Color inProgressBg = Color(0xFFDBEAFE);
  static const Color cancelled = Color(0xFFEF4444);
  static const Color cancelledBg = Color(0xFFFEE2E2);

  // ── Misc ──────────────────────────────────────────────────────────────
  static const Color divider = Color(0xFFE5E7EB);
  static const Color shadow = Color(0x0F000000);
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
  static const Color iconColor = Color(0xFF6B7280);

  // ── Stat Card Gradients ───────────────────────────────────────────────
  static const List<Color> totalGradient = [Color(0xFF1565C0), Color(0xFF42A5F5)];
  static const List<Color> pendingGradient = [Color(0xFFF59E0B), Color(0xFFFBBF24)];
  static const List<Color> inProgressGradient = [Color(0xFF7C3AED), Color(0xFFA78BFA)];
  static const List<Color> cancelledGradient = [Color(0xFFEF4444), Color(0xFFF87171)];
}
