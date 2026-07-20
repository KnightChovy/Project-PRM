import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import 'package:smart_stay_ai/features/profile/domain/entities/profile_update.dart';
import 'package:smart_stay_ai/features/profile/domain/entities/user_profile.dart';
import 'package:smart_stay_ai/features/profile/domain/repositories/profile_repository.dart';
import 'package:smart_stay_ai/features/profile/domain/usecases/change_my_password.dart';
import 'package:smart_stay_ai/features/profile/domain/usecases/get_my_profile.dart';
import 'package:smart_stay_ai/features/profile/domain/usecases/update_my_profile.dart';

const _profile = UserProfile(
  id: 'u1',
  email: 'an@example.com',
  fullName: 'Nguyễn Văn An',
  role: 'customer',
  status: 'active',
  preferredLanguage: 'vi',
  preferredCurrency: 'VND',
  marketingOptIn: false,
);

/// Fake repository tự viết (không dùng mocktail để khỏi thêm thư viện).
class _FakeProfileRepository implements ProfileRepository {
  ProfileUpdate? lastChanges;
  String? lastCurrentPassword;
  String? lastNewPassword;
  bool shouldFail = false;

  @override
  Future<Either<Failure, UserProfile>> getMyProfile() async {
    if (shouldFail) return const Left(ServerFailure(message: 'server error'));
    return const Right(_profile);
  }

  @override
  Future<Either<Failure, UserProfile>> updateMyProfile(
    ProfileUpdate changes,
  ) async {
    lastChanges = changes;
    if (shouldFail) return const Left(ServerFailure(message: 'server error'));
    return const Right(_profile);
  }

  @override
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    lastCurrentPassword = currentPassword;
    lastNewPassword = newPassword;
    if (shouldFail) return const Left(ServerFailure(message: 'server error'));
    return const Right(unit);
  }
}

void main() {
  group('GetMyProfile use case', () {
    test('trả về hồ sơ từ repository', () async {
      final result = await GetMyProfile(_FakeProfileRepository())(
        const NoParams(),
      );

      expect(result.isRight(), isTrue);
      expect(
        result.getOrElse((_) => throw 'unreachable').email,
        'an@example.com',
      );
    });
  });

  group('UpdateMyProfile use case', () {
    test(
      'KHÔNG gọi API khi không có thay đổi nào (server sẽ trả 400)',
      () async {
        final repo = _FakeProfileRepository();

        final result = await UpdateMyProfile(repo)(const ProfileUpdate());

        expect(result.isLeft(), isTrue);
        expect(repo.lastChanges, isNull);
      },
    );

    test('gửi đúng phần đã sửa xuống repository', () async {
      final repo = _FakeProfileRepository();

      final result = await UpdateMyProfile(repo)(
        const ProfileUpdate(fullName: 'Trần Bình'),
      );

      expect(result.isRight(), isTrue);
      expect(repo.lastChanges?.fullName, 'Trần Bình');
      // Field không đụng tới phải giữ null để không lọt vào body.
      expect(repo.lastChanges?.phone, isNull);
    });
  });

  group('ChangeMyPassword use case', () {
    test('từ chối khi mật khẩu mới trùng mật khẩu cũ', () async {
      final repo = _FakeProfileRepository();

      final result = await ChangeMyPassword(repo)(
        const ChangeMyPasswordParams(
          currentPassword: 'abcd1234',
          newPassword: 'abcd1234',
        ),
      );

      expect(result.isLeft(), isTrue);
      expect(repo.lastNewPassword, isNull);
    });

    test('từ chối mật khẩu không đủ mạnh theo luật của server', () async {
      final repo = _FakeProfileRepository();

      // Thiếu chữ số → server cũng sẽ từ chối, chặn sớm ở client.
      final result = await ChangeMyPassword(repo)(
        const ChangeMyPasswordParams(
          currentPassword: 'abcd1234',
          newPassword: 'onlyletters',
        ),
      );

      expect(result.isLeft(), isTrue);
      expect(repo.lastNewPassword, isNull);
    });

    test('gọi repository khi mật khẩu hợp lệ', () async {
      final repo = _FakeProfileRepository();

      final result = await ChangeMyPassword(repo)(
        const ChangeMyPasswordParams(
          currentPassword: 'abcd1234',
          newPassword: 'newpass99',
        ),
      );

      expect(result.isRight(), isTrue);
      expect(repo.lastCurrentPassword, 'abcd1234');
      expect(repo.lastNewPassword, 'newpass99');
    });
  });
}
