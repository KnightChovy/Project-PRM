import 'package:smart_stay_ai/core/error/exceptions.dart';
import '../../domain/entities/chat_message.dart';
import '../models/chat_message_model.dart';

/// Nguồn trả lời cho trợ lý AI.
///
/// NOTE: hiện đang là MOCK — sinh câu trả lời theo từ khoá để demo. Khi có
/// backend AI (REST API), thay bằng AssistantRemoteDataSourceImpl gọi
/// POST /assistant/chat và bỏ phần luật từ khoá bên dưới.
abstract interface class AssistantLocalDataSource {
  Future<ChatMessageModel> reply(String userText);
}

class AssistantLocalDataSourceImpl implements AssistantLocalDataSource {
  @override
  Future<ChatMessageModel> reply(String userText) async {
    try {
      // Giả lập độ trễ "suy nghĩ" của AI.
      await Future<void>.delayed(const Duration(milliseconds: 600));
      final now = DateTime.now();
      return ChatMessageModel(
        id: 'ai_${now.microsecondsSinceEpoch}',
        sender: MessageSender.assistant,
        text: _craftReply(userText.toLowerCase()),
        createdAt: now,
      );
    } catch (e) {
      throw ServerException(message: 'Trợ lý AI gặp sự cố: $e');
    }
  }

  /// Luật từ khoá đơn giản để câu trả lời nghe tự nhiên trong demo.
  String _craftReply(String q) {
    if (q.contains('santorini') || q.contains('greece')) {
      return 'Mình tìm thấy 4 resort sang trọng tại Santorini có hồ bơi riêng. '
          'Bạn muốn lọc theo tầm nhìn hướng biển không?';
    }
    if (q.contains('cheap') || q.contains('giá') || q.contains('budget')) {
      return 'Giá tốt nhất thường rơi vào giữa tuần. Mình có thể gợi ý vài '
          'lựa chọn tiết kiệm tới 15% cho kỳ nghỉ của bạn.';
    }
    if (q.contains('pool') || q.contains('hồ bơi') || q.contains('private')) {
      return 'Mình tìm được 3 resort yên tĩnh, sang trọng kèm hồ bơi riêng. '
          'Bạn có muốn xem ngay không?';
    }
    if (q.contains('hi') || q.contains('hello') || q.contains('chào')) {
      return 'Xin chào! Mình là trợ lý số của SmartStay. Bạn muốn tìm chỗ '
          'nghỉ như thế nào cho chuyến đi sắp tới?';
    }
    return 'Mình đã ghi nhận yêu cầu của bạn. Dựa trên sở thích, mình sẽ gợi ý '
        'những chỗ nghỉ phù hợp nhất. Bạn muốn ưu tiên vị trí hay ngân sách?';
  }
}
