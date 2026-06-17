import 'package:flutter/material.dart';

/// Bảng màu & theme dùng chung cho toàn app SmartStay.
class AppColors {
  AppColors._();

  // Tông kem / be làm nền chính
  static const Color cream = Color(0xFFF5F1E8);
  static const Color creamDark = Color(0xFFEDE6D6);
  static const Color surface = Color(0xFFFFFFFF);

  // Tông vàng gold / nâu làm điểm nhấn
  static const Color gold = Color(0xFFA8884E);
  static const Color goldDark = Color(0xFF8B6F3D);
  static const Color goldLight = Color(0xFFD9C7A0);

  // Nền tối cho màn hình loading
  static const Color darkBg = Color(0xFF2A2622);
  static const Color darkBg2 = Color(0xFF1E1B18);

  // Chữ
  static const Color textPrimary = Color(0xFF3D372E);
  static const Color textSecondary = Color(0xFF8A8275);
  static const Color hint = Color(0xFFB5AE9F);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.gold,
        secondary: AppColors.goldDark,
        surface: AppColors.surface,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
        fontFamily: 'Georgia',
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
    );
  }
}
