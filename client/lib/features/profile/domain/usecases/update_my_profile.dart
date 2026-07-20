import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../entities/profile_update.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

/// Use case: cập nhật hồ sơ.
///
/// Quy tắc nghiệp vụ: không gọi API khi người dùng chưa sửa gì — backend
/// bắt buộc body có ít nhất 1 key và sẽ trả 400.
class UpdateMyProfile implements UseCase<UserProfile, ProfileUpdate> {
  final ProfileRepository repository;
  const UpdateMyProfile(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(ProfileUpdate params) {
    if (params.isEmpty) {
      return Future.value(
        const Left(ServerFailure(message: 'Bạn chưa thay đổi thông tin nào.')),
      );
    }
    return repository.updateMyProfile(params);
  }
}
