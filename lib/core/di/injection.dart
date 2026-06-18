import 'package:get_it/get_it.dart';
import 'package:smart_stay_ai/core/network/dio_client.dart';
import 'package:smart_stay_ai/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:smart_stay_ai/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smart_stay_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:smart_stay_ai/features/auth/domain/usecases/login_user.dart';
import 'package:smart_stay_ai/features/auth/domain/usecases/register_user.dart';
import 'package:smart_stay_ai/features/auth/presentation/bloc/auth_bloc.dart';

/// "Service Locator" — nơi khai báo mọi phụ thuộc của app.
final sl = GetIt.instance;

/// Gọi 1 lần ở main() trước runApp().
Future<void> initDependencies() async {
  // ---- Core ----
  sl.registerLazySingleton(() => DioClient());

  // ---- Feature: auth ----
  // DataSource
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  // UseCase
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));

  // Bloc (factory: tạo mới mỗi lần dùng)
  sl.registerFactory(() => AuthBloc(loginUser: sl(), registerUser: sl()));
}
