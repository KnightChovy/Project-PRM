import 'package:get_it/get_it.dart';
import 'package:smart_stay_ai/core/network/dio_client.dart';
import 'package:smart_stay_ai/features/auth/data/datasources/auth_mock_remote_data_source.dart';
import 'package:smart_stay_ai/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:smart_stay_ai/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smart_stay_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:smart_stay_ai/features/auth/domain/usecases/login_user.dart';
import 'package:smart_stay_ai/features/auth/domain/usecases/register_user.dart';
import 'package:smart_stay_ai/features/auth/presentation/providers/auth_notifier.dart';
import 'package:smart_stay_ai/features/booking/data/datasources/booking_local_data_source.dart';
import 'package:smart_stay_ai/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:smart_stay_ai/features/booking/domain/repositories/booking_repository.dart';
import 'package:smart_stay_ai/features/booking/domain/usecases/create_booking.dart';
import 'package:smart_stay_ai/features/booking/domain/usecases/get_my_bookings.dart';
import 'package:smart_stay_ai/features/booking/presentation/providers/booking_notifier.dart';

/// "Service Locator" — nơi khai báo mọi phụ thuộc của app.
final sl = GetIt.instance;

/// Gọi 1 lần ở main() trước runApp().
Future<void> initDependencies() async {
  // ---- Core ----
  sl.registerLazySingleton(() => DioClient());

  // ---- Feature: auth ----
  // DataSource — đang dùng MOCK (chưa có backend).
  // Khi có API thật: đổi sang AuthRemoteDataSourceImpl(sl()).
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthMockRemoteDataSource(),
  );
  // sl.registerLazySingleton<AuthRemoteDataSource>(
  //   () => AuthRemoteDataSourceImpl(sl()),
  // );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  // UseCase
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));

  // Notifier (factory: tạo mới mỗi lần dùng)
  sl.registerFactory(() => AuthNotifier(loginUser: sl(), registerUser: sl()));

  // ---- Feature: booking ----
  // DataSource (singleton: giữ danh sách booking trong RAM)
  sl.registerLazySingleton(() => BookingLocalDataSource());

  // Repository
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(sl()),
  );

  // UseCase
  sl.registerLazySingleton(() => CreateBooking(sl()));
  sl.registerLazySingleton(() => GetMyBookings(sl()));

  // Notifier (singleton: chia sẻ danh sách giữa màn xác nhận và tab My Booking)
  sl.registerLazySingleton(
    () => BookingNotifier(createBooking: sl(), getMyBookings: sl()),
  );
}
