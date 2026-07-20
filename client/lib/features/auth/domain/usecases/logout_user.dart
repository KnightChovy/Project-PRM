import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case: đăng xuất.
class LogoutUser implements UseCase<Unit, NoParams> {
  final AuthRepository repository;
  const LogoutUser(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) {
    return repository.logout();
  }
}
