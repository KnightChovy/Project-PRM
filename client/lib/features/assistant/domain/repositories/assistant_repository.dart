import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import '../entities/assistant_reply.dart';
import '../entities/chat_conversation.dart';

/// Hợp đồng cho trợ lý AI. Domain khai báo, Data hiện thực.
abstract interface class AssistantRepository {
  /// Gửi câu hỏi của người dùng, nhận về câu trả lời của trợ lý.
  ///
  /// [conversationId] để null ở lượt đầu — server sẽ tạo hội thoại mới.
  Future<Either<Failure, AssistantReply>> sendMessage({
    required String text,
    String? conversationId,
  });

  /// Khôi phục hội thoại gần nhất. Trả `null` khi người dùng chưa từng chat
  /// (server trả đúng JSON `null`, và khách chưa đăng nhập cũng không có gì).
  Future<Either<Failure, ChatConversation?>> loadMyConversation();
}
