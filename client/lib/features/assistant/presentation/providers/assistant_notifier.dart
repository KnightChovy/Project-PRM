import 'package:flutter/foundation.dart';
import 'package:smart_stay_ai/features/assistant/domain/entities/chat_message.dart';
import 'package:smart_stay_ai/features/assistant/domain/usecases/send_message.dart';

/// Quản lý trạng thái khung chat với trợ lý AI. Chỉ gọi UseCase.
class AssistantNotifier extends ChangeNotifier {
  final SendMessage sendMessage;
  AssistantNotifier(this.sendMessage);

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  bool _thinking = false;
  bool get isThinking => _thinking;

  String? errorMessage;

  /// Gửi câu hỏi: hiện ngay tin của người dùng, rồi chờ trả lời của AI.
  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final now = DateTime.now();
    _messages.add(ChatMessage(
      id: 'me_${now.microsecondsSinceEpoch}',
      sender: MessageSender.user,
      text: trimmed,
      createdAt: now,
    ));
    _thinking = true;
    errorMessage = null;
    notifyListeners();

    final result = await sendMessage(SendMessageParams(trimmed));
    result.fold(
      (failure) => errorMessage = failure.message,
      (reply) => _messages.add(reply),
    );
    _thinking = false;
    notifyListeners();
  }
}
