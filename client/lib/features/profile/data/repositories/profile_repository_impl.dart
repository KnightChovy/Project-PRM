import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/exceptions.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import '../../domain/entities/profile_update.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

/// Hiện thực [ProfileRepository]. NƠI DUY NHẤT đổi Exception → Failure.
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remote;
  const ProfileRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, UserProfile>> getMyProfile() async {
    try {
      return Right(await remote.getMyProfile());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateMyProfile(
    ProfileUpdate changes,
  ) async {
    try {
      return Right(await remote.updateMyProfile(changes));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await remote.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
