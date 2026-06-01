import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const Color primary       = Color(0xFFE31837);   // Hunger Point Red
  static const Color primaryDark   = Color(0xFFC0000F);
  static const Color primaryLight  = Color(0xFFFF6B6B);
  static const Color accent        = Color(0xFFE31837);
  static const Color accentDark    = Color(0xFFC0000F);
  static const Color background    = Color(0xFFF5F5F5);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color cardBg        = Color(0xFFF8F8F8);
  static const Color textPrimary   = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight     = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color success       = Color(0xFF43A047);
  static const Color error         = Color(0xFFE53935);
  static const Color divider       = Color(0xFFEEEEEE);
  static const Color shadow        = Color(0x1A000000);
  static const Color shimmerBase   = Color(0xFFE0E0E0);
  static const Color shimmerHigh   = Color(0xFFF5F5F5);

  // Fancy red gradient — use across banners, headers, buttons
  static const List<Color> redGradient = [Color(0xFFE31837), Color(0xFFFF6B6B)];
  static const List<Color> redGradientDeep = [Color(0xFFC0000F), Color(0xFFE31837)];
}
