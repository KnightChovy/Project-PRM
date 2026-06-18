import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import '../entities/user.dart';

/// Hợp đồng (interface) cho việc xác thực.
/// Domain chỉ KHAI BÁO — tầng Data sẽ hiện thực (implement).
abstract interface class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
  });
}
