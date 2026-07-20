import '../../domain/entities/chat_message.dart';

/// DTO của [ChatMessage]: nơi DUY NHẤT map JSON ↔ Entity.
class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.sender,
    required super.text,
    required super.createdAt,
  });

  /// Map một hàng `Message` của server.
  ///
  /// `senderType` bên backend có 4 giá trị (`user | ai_bot | staff | system`)
  /// nhưng khung chat chỉ vẽ 2 phía, nên mọi thứ không phải `user` đều hiển
  /// thị như tin của trợ lý — kể cả khi nhân viên thật đang trả lời.
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        id: json['id']?.toString() ?? '',
        sender: json['senderType']?.toString() == 'user'
            ? MessageSender.user
            : MessageSender.assistant,
        text: json['content']?.toString() ?? '',
        createdAt:
            DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
      );
}
