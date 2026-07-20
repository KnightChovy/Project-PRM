import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';

/// Help & Support — nút "Start Chat" mở trợ lý AI thật của backend.
///
/// TODO(backend): ô tìm kiếm và danh sách FAQ vẫn là nội dung tĩnh. Bảng
/// `FaqKnowledgeBase` đã có trong schema nhưng chỉ được service chatbot đọc nội
/// bộ để làm RAG — không có endpoint nào cho client liệt kê FAQ. Tương tự,
/// không có API ticket/hỗ trợ nên 3 ô liên hệ bên dưới chưa gắn hành động.
class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  static const _faqs = [
    (
      'Booking & Cancellation',
      'Learn about our flexible cancellation policies, how to modify your reservation '
          'dates, and what happens in case of unexpected travel changes.',
    ),
    (
      'Payments & Refunds',
      'Information regarding accepted payment methods, holding fees, security deposits, '
          'and our standard refund processing times.',
    ),
    (
      'Account & Security',
      'Manage your profile details, update password settings, and review how we protect '
          'your personal data during transactions.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Concierge Support'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          children: [
            Text('How can we assist you?', style: t.headlineLarge),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search help articles...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.onSurfaceVariant,
                ),
                filled: true,
                fillColor: AppTheme.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppTheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppTheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.secondary),
                ),
              ),
            ),
            const SizedBox(height: 48),
            const _ChatCta(),
            const SizedBox(height: 48),
            Text('Frequently Asked Questions', style: t.headlineMedium),
            const Divider(color: AppTheme.surfaceVariant),
            const SizedBox(height: 8),
            for (final (q, a) in _faqs)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0,
                color: AppTheme.surfaceContainerLowest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: AppTheme.surfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: ExpansionTile(
                  shape: const Border(),
                  title: Text(
                    q,
                    style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        a,
                        style: t.bodyMedium?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 40),
            Center(
              child: Text('Other ways to reach us', style: t.headlineMedium),
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(
                  child: _ContactTile(
                    icon: Icons.forum_outlined,
                    label: 'Live Chat',
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _ContactTile(icon: Icons.mail_outline, label: 'Email'),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _ContactTile(
                    icon: Icons.call_outlined,
                    label: 'Phone',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Still need help? Our premium support team is available 24/7 to assist you.',
              textAlign: TextAlign.center,
              style: t.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: AppTheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatCta extends StatelessWidget {
  const _ChatCta();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.surfaceContainerLow, AppTheme.surfaceContainer],
        ),
        boxShadow: const [BoxShadow(color: Color(0x4D8FD3D3), blurRadius: 20)],
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
                  Row(
                    children: [
                      const Text('🤖', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        'Chat with Assistant',
                        style: t.headlineMedium?.copyWith(fontSize: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Get instant answers 24/7',
                    style: t.bodyMedium?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.auto_awesome, color: AppTheme.secondary),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF313030), // inverse-surface
                foregroundColor: AppTheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              // Mở khung chat AI thật (`POST /v1/conversations/messages`,
              // chatbot Gemini phía backend). Notifier của assistant là
              // singleton nên vào từ đây hay từ tab Assistant đều là CÙNG một
              // hội thoại, không tạo hội thoại mới.
              onPressed: () => context.push(AppRoutes.assistant),
              child: const Text('Start Chat'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.surfaceVariant.withValues(alpha: 0.5),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.secondaryContainer.withValues(
                alpha: 0.3,
              ),
              child: Icon(icon, color: AppTheme.secondary),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
