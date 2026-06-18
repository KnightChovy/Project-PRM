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

  // ---- Bảng màu Material 3 (lấy từ mockup) — dùng cho các màn Profile ----
  static const Color primary = Color(0xFF5F5E5B);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFF4F1ED);
  static const Color onPrimaryContainer = Color(0xFF6E6D6A);
  static const Color secondary = Color(0xFF735A35);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFDDAAC);
  static const Color onSecondaryContainer = Color(0xFF785E39);
  static const Color tertiary = Color(0xFF735C00);
  static const Color tertiaryContainer = Color(0xFFFFF0CE);
  static const Color onTertiaryContainer = Color(0xFF866A00);
  static const Color tertiaryFixedDim = Color(0xFFE9C349); // toggles on, gold card
  static const Color tertiaryFixed = Color(0xFFFFE088);
  static const Color onTertiaryFixed = Color(0xFF241A00);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color background = Color(0xFFFCF9F8);
  static const Color onBackground = Color(0xFF1C1B1B);
  static const Color surface = Color(0xFFFCF9F8);
  static const Color onSurface = Color(0xFF1C1B1B);
  static const Color onSurfaceVariant = Color(0xFF484740);
  static const Color surfaceVariant = Color(0xFFE5E2E1);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF6F3F2);
  static const Color surfaceContainer = Color(0xFFF0EDED);
  static const Color surfaceContainerHigh = Color(0xFFEAE7E7);
  static const Color outline = Color(0xFF79776F);
  static const Color outlineVariant = Color(0xFFCAC6BD);

  /// Theme chính của app — tông kem/gold, đồng bộ với [AppColors]
  /// vốn đang được dùng trực tiếp ở phần lớn các màn hình.
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
