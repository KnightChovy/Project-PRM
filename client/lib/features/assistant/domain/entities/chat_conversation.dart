import 'package:equatable/equatable.dart';
import 'chat_message.dart';

/// Một cuộc hội thoại đã có sẵn trên server (`GET /v1/conversations/me`),
/// dùng để khôi phục khung chat khi người dùng mở lại màn hình.
class ChatConversation extends Equatable {
  final String id;
  final List<ChatMessage> messages;
  final bool handoff;

  const ChatConversation({
    required this.id,
    required this.messages,
    required this.handoff,
  });

  @override
  List<Object?> get props => [id, messages, handoff];
}
