import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../entities/chat_message.dart';
import '../repositories/assistant_repository.dart';

/// Use case: gửi một câu hỏi tới trợ lý AI và nhận câu trả lời.
///
/// Quy tắc nghiệp vụ: không gửi tin nhắn rỗng.
class SendMessage implements UseCase<ChatMessage, SendMessageParams> {
  final AssistantRepository repository;
  const SendMessage(this.repository);

  @override
  Future<Either<Failure, ChatMessage>> call(SendMessageParams params) {
    final text = params.text.trim();
    if (text.isEmpty) {
      return Future.value(
        const Left(ServerFailure(message: 'Nội dung tin nhắn đang trống.')),
      );
    }
    return repository.sendMessage(text);
  }
}

class SendMessageParams extends Equatable {
  final String text;
  const SendMessageParams(this.text);

  @override
  List<Object?> get props => [text];
}
