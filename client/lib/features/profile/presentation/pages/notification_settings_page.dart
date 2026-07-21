import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_message_dialog.dart';
import '../../domain/entities/profile_update.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_notifier.dart';

/// Notification settings.
///
/// Các toggle được lưu vào `UserProfile.notificationPrefs` (JSON) qua
/// `PATCH /v1/users/me`. Riêng "Promotional Offers" vẫn map thẳng vào cột
/// `marketingOptIn` như trước.
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final _notifier = sl<ProfileNotifier>();

  // key -> enabled. `bookingConfirmations` is locked on (disabled in the mockup).
  // Giá trị mặc định; sẽ được ghi đè bằng notificationPrefs của hồ sơ khi tải.
  final Map<String, bool> _alerts = {
    'priceDrops': true,
    'aiDeals': true,
    'checkIn': true,
    'reviews': true,
    'appUpdates': false,
  };
  final Map<String, bool> _comms = {'email': true, 'sms': false, 'push': true};

  @override
  void initState() {
    super.initState();
    _seedFrom(_notifier.profile);
    if (_notifier.profile == null) {
      _notifier.load().then((_) {
        if (mounted) setState(() => _seedFrom(_notifier.profile));
      });
    }
  }

  /// Nạp trạng thái toggle từ `notificationPrefs` đã lưu (thiếu key thì giữ mặc định).
  void _seedFrom(UserProfile? profile) {
    final saved = profile?.notificationPrefs;
    if (saved == null || saved.isEmpty) return;
    for (final k in _alerts.keys.toList()) {
      if (saved.containsKey(k)) _alerts[k] = saved[k]!;
    }
    for (final k in _comms.keys.toList()) {
      if (saved.containsKey(k)) _comms[k] = saved[k]!;
    }
  }

  /// Đổi 1 toggle rồi lưu cả bộ notificationPrefs lên server.
  Future<void> _toggle(Map<String, bool> map, String key, bool value) async {
    setState(() => map[key] = value);
    final all = <String, bool>{..._alerts, ..._comms};
    final ok = await _notifier.save(ProfileUpdate(notificationPrefs: all));
    if (!mounted || ok) return;
    await showAppErrorDialog(
      context,
      title: 'Không lưu được cài đặt',
      message: _notifier.actionErrorMessage ?? 'Vui lòng thử lại.',
    );
  }

  /// "Promotional Offers" map thẳng vào cột `marketingOptIn`.
  Future<void> _setMarketing(bool value) async {
    final ok = await _notifier.setMarketingOptIn(value);
    if (!mounted || ok) return;
    await showAppErrorDialog(
      context,
      title: 'Không lưu được cài đặt',
      message: _notifier.actionErrorMessage ?? 'Vui lòng thử lại.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return ChangeNotifierProvider.value(
      value: _notifier,
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('Notifications'),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
            children: [
              _Card(
                children: [
                  _LockedRow(
                    icon: Icons.confirmation_number_outlined,
                    label: 'Booking Confirmations',
                  ),
                  _ToggleRow(
                    icon: Icons.trending_down,
                    label: 'Price Drops on Wishlist',
                    value: _alerts['priceDrops']!,
                    onChanged: (v) => _toggle(_alerts, 'priceDrops', v),
                  ),
                  _ToggleRow(
                    icon: Icons.auto_awesome,
                    label: 'AI Personalized Deals',
                    value: _alerts['aiDeals']!,
                    onChanged: (v) => _toggle(_alerts, 'aiDeals', v),
                  ),
                  _ToggleRow(
                    icon: Icons.notification_important_outlined,
                    label: 'Check-in Reminders',
                    value: _alerts['checkIn']!,
                    onChanged: (v) => _toggle(_alerts, 'checkIn', v),
                  ),
                  // Cờ THẬT: map thẳng vào `UserProfile.marketingOptIn`.
                  Consumer<ProfileNotifier>(
                    builder: (context, notifier, _) => _ToggleRow(
                      icon: Icons.local_offer_outlined,
                      label: 'Promotional Offers',
                      value: notifier.profile?.marketingOptIn ?? false,
                      onChanged: (v) {
                        // Chặn bấm liên tục khi request trước chưa xong.
                        if (notifier.isSaving) return;
                        _setMarketing(v);
                      },
                    ),
                  ),
                  _ToggleRow(
                    icon: Icons.rate_review_outlined,
                    label: 'Review Reminders',
                    value: _alerts['reviews']!,
                    onChanged: (v) => _toggle(_alerts, 'reviews', v),
                  ),
                  _ToggleRow(
                    icon: Icons.system_update,
                    label: 'App Updates',
                    value: _alerts['appUpdates']!,
                    onChanged: (v) => _toggle(_alerts, 'appUpdates', v),
                    last: true,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 12),
                child: Text(
                  'COMMUNICATION',
                  style: t.labelSmall?.copyWith(
                    color: AppTheme.outlineVariant,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              _Card(
                children: [
                  _ToggleRow(
                    icon: Icons.mail_outline,
                    label: 'Email Notifications',
                    value: _comms['email']!,
                    onChanged: (v) => _toggle(_comms, 'email', v),
                  ),
                  _ToggleRow(
                    icon: Icons.sms_outlined,
                    label: 'SMS Notifications',
                    value: _comms['sms']!,
                    onChanged: (v) => _toggle(_comms, 'sms', v),
                  ),
                  _ToggleRow(
                    icon: Icons.notifications_active_outlined,
                    label: 'Push Notifications',
                    value: _comms['push']!,
                    onChanged: (v) => _toggle(_comms, 'push', v),
                    last: true,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Cài đặt được lưu vào tài khoản của bạn và đồng bộ giữa các thiết bị.',
                style: t.labelSmall?.copyWith(color: AppTheme.onSurfaceVariant),
              ),
              const SizedBox(height: 48),
              const _SmartAlertsBanner(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.surfaceContainerHigh.withValues(alpha: 0.5),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1C1B1B),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: last
          ? null
          : const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.surfaceContainerHigh),
              ),
            ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppTheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.tertiaryFixedDim,
          ),
        ],
      ),
    );
  }
}

class _LockedRow extends StatelessWidget {
  const _LockedRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.6,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppTheme.surfaceContainerHigh),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppTheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ),
            const Switch(
              value: true,
              onChanged: null,
              activeTrackColor: AppTheme.tertiaryFixedDim,
            ),
          ],
        ),
      ),
    );
  }
}

class _SmartAlertsBanner extends StatelessWidget {
  const _SmartAlertsBanner();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x668FD3D3), blurRadius: 12)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🤖', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 16),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: t.bodyMedium?.copyWith(
                  fontSize: 15,
                  height: 1.5,
                  color: AppTheme.onSurfaceVariant,
                ),
                children: [
                  TextSpan(
                    text: 'Smart Alerts are on',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const TextSpan(
                    text: " — we'll only notify you when it really matters.",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
