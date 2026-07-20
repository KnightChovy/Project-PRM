import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../entities/chat_conversation.dart';
import '../repositories/assistant_repository.dart';

/// Use case: khôi phục hội thoại gần nhất khi mở lại khung chat.
class LoadMyConversation implements UseCase<ChatConversation?, NoParams> {
  final AssistantRepository repository;
  const LoadMyConversation(this.repository);

  @override
  Future<Either<Failure, ChatConversation?>> call(NoParams params) =>
      repository.loadMyConversation();
}
