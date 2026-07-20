import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/session/app_session.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../providers/profile_notifier.dart';
import 'change_password_page.dart';
import 'edit_profile_page.dart';
import 'help_support_page.dart';
import 'notification_settings_page.dart';

/// Màn Profile — hiển thị hồ sơ thật từ `GET /v1/users/me`.
///
/// Các khối Loyalty / Stats / Travel Style vẫn là số liệu mẫu: backend chưa có
/// API điểm thưởng hay thống kê chuyến đi (xem chú thích tại từng widget).
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  /// Singleton dùng chung với Edit Profile / Notification Settings nên phải
  /// provide bằng `.value`, không để provider dispose nó.
  final _notifier = sl<ProfileNotifier>();

  @override
  void initState() {
    super.initState();
    // Khách vãng lai không có hồ sơ để tải — gọi API chỉ tổ nhận 401.
    if (sl<AppSession>().isSignedIn) _notifier.load();
  }

  /// Hỏi xác nhận rồi đăng xuất: xoá toàn bộ stack và quay về màn đăng nhập.
  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    // Gọi API thu hồi phiên + xoá token dưới máy. Trước đây màn này chỉ điều
    // hướng về login nên phiên vẫn sống và token vẫn nằm trong SharedPreferences.
    await sl<AuthNotifier>().logout();

    if (!context.mounted) return;
    // go() thay vì push() để dọn sạch lịch sử điều hướng sau khi đăng xuất.
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return ChangeNotifierProvider.value(
      value: _notifier,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
          title: Text(
            'SmartStay',
            style: t.headlineLarge?.copyWith(color: AppTheme.primary),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Consumer<ProfileNotifier>(
                builder: (context, notifier, _) =>
                    _Avatar(url: notifier.profile?.avatarUrl, radius: 16),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Consumer2<AppSession, ProfileNotifier>(
            builder: (context, session, notifier, _) {
              final signedIn = session.isSignedIn;
              return RefreshIndicator(
                // Khách vãng lai kéo xuống cũng không có gì để tải.
                onRefresh: signedIn ? notifier.load : () async {},
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  children: [
                    _ProfileHeader(notifier: notifier),
                    const SizedBox(height: 40),
                    // Điểm thưởng, thống kê, menu tài khoản và nút đăng xuất
                    // đều vô nghĩa khi chưa có tài khoản — ẩn hẳn thay vì hiện
                    // ra rồi báo lỗi lúc chạm vào.
                    if (signedIn) ...[
                      const _LoyaltyCard(),
                      const SizedBox(height: 40),
                      const _StatsRow(),
                      const SizedBox(height: 40),
                      const _TravelStyle(),
                      const SizedBox(height: 40),
                      const _MenuList(),
                      const SizedBox(height: 32),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.errorContainer.withValues(
                            alpha: 0.4,
                          ),
                          foregroundColor: AppTheme.error,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => _confirmLogout(context),
                        child: const Text(
                          'Log Out',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Center(
                      child: Text(
                        'Version 4.12.0',
                        style: t.labelSmall?.copyWith(
                          color: AppTheme.onSurfaceVariant.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Ảnh đại diện: dùng `avatarUrl` khi có, ngược lại vẽ icon người mặc định.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.radius});

  final String? url;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final hasImage = url != null && url!.isNotEmpty;
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppTheme.surfaceVariant,
      foregroundImage: hasImage ? NetworkImage(url!) : null,
      child: hasImage
          ? null
          : Icon(
              Icons.person,
              size: radius * 1.25,
              color: AppTheme.onSurfaceVariant,
            ),
    );
  }
}

/// Tên + email thật của người đang đăng nhập.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.notifier});

  final ProfileNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final profile = notifier.profile;

    // Khách vãng lai: không có hồ sơ nào để chờ, mời đăng nhập luôn thay vì
    // quay vòng tải mãi mãi.
    if (!sl<AppSession>().isSignedIn) {
      return const _GuestHeader();
    }

    // Lần tải đầu chưa có dữ liệu → chừa chỗ để layout không nhảy.
    if (profile == null) {
      return SizedBox(
        height: 220,
        child: Center(
          child: notifier.status == ProfileStatus.error
              ? _LoadError(
                  message: notifier.errorMessage ?? 'Không tải được hồ sơ.',
                  onRetry: notifier.load,
                )
              : const CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      children: [
        _Avatar(url: profile.avatarUrl, radius: 48),
        const SizedBox(height: 16),
        Text(profile.fullName, style: t.headlineLarge),
        const SizedBox(height: 4),
        Text(
          profile.email,
          style: t.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
        ),
        if (!profile.isEmailVerified) ...[
          const SizedBox(height: 8),
          Text(
            'Email chưa xác thực',
            style: t.labelSmall?.copyWith(color: AppTheme.error),
          ),
        ],
        const SizedBox(height: 16),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppTheme.outline),
            foregroundColor: AppTheme.onBackground,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const EditProfilePage())),
          child: const Text('Edit Profile'),
        ),
      ],
    );
  }
}

/// Trạng thái Profile của khách chưa đăng nhập.
class _GuestHeader extends StatelessWidget {
  const _GuestHeader();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      children: [
        const _Avatar(url: null, radius: 48),
        const SizedBox(height: 16),
        Text('Bạn chưa đăng nhập', style: t.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'Đăng nhập để quản lý hồ sơ, chuyến đi và danh sách yêu thích.',
          textAlign: TextAlign.center,
          style: t.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.secondary,
            foregroundColor: AppTheme.onSecondary,
            minimumSize: const Size(220, 52),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () => context.push(AppRoutes.login),
          child: const Text('Đăng nhập'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => context.push(AppRoutes.register),
          child: const Text('Chưa có tài khoản? Đăng ký'),
        ),
      ],
    );
  }
}

/// Báo lỗi tải hồ sơ kèm nút thử lại.
class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.cloud_off, size: 40, color: AppTheme.onSurfaceVariant),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        TextButton(onPressed: onRetry, child: const Text('Thử lại')),
      ],
    );
  }
}

