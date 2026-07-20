import 'package:flutter/material.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';

/// Kiểu thông báo — quyết định icon và màu nhấn của dialog.
enum AppMessageType { error, success }

/// Dialog thông báo dùng chung (lỗi đăng nhập/đăng ký, gửi OTP thành công...).
///
/// Chỉ là widget hiển thị: không chứa logic nghiệp vụ, không tự gọi UseCase.
/// Màn hình gọi [showAppMessageDialog] SAU khi đã await xong action của Notifier.
class AppMessageDialog extends StatelessWidget {
  const AppMessageDialog({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.actionLabel = 'OK',
  });

  final AppMessageType type;
  final String title;
  final String message;
  final String actionLabel;

  bool get _isError => type == AppMessageType.error;

  Color get _accent => _isError ? AppTheme.error : AppColors.goldDark;

  Color get _accentSoft =>
      _isError ? AppTheme.errorContainer : AppColors.creamDark;

  IconData get _icon =>
      _isError ? Icons.error_outline_rounded : Icons.check_circle_outline;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _accentSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, size: 34, color: _accent),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mở [AppMessageDialog]. Trả về future hoàn tất khi người dùng đóng dialog.
Future<void> showAppMessageDialog(
  BuildContext context, {
  required AppMessageType type,
  required String title,
  required String message,
  String actionLabel = 'OK',
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => AppMessageDialog(
      type: type,
      title: title,
      message: message,
      actionLabel: actionLabel,
    ),
  );
}

/// Lối tắt cho trường hợp phổ biến nhất: báo lỗi.
Future<void> showAppErrorDialog(
  BuildContext context, {
  String title = 'Something went wrong',
  required String message,
}) {
  return showAppMessageDialog(
    context,
    type: AppMessageType.error,
    title: title,
    message: message,
  );
}
