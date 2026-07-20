import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/features/assistant/domain/entities/assistant_reply.dart';
import 'package:smart_stay_ai/features/assistant/domain/entities/chat_conversation.dart';
import 'package:smart_stay_ai/features/assistant/domain/entities/chat_message.dart';
import 'package:smart_stay_ai/features/assistant/domain/repositories/assistant_repository.dart';
import 'package:smart_stay_ai/features/assistant/domain/usecases/send_message.dart';

/// Fake repository tự viết (không dùng mocktail để khỏi thêm thư viện).
class _FakeAssistantRepository implements AssistantRepository {
  String? lastText;
  String? lastConversationId;
  int sendCount = 0;

  @override
  Future<Either<Failure, AssistantReply>> sendMessage({
    required String text,
    String? conversationId,
  }) async {
    sendCount++;
    lastText = text;
    lastConversationId = conversationId;
    return Right(
      AssistantReply(
        conversationId: conversationId ?? 'conv_new',
        handoff: false,
        message: ChatMessage(
          id: 'ai_1',
          sender: MessageSender.assistant,
          text: 'Chào bạn!',
          createdAt: DateTime.utc(2026),
        ),
      ),
    );
  }

  @override
  Future<Either<Failure, ChatConversation?>> loadMyConversation() async =>
      const Right(null);
}

void main() {
  group('SendMessage use case', () {
    test('không gọi API với tin nhắn rỗng', () async {
      final repo = _FakeAssistantRepository();

      final result = await SendMessage(repo)(const SendMessageParams('   '));

      expect(result.isLeft(), isTrue);
      expect(repo.sendCount, 0);
    });

    test('chặn tin dài hơn giới hạn 2000 ký tự của server', () async {
      final repo = _FakeAssistantRepository();

      final result = await SendMessage(repo)(
        SendMessageParams('a' * (SendMessage.maxLength + 1)),
      );

      expect(result.isLeft(), isTrue);
      expect(repo.sendCount, 0);
    });

    test('cắt khoảng trắng thừa và chuyển tiếp conversationId', () async {
      final repo = _FakeAssistantRepository();

      final result = await SendMessage(repo)(
        const SendMessageParams(
          '  còn phòng trống không?  ',
          conversationId: 'conv_1',
        ),
      );

      expect(result.isRight(), isTrue);
      expect(repo.lastText, 'còn phòng trống không?');
      expect(repo.lastConversationId, 'conv_1');
    });

    test(
      'lượt đầu gửi conversationId null để server tạo hội thoại mới',
      () async {
        final repo = _FakeAssistantRepository();

        final result = await SendMessage(repo)(const SendMessageParams('hi'));

        expect(repo.lastConversationId, isNull);
        expect(
          result.getOrElse((_) => throw 'unreachable').conversationId,
          'conv_new',
        );
      },
    );
  });
}
