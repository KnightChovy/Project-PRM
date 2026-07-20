import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

/// Use case: lấy hồ sơ của người dùng đang đăng nhập.
class GetMyProfile implements UseCase<UserProfile, NoParams> {
  final ProfileRepository repository;
  const GetMyProfile(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(NoParams params) =>
      repository.getMyProfile();
}
