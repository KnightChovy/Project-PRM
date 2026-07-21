import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/exceptions.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import '../../domain/entities/assistant_reply.dart';
import '../../domain/entities/chat_conversation.dart';
import '../../domain/repositories/assistant_repository.dart';
import '../datasources/assistant_remote_data_source.dart';

/// Hiện thực [AssistantRepository]. NƠI DUY NHẤT đổi Exception → Failure.
class AssistantRepositoryImpl implements AssistantRepository {
  final AssistantRemoteDataSource remote;
  const AssistantRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, AssistantReply>> sendMessage({
    required String text,
    String? conversationId,
  }) async {
    try {
      final reply = await remote.sendMessage(
        text: text,
        conversationId: conversationId,
      );
      return Right(reply);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, ChatConversation?>> loadMyConversation() async {
    try {
      return Right(await remote.loadMyConversation());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
