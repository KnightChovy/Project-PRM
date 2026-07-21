import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../entities/assistant_reply.dart';
import '../repositories/assistant_repository.dart';

/// Use case: gửi một câu hỏi tới trợ lý AI và nhận câu trả lời.
///
/// Quy tắc nghiệp vụ: không gửi tin nhắn rỗng, và không vượt quá 2000 ký tự
/// (giới hạn `Joi.string().max(2000)` phía server).
class SendMessage implements UseCase<AssistantReply, SendMessageParams> {
  static const int maxLength = 2000;

  final AssistantRepository repository;
  const SendMessage(this.repository);

  @override
  Future<Either<Failure, AssistantReply>> call(SendMessageParams params) {
    final text = params.text.trim();
    if (text.isEmpty) {
      return Future.value(
        const Left(ServerFailure(message: 'Nội dung tin nhắn đang trống.')),
      );
    }
    if (text.length > maxLength) {
      return Future.value(
        const Left(ServerFailure(message: 'Tin nhắn tối đa $maxLength ký tự.')),
      );
    }
    return repository.sendMessage(
      text: text,
      conversationId: params.conversationId,
    );
  }
}

class SendMessageParams extends Equatable {
  final String text;
  final String? conversationId;

  const SendMessageParams(this.text, {this.conversationId});

  @override
  List<Object?> get props => [text, conversationId];
}
