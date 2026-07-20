import 'package:fpdart/fpdart.dart';
import 'exceptions.dart';
import 'failures.dart';

/// Bọc một lời gọi DataSource và đổi Exception -> [Failure].
///
/// Đây là chỗ DUY NHẤT thực hiện việc đổi này, và nó chỉ được dùng bởi
/// RepositoryImpl (tầng Data). UseCase/Notifier vẫn chỉ thấy [Either].
Future<Either<Failure, T>> guardApiCall<T>(Future<T> Function() body) async {
  try {
    return Right(await body());
  } on ValidationException catch (e) {
    return Left(ValidationFailure(message: e.message));
  } on UnauthorizedException catch (e) {
    return Left(AuthFailure(message: e.message));
  } on NotFoundException catch (e) {
    return Left(NotFoundFailure(message: e.message));
  } on NetworkException catch (e) {
    return Left(NetworkFailure(message: e.message));
  } on ServerException catch (e) {
    return Left(ServerFailure(message: e.message));
  }
}
