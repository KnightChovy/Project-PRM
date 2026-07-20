import 'package:equatable/equatable.dart';
import 'chat_message.dart';

/// Kết quả của một lượt gửi tin tới trợ lý (`POST /v1/conversations/messages`).
///
/// Ngoài câu trả lời, server còn cho biết cuộc hội thoại nào đang được dùng —
/// lượt đầu tiên KHÔNG có [conversationId] nên server tự tạo mới rồi trả về;
/// client phải nhớ để gửi kèm cho các lượt sau, nếu không AI sẽ mất ngữ cảnh.
class AssistantReply extends Equatable {
  final String conversationId;
  final ChatMessage message;

  /// `true` khi hội thoại đã được chuyển cho nhân viên hỗ trợ thật.
  final bool handoff;

  const AssistantReply({
    required this.conversationId,
    required this.message,
    required this.handoff,
  });

  @override
  List<Object?> get props => [conversationId, message, handoff];
}
