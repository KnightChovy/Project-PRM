import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/exceptions.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/network/token_storage.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// Hiện thực hợp đồng [AuthRepository].
/// Đây là NƠI DUY NHẤT đổi Exception -> Failure.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final TokenStorage tokenStorage;
  const AuthRepositoryImpl({required this.remote, required this.tokenStorage});

  @override
  Future<Either<Failure, Unit>> sendOtp({required String email}) async {
    try {
      await remote.sendOtp(email: email);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, AuthSession>> register({
    required String name,
    required String email,
    required String password,
    required String verificationCode,
    String? phone,
  }) async {
    try {
      final response = await remote.register(
        name: name,
        email: email,
        password: password,
        verificationCode: verificationCode,
        phone: phone,
      );
      // Register trả sẵn token -> lưu luôn để user vào thẳng app, khỏi login lại.
      await tokenStorage.saveTokens(
        accessToken: response.tokens.accessToken,
        refreshToken: response.tokens.refreshToken,
      );
      return Right(AuthSession(user: response.user, tokens: response.tokens));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, AuthSession>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await remote.login(email: email, password: password);
      await tokenStorage.saveTokens(
        accessToken: response.tokens.accessToken,
        refreshToken: response.tokens.refreshToken,
      );
      return Right(AuthSession(user: response.user, tokens: response.tokens));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    final refreshToken = tokenStorage.refreshToken;
    try {
      if (refreshToken != null) {
        await remote.logout(refreshToken: refreshToken);
      }
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } finally {
      // Luôn xoá token cục bộ dù server có phản hồi lỗi hay không.
      await tokenStorage.clear();
    }
  }

  @override
  Future<Either<Failure, AuthTokens>> refreshTokens() async {
    final refreshToken = tokenStorage.refreshToken;
    if (refreshToken == null) {
      return const Left(AuthFailure(message: 'You are not signed in.'));
    }
    try {
      final tokens = await remote.refreshTokens(refreshToken: refreshToken);
      await tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      return Right(tokens);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> forgotPassword({required String email}) async {
    try {
      await remote.forgotPassword(email: email);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await remote.resetPassword(token: token, newPassword: newPassword);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendVerificationEmail() async {
    try {
      await remote.sendVerificationEmail();
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> verifyEmail({required String token}) async {
    try {
      await remote.verifyEmail(token: token);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
