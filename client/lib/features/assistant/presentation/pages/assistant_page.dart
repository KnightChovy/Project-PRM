import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_stay_ai/core/di/injection.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';
import 'package:smart_stay_ai/core/widgets/app_network_image.dart';
import 'package:smart_stay_ai/features/assistant/domain/entities/chat_message.dart';
import 'package:smart_stay_ai/features/assistant/presentation/providers/assistant_notifier.dart';

/// Màn "AI Assistant" — trợ lý số giúp khách tìm chỗ nghỉ phù hợp.
class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  /// Notifier là singleton (dùng chung với Help & Support) nên KHÔNG tạo qua
  /// `create:` — provider sẽ dispose nó khi rời màn và lần sau mở lại sẽ nổ.
  final _notifier = sl<AssistantNotifier>();

  @override
  void initState() {
    super.initState();
    // Khôi phục hội thoại cũ để người dùng đọc lại được lịch sử chat.
    _notifier.restore();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send(AssistantNotifier notifier) async {
    final text = _inputCtrl.text;
    if (text.trim().isEmpty) return;
    _inputCtrl.clear();
    await notifier.send(text);
    // Màn này mở được cả dạng tab lẫn dạng push từ Help & Support, nên có thể
    // bị pop khi AI còn đang trả lời.
    if (!mounted) return;
    // Cuộn xuống cuối sau khi có tin nhắn mới.
    if (_scrollCtrl.hasClients) {
      await _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _notifier,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'SmartStay',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Consumer<AssistantNotifier>(
                  builder: (context, notifier, _) {
                    return ListView(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      children: [
                        const _SmartAdviceCard(),
                        const SizedBox(height: 14),
                        const _AiPickCard(),
                        const SizedBox(height: 14),
                        for (final m in notifier.messages) _Bubble(message: m),
                        if (notifier.isThinking) const _TypingBubble(),
                        if (notifier.errorMessage != null)
                          _ErrorNote(message: notifier.errorMessage!),
                      ],
                    );
                  },
                ),
              ),
              _InputBar(controller: _inputCtrl, onSend: _send),
            ],
          ),
        ),
      ),
    );
  }
}

/// Thẻ "Smart Advice" — gợi ý chủ động của AI ở đầu màn.
class _SmartAdviceCard extends StatelessWidget {
  const _SmartAdviceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.smart_toy_outlined, size: 18, color: AppColors.gold),
              SizedBox(width: 8),
              Text(
                'Smart Advice',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Giá của resort này đang thấp nhất vào tháng 10. Đặt ngay có thể '
            'giúp bạn tiết kiệm tới 15%.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// Thẻ "AI Pick" — gợi ý một chỗ nghỉ nổi bật.
class _AiPickCard extends StatelessWidget {
  const _AiPickCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 150,
            width: double.infinity,
            child: AppNetworkImage(
              url:
                  'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Amanzoe Villas',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Peloponnese, Greece',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text(
                      '\$1,250',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.goldDark,
                      ),
                    ),
                    Text(
                      'mỗi đêm',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bong bóng tin nhắn (người dùng bên phải, AI bên trái).
class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser ? AppColors.goldDark : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: isUser ? null : Border.all(color: AppColors.goldLight),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? Colors.white : AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

/// Dòng báo lỗi ngay trong khung chat (hết hạn mức, mất mạng, server bận...).
///
/// Message lấy nguyên văn từ backend vì API chatbot trả câu tiếng Việt đã đủ
/// rõ cho người dùng cuối (ví dụ: "Bạn gửi tin quá nhanh...").
class _ErrorNote extends StatelessWidget {
  const _ErrorNote({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, size: 18, color: Colors.red.shade400),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message,
                style: TextStyle(color: Colors.red.shade700, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bong bóng "đang trả lời..." khi AI suy nghĩ.
class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.goldLight),
        ),
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

/// Ô nhập câu hỏi gửi tới trợ lý.
class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.onSend});

  final TextEditingController controller;
  final Future<void> Function(AssistantNotifier) onSend;

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<AssistantNotifier>();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(notifier),
              decoration: InputDecoration(
                hintText: 'Hỏi trợ lý số của bạn...',
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: const BorderSide(color: AppColors.goldLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: const BorderSide(color: AppColors.goldLight),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.gold,
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: () => onSend(notifier),
            ),
          ),
        ],
      ),
    );
  }
}
