import '../../domain/entities/chat_conversation.dart';
import 'chat_message_model.dart';

/// DTO của [ChatConversation] — response của `GET /v1/conversations/me`.
class ChatConversationModel extends ChatConversation {
  const ChatConversationModel({
    required super.id,
    required super.messages,
    required super.handoff,
  });

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'] as List<dynamic>? ?? const [];
    return ChatConversationModel(
      id: json['id']?.toString() ?? '',
      handoff: json['handoff'] as bool? ?? false,
      messages: rawMessages
          .whereType<Map<String, dynamic>>()
          .map(ChatMessageModel.fromJson)
          .toList(),
    );
  }
}
