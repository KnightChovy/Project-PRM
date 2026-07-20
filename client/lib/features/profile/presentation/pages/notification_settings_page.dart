import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Notification settings — local toggles only.
/// ponytail: persist via a settings repo/bloc when the backend exposes the prefs API.
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  // key -> enabled. `bookingConfirmations` is locked on (disabled in the mockup).
  final Map<String, bool> _alerts = {
    'priceDrops': true,
    'aiDeals': true,
    'checkIn': true,
    'promos': false,
    'reviews': true,
    'appUpdates': false,
  };
  final Map<String, bool> _comms = {
    'email': true,
    'sms': false,
    'push': true,
  };

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
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
                  onChanged: (v) => setState(() => _alerts['priceDrops'] = v),
                ),
                _ToggleRow(
                  icon: Icons.auto_awesome,
                  label: 'AI Personalized Deals',
                  value: _alerts['aiDeals']!,
                  onChanged: (v) => setState(() => _alerts['aiDeals'] = v),
                ),
                _ToggleRow(
                  icon: Icons.notification_important_outlined,
                  label: 'Check-in Reminders',
                  value: _alerts['checkIn']!,
                  onChanged: (v) => setState(() => _alerts['checkIn'] = v),
                ),
                _ToggleRow(
                  icon: Icons.local_offer_outlined,
                  label: 'Promotional Offers',
                  value: _alerts['promos']!,
                  onChanged: (v) => setState(() => _alerts['promos'] = v),
                ),
                _ToggleRow(
                  icon: Icons.rate_review_outlined,
                  label: 'Review Reminders',
                  value: _alerts['reviews']!,
                  onChanged: (v) => setState(() => _alerts['reviews'] = v),
                ),
                _ToggleRow(
                  icon: Icons.system_update,
                  label: 'App Updates',
                  value: _alerts['appUpdates']!,
                  onChanged: (v) => setState(() => _alerts['appUpdates'] = v),
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
                  onChanged: (v) => setState(() => _comms['email'] = v),
                ),
                _ToggleRow(
                  icon: Icons.sms_outlined,
                  label: 'SMS Notifications',
                  value: _comms['sms']!,
                  onChanged: (v) => setState(() => _comms['sms'] = v),
                ),
                _ToggleRow(
                  icon: Icons.notifications_active_outlined,
                  label: 'Push Notifications',
                  value: _comms['push']!,
                  onChanged: (v) => setState(() => _comms['push'] = v),
                  last: true,
                ),
              ],
            ),
            const SizedBox(height: 48),
            const _SmartAlertsBanner(),
          ],
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
        border: Border.all(color: AppTheme.surfaceContainerHigh.withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(color: Color(0x0A1C1B1B), blurRadius: 20, offset: Offset(0, 4)),
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
              border: Border(bottom: BorderSide(color: AppTheme.surfaceContainerHigh)),
            ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppTheme.primary),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
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
          border: Border(bottom: BorderSide(color: AppTheme.surfaceContainerHigh)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppTheme.primary),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
            const Switch(value: true, onChanged: null, activeTrackColor: AppTheme.tertiaryFixedDim),
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
        boxShadow: const [
          BoxShadow(color: Color(0x668FD3D3), blurRadius: 12),
        ],
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