/// TODO(backend): số liệu mẫu — chưa có API điểm thưởng / hạng thành viên.
/// Prisma đã có model loyalty nhưng không route/service nào expose ra.
class _LoyaltyCard extends StatelessWidget {
  const _LoyaltyCard();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppTheme.tertiaryFixedDim, AppTheme.tertiaryFixed],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MEMBERSHIP TIER',
                    style: t.labelSmall?.copyWith(
                      color: AppTheme.onTertiaryFixed.withValues(alpha: 0.8),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'SmartStay Gold',
                        style: t.headlineMedium?.copyWith(
                          color: AppTheme.onTertiaryFixed,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.stars,
                        size: 20,
                        color: AppTheme.onTertiaryFixed,
                      ),
                    ],
                  ),
                ],
              ),
              Icon(
                Icons.diamond,
                size: 32,
                color: AppTheme.onTertiaryFixed.withValues(alpha: 0.2),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '2,450',
                    style: t.displayLarge?.copyWith(
                      color: AppTheme.onTertiaryFixed,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Available Points',
                    style: t.labelLarge?.copyWith(
                      color: AppTheme.onTertiaryFixed.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.onTertiaryFixed,
                  foregroundColor: AppTheme.tertiaryFixed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {},
                child: const Text('Redeem'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// TODO(backend): số liệu mẫu — chưa có API thống kê chuyến đi / review / saved.
class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1C1B1B),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: const [
            _Stat(value: '12', label: 'Stays'),
            VerticalDivider(color: AppTheme.outlineVariant, width: 1),
            _Stat(value: '8', label: 'Reviews'),
            VerticalDivider(color: AppTheme.outlineVariant, width: 1),
            _Stat(value: '5', label: 'Saved'),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        children: [
          Text(value, style: t.headlineMedium),
          Text(
            label,
            style: t.labelSmall?.copyWith(color: AppTheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// TODO(backend): thẻ sở thích mẫu — chưa có API gợi ý phong cách du lịch.
class _TravelStyle extends StatelessWidget {
  const _TravelStyle();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1C1B1B),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Your Travel Style', style: t.headlineMedium),
              const SizedBox(width: 8),
              const Icon(
                Icons.auto_awesome,
                color: AppTheme.secondary,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'AI-curated based on your recent bookings.',
            style: t.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(label: 'Beach Lover'),
              _Chip(label: 'Business Traveler'),
              _Chip(label: 'Budget Conscious'),
              _Chip(label: '+', dashed: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.dashed = false});
  final String label;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: dashed ? null : AppTheme.primaryContainer,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: dashed ? AppTheme.outline : AppTheme.outlineVariant,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: dashed
              ? AppTheme.onSurfaceVariant
              : AppTheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _MenuList extends StatelessWidget {
  const _MenuList();

  @override
  Widget build(BuildContext context) {
    final items = <(int, IconData, String, Widget?)>[
      (
        0,
        Icons.person_outline,
        'Personal Information',
        const EditProfilePage(),
      ),
      (
        1,
        Icons.lock_outline,
        'Security & Password',
        const ChangePasswordPage(),
      ),
      (
        2,
        Icons.notifications_outlined,
        'Notification Settings',
        const NotificationSettingsPage(),
      ),
      (3, Icons.language, 'Language & Region', null),
      (4, Icons.help_outline, 'Help & Support', const HelpSupportPage()),
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1C1B1B),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (i, icon, label, page) in items) ...[
            if (i != 0)
              const Divider(height: 1, color: AppTheme.surfaceVariant),
            ListTile(
              leading: Icon(icon, color: AppTheme.onSurfaceVariant),
              title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppTheme.outlineVariant,
              ),
              onTap: page == null
                  ? null
                  : () => Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (_) => page)),
            ),
          ],
        ],
      ),
    );
  }
}
