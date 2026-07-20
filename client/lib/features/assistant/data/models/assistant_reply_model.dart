import '../../domain/entities/assistant_reply.dart';
import '../../domain/entities/chat_message.dart';

/// DTO của [AssistantReply] — response của `POST /v1/conversations/messages`.
class AssistantReplyModel extends AssistantReply {
  const AssistantReplyModel({
    required super.conversationId,
    required super.message,
    required super.handoff,
  });

  /// Server chỉ trả `reply` dạng chuỗi (không phải một hàng `Message`), nên
  /// id và thời điểm của bong bóng chat được sinh ở client.
  factory AssistantReplyModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return AssistantReplyModel(
      conversationId: json['conversationId']?.toString() ?? '',
      handoff: json['handoff'] as bool? ?? false,
      message: ChatMessage(
        id: 'ai_${now.microsecondsSinceEpoch}',
        sender: MessageSender.assistant,
        text: json['reply']?.toString() ?? '',
        createdAt: now,
      ),
    );
  }
}
