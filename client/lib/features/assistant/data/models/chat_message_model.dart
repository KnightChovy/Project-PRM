import '../../domain/entities/chat_message.dart';

/// DTO của [ChatMessage]: nơi DUY NHẤT map JSON ↔ Entity.
class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.sender,
    required super.text,
    required super.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        id: json['id'] as String,
        sender: (json['sender'] as String) == 'user'
            ? MessageSender.user
            : MessageSender.assistant,
        text: json['text'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender': sender.name,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };
}
