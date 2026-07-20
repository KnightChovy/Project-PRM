import 'package:equatable/equatable.dart';

/// Ai là người gửi tin nhắn trong cuộc hội thoại với trợ lý AI.
enum MessageSender { user, assistant }

/// Một tin nhắn trong khung chat với trợ lý AI. Thuần Dart.
class ChatMessage extends Equatable {
  final String id;
  final MessageSender sender;
  final String text;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.createdAt,
  });

  bool get isUser => sender == MessageSender.user;

  @override
  List<Object?> get props => [id, sender, text, createdAt];
}
