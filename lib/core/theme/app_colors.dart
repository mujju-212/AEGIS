import 'package:flutter/material.dart';

/// App color palette — Privacy feel: deep blues, blacks.
/// Green = positive/good | Orange = warning | Red = serious alerts.
class AppColors {
  AppColors._();

  // Primary palette — Deep blues & blacks
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF121828);
  static const Color surfaceLight = Color(0xFF1A2235);
  static const Color surfaceCard = Color(0xFF1E2840);
  static const Color surfaceBorder = Color(0xFF2A3550);

  // Primary accent — Soft blue
  static const Color primary = Color(0xFF4A90D9);
  static const Color primaryLight = Color(0xFF6AABF0);
  static const Color primaryDark = Color(0xFF2D6DB5);

  // Semantic colors
  static const Color positive = Color(0xFF4CAF50);       // Green — good behaviour
  static const Color positiveLight = Color(0xFF81C784);
  static const Color warning = Color(0xFFFF9800);         // Orange — warnings
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color danger = Color(0xFFE53935);          // Red — serious alerts only
  static const Color dangerLight = Color(0xFFEF5350);

  // Text
  static const Color textPrimary = Color(0xFFE8ECF4);
  static const Color textSecondary = Color(0xFF8A94A8);
  static const Color textMuted = Color(0xFF5A6478);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Addiction risk gradient
  static const Color riskLow = Color(0xFF4CAF50);
  static const Color riskMedium = Color(0xFFFF9800);
  static const Color riskHigh = Color(0xFFE53935);

  // Privacy badge
  static const Color privacyBadge = Color(0xFF00E676);

  // Shimmer
  static const Color shimmerBase = Color(0xFF1A2235);
  static const Color shimmerHighlight = Color(0xFF2A3550);

  // Aliases used across screens
  static const Color border = surfaceBorder;
  static const Color surfaceElevated = surfaceLight;
  static const Color accent = primaryLight;
}
