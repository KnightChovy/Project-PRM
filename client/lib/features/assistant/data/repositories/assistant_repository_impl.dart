import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/exceptions.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/assistant_repository.dart';
import '../datasources/assistant_local_data_source.dart';

/// Hiện thực [AssistantRepository]. NƠI DUY NHẤT đổi Exception → Failure.
class AssistantRepositoryImpl implements AssistantRepository {
  final AssistantLocalDataSource local;
  const AssistantRepositoryImpl(this.local);

  @override
  Future<Either<Failure, ChatMessage>> sendMessage(String userText) async {
    try {
      final reply = await local.reply(userText);
      return Right(reply);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
