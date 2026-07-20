import 'package:dio/dio.dart';
import 'package:smart_stay_ai/core/constants/api_constants.dart';
import 'package:smart_stay_ai/core/error/exceptions.dart';
import 'package:smart_stay_ai/core/network/dio_client.dart';
import '../models/assistant_reply_model.dart';
import '../models/chat_conversation_model.dart';

/// Nguồn trả lời cho trợ lý AI — gọi chatbot Gemini của backend.
///
/// Các endpoint `/v1/conversations/*` dùng `optionalAuth`: khách chưa đăng
/// nhập vẫn chat được (bị giới hạn 20 tin/hội thoại), người đã đăng nhập được
/// 50 tin AI mỗi ngày. Vượt hạn mức server trả 429 kèm message tiếng Việt —
/// message đó được đẩy nguyên văn lên UI.
abstract interface class AssistantRemoteDataSource {
  Future<AssistantReplyModel> sendMessage({
    required String text,
    String? conversationId,
  });

  /// `null` khi người dùng chưa có hội thoại nào.
  Future<ChatConversationModel?> loadMyConversation();
}

class AssistantRemoteDataSourceImpl implements AssistantRemoteDataSource {
  final DioClient client;
  const AssistantRemoteDataSourceImpl(this.client);

  @override
  Future<AssistantReplyModel> sendMessage({
    required String text,
    String? conversationId,
  }) async {
    try {
      final res = await client.dio.post(
        ApiConstants.conversationMessages,
        data: {
          'message': text,
          // Bỏ hẳn key khi chưa có hội thoại: schema yêu cầu uuid hợp lệ,
          // gửi null sẽ bị Joi từ chối.
          'conversationId': ?conversationId,
        },
      );
      return AssistantReplyModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
        message: _messageOf(e, 'Trợ lý đang bận, vui lòng thử lại.'),
      );
    }
  }

  @override
  Future<ChatConversationModel?> loadMyConversation() async {
    try {
      // Không truyền hotelId → hội thoại chung của nền tảng.
      final res = await client.dio.get(ApiConstants.myConversation);
      final data = res.data;
      // Server trả đúng JSON `null` khi chưa từng chat.
      if (data is! Map<String, dynamic>) return null;
      return ChatConversationModel.fromJson(data);
    } on DioException catch (e) {
      throw ServerException(
        message: _messageOf(e, 'Không tải được lịch sử trò chuyện.'),
      );
    }
  }

  /// Backend trả lỗi dạng `{ code, message }` — CHỈ lấy `message` đó.
  String _messageOf(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      final message = (data['message'] as String).trim();
      if (message.isNotEmpty) return message;
    }
    if (e.response == null) {
      return 'Cannot reach the server. Check your connection and try again.';
    }
    return fallback;
  }
}
