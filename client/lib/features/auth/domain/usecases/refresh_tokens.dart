import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../entities/auth_tokens.dart';
import '../repositories/auth_repository.dart';

/// Use case: làm mới access token bằng refresh token đang lưu ở máy.
class RefreshTokens implements UseCase<AuthTokens, NoParams> {
  final AuthRepository repository;
  const RefreshTokens(this.repository);

  @override
  Future<Either<Failure, AuthTokens>> call(NoParams params) {
    return repository.refreshTokens();
  }
}
