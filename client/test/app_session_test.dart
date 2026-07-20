import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/network/token_storage.dart';
import 'package:smart_stay_ai/core/session/app_session.dart';
import 'package:smart_stay_ai/features/assistant/domain/entities/assistant_reply.dart';
import 'package:smart_stay_ai/features/assistant/domain/entities/chat_conversation.dart';
import 'package:smart_stay_ai/features/assistant/domain/entities/chat_message.dart';
import 'package:smart_stay_ai/features/assistant/domain/repositories/assistant_repository.dart';
import 'package:smart_stay_ai/features/assistant/domain/usecases/load_my_conversation.dart';
import 'package:smart_stay_ai/features/assistant/domain/usecases/send_message.dart';
import 'package:smart_stay_ai/features/assistant/presentation/providers/assistant_notifier.dart';

Future<TokenStorage> _storage(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  return TokenStorage(await SharedPreferences.getInstance());
}

/// Fake repository tự viết (không dùng mocktail để khỏi thêm thư viện).
class _FakeAssistantRepository implements AssistantRepository {
  ChatConversation? conversation;

  @override
  Future<Either<Failure, AssistantReply>> sendMessage({
    required String text,
    String? conversationId,
  }) async => Right(
    AssistantReply(
      conversationId: 'conv_1',
      handoff: false,
      message: ChatMessage(
        id: 'ai_1',
        sender: MessageSender.assistant,
        text: 'xin chào',
        createdAt: DateTime.utc(2026),
      ),
    ),
  );

  @override
  Future<Either<Failure, ChatConversation?>> loadMyConversation() async =>
      Right(conversation);
}

AssistantNotifier _assistant(_FakeAssistantRepository repo) =>
    AssistantNotifier(
      sendMessage: SendMessage(repo),
      loadMyConversation: LoadMyConversation(repo),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppSession', () {
    test('có refresh token nghĩa là còn phiên', () async {
      final session = AppSession(await _storage({'auth_refresh_token': 'r1'}));
      expect(session.isSignedIn, isTrue);
    });

    test('không có token thì coi như chưa đăng nhập', () async {
      final session = AppSession(await _storage({}));
      expect(session.isSignedIn, isFalse);
    });

    test('onSignedOut chạy mọi handler dọn dẹp đã đăng ký', () async {
      final session = AppSession(await _storage({}));
      var cleared = 0;
      session
        ..addResetHandler(() => cleared++)
        ..addResetHandler(() => cleared++);

      session.onSignedOut();

      expect(cleared, 2);
    });

    test('router được báo mỗi khi phiên đổi', () async {
      final session = AppSession(await _storage({}));
      var notified = 0;
      session.addListener(() => notified++);

      session.onSignedIn();
      session.onSignedOut();

      expect(notified, 2);
    });
  });

  group('AssistantNotifier — không rò dữ liệu giữa hai tài khoản', () {
    test('reset() xoá sạch tin nhắn và conversationId', () async {
      final notifier = _assistant(_FakeAssistantRepository());
      await notifier.send('bí mật của tôi');
      expect(notifier.messages, isNotEmpty);

      notifier.reset();

      expect(notifier.messages, isEmpty);
      expect(notifier.conversationId, isNull);
    });

    test(
      'restore() cho tài khoản chưa từng chat vẫn xoá tin nhắn còn sót',
      () async {
        final repo = _FakeAssistantRepository();
        final notifier = _assistant(repo);
        await notifier.send('tin của người dùng cũ');
        expect(notifier.messages, isNotEmpty);

        // Người dùng mới: server trả null vì chưa có hội thoại nào.
        repo.conversation = null;
        await notifier.restore();

        expect(notifier.messages, isEmpty);
        expect(notifier.conversationId, isNull);
      },
    );
  });
}
