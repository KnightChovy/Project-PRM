import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import 'change_password_page.dart';
import 'edit_profile_page.dart';
import 'help_support_page.dart';
import 'notification_settings_page.dart';

/// Profile screen — static display + navigation entry points.
/// ponytail: local-only; wire a profile bloc when it actually loads from the API.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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

    if (shouldLogout != true || !context.mounted) return;
    // go() thay vì push() để dọn sạch lịch sử điều hướng sau khi đăng xuất.
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: Text('SmartStay', style: t.headlineLarge?.copyWith(color: AppTheme.primary)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.surfaceVariant,
              child: const Icon(Icons.person, size: 20, color: AppTheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            const _ProfileHeader(),
            const SizedBox(height: 40),
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
                backgroundColor: AppTheme.errorContainer.withValues(alpha: 0.4),
                foregroundColor: AppTheme.error,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => _confirmLogout(context),
              child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Version 4.12.0',
                style: t.labelSmall?.copyWith(
                  color: AppTheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.surfaceVariant,
            boxShadow: const [
              BoxShadow(color: Color(0x0A1C1B1B), blurRadius: 20, offset: Offset(0, 4)),
            ],
          ),
          child: const Icon(Icons.person, size: 48, color: AppTheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Text('Alex Sterling', style: t.headlineLarge),
        const SizedBox(height: 4),
        Text('alex.sterling@example.com',
            style: t.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
        const SizedBox(height: 16),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppTheme.outline),
            foregroundColor: AppTheme.onBackground,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          ),
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const EditProfilePage())),
          child: const Text('Edit Profile'),
        ),
      ],
    );
  }
}

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
                      Text('SmartStay Gold',
                          style: t.headlineMedium?.copyWith(color: AppTheme.onTertiaryFixed)),
                      const SizedBox(width: 8),
                      const Icon(Icons.stars, size: 20, color: AppTheme.onTertiaryFixed),
                    ],
                  ),
                ],
              ),
              Icon(Icons.diamond,
                  size: 32, color: AppTheme.onTertiaryFixed.withValues(alpha: 0.2)),
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
                  Text('2,450',
                      style: t.displayLarge?.copyWith(color: AppTheme.onTertiaryFixed)),
                  const SizedBox(height: 4),
                  Text('Available Points',
                      style: t.labelLarge?.copyWith(
                        color: AppTheme.onTertiaryFixed.withValues(alpha: 0.8),
                      )),
                ],
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.onTertiaryFixed,
                  foregroundColor: AppTheme.tertiaryFixed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          BoxShadow(color: Color(0x0A1C1B1B), blurRadius: 20, offset: Offset(0, 4)),
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
          Text(label, style: t.labelSmall?.copyWith(color: AppTheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

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
          BoxShadow(color: Color(0x0A1C1B1B), blurRadius: 20, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Your Travel Style', style: t.headlineMedium),
              const SizedBox(width: 8),
              const Icon(Icons.auto_awesome, color: AppTheme.secondary, size: 22),
            ],
          ),
          const SizedBox(height: 4),
          Text('AI-curated based on your recent bookings.',
              style: t.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
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
              color: dashed ? AppTheme.onSurfaceVariant : AppTheme.onPrimaryContainer,
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
      (0, Icons.person_outline, 'Personal Information', null),
      (1, Icons.lock_outline, 'Security & Password', const ChangePasswordPage()),
      (2, Icons.notifications_outlined, 'Notification Settings', const NotificationSettingsPage()),
      (3, Icons.language, 'Language & Region', null),
      (4, Icons.help_outline, 'Help & Support', const HelpSupportPage()),
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0x0A1C1B1B), blurRadius: 20, offset: Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (i, icon, label, page) in items) ...[
            if (i != 0) const Divider(height: 1, color: AppTheme.surfaceVariant),
            ListTile(
              leading: Icon(icon, color: AppTheme.onSurfaceVariant),
              title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
              trailing: const Icon(Icons.chevron_right, color: AppTheme.outlineVariant),
              onTap: page == null
                  ? null
                  : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page)),
            ),
          ],
        ],
      ),
    );
  }
}
