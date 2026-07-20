import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import '../entities/profile_update.dart';
import '../entities/user_profile.dart';

/// Hợp đồng cho hồ sơ người dùng. Domain khai báo, Data hiện thực.
abstract interface class ProfileRepository {
  /// `GET /v1/users/me` — hồ sơ của chính người đang đăng nhập.
  Future<Either<Failure, UserProfile>> getMyProfile();

  /// `PATCH /v1/users/me` — trả về hồ sơ SAU khi cập nhật.
  Future<Either<Failure, UserProfile>> updateMyProfile(ProfileUpdate changes);

  /// `PATCH /v1/users/me/password` — server trả 204 rỗng nên không có dữ liệu.
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
