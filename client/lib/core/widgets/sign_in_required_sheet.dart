import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../theme/app_theme.dart';

/// Mời đăng nhập khi khách vãng lai chạm vào tính năng cần tài khoản.
///
/// Dùng bottom sheet thay vì đẩy thẳng sang màn Login vì đây là app mobile:
/// người dùng đang xem dở một khách sạn mà bị nhảy nguyên trang thì mất mạch
/// thao tác. Sheet trượt lên từ đáy — tầm ngón cái, vuốt xuống là huỷ, và
/// khách quay lại đúng chỗ đang đứng.
///
/// Trả về `true` nếu người dùng chọn đi đăng nhập/đăng ký.
Future<bool> showSignInRequiredSheet(
  BuildContext context, {
  required String message,
}) async {
  final goToAuth = await showModalBottomSheet<bool>(
    context: context,
    // Bo góc + kéo được: đúng thói quen thao tác trên điện thoại.
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: AppTheme.surfaceContainerLowest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => _SignInRequiredSheet(message: message),
  );

  if (goToAuth != true || !context.mounted) return false;
  return true;
}

class _SignInRequiredSheet extends StatelessWidget {
  const _SignInRequiredSheet({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      // viewInsets: chừa chỗ cho bàn phím; viewPadding.bottom: tránh thanh
      // gesture của điện thoại tràn lên nút.
      padding: EdgeInsets.fromLTRB(
        24,
        8,
        24,
        24 + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppTheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 30,
                color: AppTheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Đăng nhập để tiếp tục',
            textAlign: TextAlign.center,
            style: t.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: t.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          // Vùng chạm 52px — thoải mái cho ngón tay, hơn mức tối thiểu 48px.
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.secondary,
              foregroundColor: AppTheme.onSecondary,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
              context.push(AppRoutes.login);
            },
            child: const Text('Đăng nhập'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              side: const BorderSide(color: AppTheme.outline),
              foregroundColor: AppTheme.onBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
              context.push(AppRoutes.register);
            },
            child: const Text('Tạo tài khoản mới'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Để sau'),
          ),
        ],
      ),
    );
  }
}
