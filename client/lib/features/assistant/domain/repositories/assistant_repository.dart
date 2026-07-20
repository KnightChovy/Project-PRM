import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import '../entities/chat_message.dart';

/// Hợp đồng cho trợ lý AI. Domain khai báo, Data hiện thực.
abstract interface class AssistantRepository {
  /// Gửi câu hỏi của người dùng, nhận về câu trả lời của trợ lý.
  Future<Either<Failure, ChatMessage>> sendMessage(String userText);
}
