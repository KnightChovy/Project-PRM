import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../repositories/profile_repository.dart';

/// Use case: đổi mật khẩu của chính mình.
///
/// Chặn sớm 2 lỗi mà backend cũng chặn, để khỏi tốn một vòng gọi mạng.
/// Luật mật khẩu lấy đúng theo `custom.validation.ts` phía server:
/// tối thiểu 8 ký tự, có ít nhất 1 chữ và 1 số.
class ChangeMyPassword implements UseCase<Unit, ChangeMyPasswordParams> {
  final ProfileRepository repository;
  const ChangeMyPassword(this.repository);

  @override
  Future<Either<Failure, Unit>> call(ChangeMyPasswordParams params) {
    if (params.newPassword == params.currentPassword) {
      return Future.value(
        const Left(
          ServerFailure(message: 'Mật khẩu mới phải khác mật khẩu hiện tại.'),
        ),
      );
    }
    if (!_isStrongEnough(params.newPassword)) {
      return Future.value(
        const Left(
          ServerFailure(
            message: 'Mật khẩu phải từ 8 ký tự và có cả chữ lẫn số.',
          ),
        ),
      );
    }
    return repository.changePassword(
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
    );
  }

  bool _isStrongEnough(String value) =>
      value.length >= 8 &&
      RegExp(r'\d').hasMatch(value) &&
      RegExp('[a-zA-Z]').hasMatch(value);
}

class ChangeMyPasswordParams extends Equatable {
  final String currentPassword;
  final String newPassword;

  const ChangeMyPasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}
