import 'package:flutter/material.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';

/// Ảnh tải từ mạng dùng chung: có vòng xoay khi đang tải và ảnh dự phòng
/// (nền kem + icon) khi lỗi hoặc offline — để UI không bao giờ bị trống.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
  });

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _fallback(
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, _, _) => _fallback(
        const Icon(Icons.villa_outlined, size: 56, color: AppColors.gold),
      ),
    );
  }

  Widget _fallback(Widget child) => Container(
        color: AppColors.creamDark,
        alignment: Alignment.center,
        child: child,
      );
}
