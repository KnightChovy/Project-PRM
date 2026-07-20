import 'package:flutter/material.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';

/// Mô tả 1 mục trên thanh điều hướng (icon + nhãn).
class MainTab {
  final IconData icon;
  final String label;
  const MainTab(this.icon, this.label);
}

/// Thanh điều hướng đáy 5 mục. Mục giữa "My Booking" được làm NỔI BẬT
/// (vòng tròn gradient vàng, icon trắng) so với 4 mục còn lại.
class MainBottomNav extends StatelessWidget {
  const MainBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Index của mục nổi bật (My Booking).
  static const int highlightedIndex = 2;

  static const List<MainTab> tabs = [
    MainTab(Icons.home_rounded, 'Home'),
    MainTab(Icons.favorite_border, 'Wishlist'),
    MainTab(Icons.calendar_month, 'My Booking'),
    MainTab(Icons.chat_bubble_outline, 'Chatbot'),
    MainTab(Icons.person_outline, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: List.generate(tabs.length, (i) {
              final tab = tabs[i];
              final selected = i == currentIndex;
              if (i == highlightedIndex) {
                return Expanded(
                  child: _CenterItem(tab: tab, onTap: () => onTap(i)),
                );
              }
              return Expanded(
                child: _NavItem(
                  tab: tab,
                  selected: selected,
                  onTap: () => onTap(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// Mục thường: icon + nhãn, đổi màu khi được chọn.
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final MainTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.goldDark : AppColors.textSecondary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(tab.icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            tab.label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mục giữa (My Booking) được làm nổi bật bằng vòng tròn gradient vàng.
class _CenterItem extends StatelessWidget {
  const _CenterItem({required this.tab, required this.onTap});

  final MainTab tab;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.goldLight, AppColors.goldDark],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x558B6F3D),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(tab.icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 4),
          Text(
            tab.label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.goldDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
