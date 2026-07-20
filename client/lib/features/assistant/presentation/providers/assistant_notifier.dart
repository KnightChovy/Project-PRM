import 'package:flutter/foundation.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import 'package:smart_stay_ai/features/assistant/domain/entities/chat_message.dart';
import 'package:smart_stay_ai/features/assistant/domain/usecases/load_my_conversation.dart';
import 'package:smart_stay_ai/features/assistant/domain/usecases/send_message.dart';

/// Quản lý trạng thái khung chat với trợ lý AI. Chỉ gọi UseCase.
class AssistantNotifier extends ChangeNotifier {
  final SendMessage sendMessage;
  final LoadMyConversation loadMyConversation;

  AssistantNotifier({
    required this.sendMessage,
    required this.loadMyConversation,
  });

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  bool _thinking = false;
  bool get isThinking => _thinking;

  bool _restoring = false;
  bool get isRestoring => _restoring;

  /// Hội thoại đang mở; null cho tới khi server tạo ở lượt gửi đầu tiên.
  String? _conversationId;
  String? get conversationId => _conversationId;

  /// `true` khi cuộc trò chuyện đã chuyển sang nhân viên hỗ trợ thật.
  bool handoff = false;

  String? errorMessage;

  /// Xoá sạch hội thoại đang giữ trong RAM. Gọi khi đăng xuất.
  ///
  /// Notifier này là singleton nên nếu không dọn, người đăng nhập kế tiếp trên
  /// cùng máy sẽ đọc được toàn bộ đoạn chat của người trước.
  void reset() {
    _messages.clear();
    _conversationId = null;
    handoff = false;
    errorMessage = null;
    notifyListeners();
  }

  /// Khôi phục hội thoại gần nhất. Gọi khi mở màn chat.
  ///
  /// Lỗi ở bước này KHÔNG chặn người dùng chat tiếp — cùng lắm là mất lịch sử,
  /// nên chỉ ghi vào [errorMessage] rồi thôi.
  Future<void> restore() async {
    if (_restoring) return;
    _restoring = true;
    notifyListeners();

    final result = await loadMyConversation(const NoParams());
    result.fold((failure) => errorMessage = failure.message, (conversation) {
      // Dọn TRƯỚC khi kiểm tra null: tài khoản mới chưa có hội thoại nào thì
      // vẫn phải xoá tin nhắn còn sót, không được thoát sớm rồi để nguyên.
      _messages.clear();
      _conversationId = conversation?.id;
      handoff = conversation?.handoff ?? false;
      if (conversation != null) _messages.addAll(conversation.messages);
    });
    _restoring = false;
    notifyListeners();
  }

  /// Gửi câu hỏi: hiện ngay tin của người dùng, rồi chờ trả lời của AI.
  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final now = DateTime.now();
    _messages.add(
      ChatMessage(
        id: 'me_${now.microsecondsSinceEpoch}',
        sender: MessageSender.user,
        text: trimmed,
        createdAt: now,
      ),
    );
    _thinking = true;
    errorMessage = null;
    notifyListeners();

    final result = await sendMessage(
      SendMessageParams(trimmed, conversationId: _conversationId),
    );
    result.fold((failure) => errorMessage = failure.message, (reply) {
      // Lượt đầu tiên server mới cấp id — nhớ lại để giữ ngữ cảnh hội thoại.
      _conversationId = reply.conversationId;
      handoff = reply.handoff;
      _messages.add(reply.message);
    });
    _thinking = false;
    notifyListeners();
  }
}
