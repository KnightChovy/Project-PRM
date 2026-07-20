import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_stay_ai/core/network/dio_client.dart';
import 'package:smart_stay_ai/core/network/token_storage.dart';
// import 'package:smart_stay_ai/features/auth/data/datasources/auth_mock_remote_data_source.dart';
import 'package:smart_stay_ai/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:smart_stay_ai/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smart_stay_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:smart_stay_ai/features/auth/domain/usecases/forgot_password.dart';
import 'package:smart_stay_ai/features/auth/domain/usecases/login_user.dart';
import 'package:smart_stay_ai/features/auth/domain/usecases/logout_user.dart';
import 'package:smart_stay_ai/features/auth/domain/usecases/refresh_tokens.dart';
import 'package:smart_stay_ai/features/auth/domain/usecases/register_user.dart';
import 'package:smart_stay_ai/features/auth/domain/usecases/reset_password.dart';
import 'package:smart_stay_ai/features/auth/domain/usecases/send_otp.dart';
import 'package:smart_stay_ai/features/auth/domain/usecases/send_verification_email.dart';
import 'package:smart_stay_ai/features/auth/domain/usecases/verify_email.dart';
import 'package:smart_stay_ai/features/auth/presentation/providers/auth_notifier.dart';
import 'package:smart_stay_ai/features/booking/data/datasources/booking_local_data_source.dart';
import 'package:smart_stay_ai/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:smart_stay_ai/features/booking/domain/repositories/booking_repository.dart';
import 'package:smart_stay_ai/features/booking/domain/usecases/create_booking.dart';
import 'package:smart_stay_ai/features/booking/domain/usecases/get_my_bookings.dart';
import 'package:smart_stay_ai/features/booking/presentation/providers/booking_notifier.dart';
// ---- Thêm bởi BinhKhiem (feat: myBooking/detail/cancel/review/AI) ----
import 'package:smart_stay_ai/features/booking/data/datasources/booking_history_local_data_source.dart';
import 'package:smart_stay_ai/features/booking/data/repositories/booking_history_repository_impl.dart';
import 'package:smart_stay_ai/features/booking/domain/repositories/booking_history_repository.dart';
import 'package:smart_stay_ai/features/booking/domain/usecases/cancel_booking.dart';
import 'package:smart_stay_ai/features/booking/domain/usecases/get_booking_history.dart';
import 'package:smart_stay_ai/features/booking/presentation/providers/booking_history_notifier.dart';
import 'package:smart_stay_ai/features/review/data/datasources/review_local_data_source.dart';
import 'package:smart_stay_ai/features/review/data/repositories/review_repository_impl.dart';
import 'package:smart_stay_ai/features/review/domain/repositories/review_repository.dart';
import 'package:smart_stay_ai/features/review/domain/usecases/submit_review.dart';
import 'package:smart_stay_ai/features/review/domain/usecases/get_my_reviews.dart';
import 'package:smart_stay_ai/features/review/presentation/providers/review_notifier.dart';
import 'package:smart_stay_ai/features/assistant/data/datasources/assistant_local_data_source.dart';
import 'package:smart_stay_ai/features/assistant/data/repositories/assistant_repository_impl.dart';
import 'package:smart_stay_ai/features/assistant/domain/repositories/assistant_repository.dart';
import 'package:smart_stay_ai/features/assistant/domain/usecases/send_message.dart';
import 'package:smart_stay_ai/features/assistant/presentation/providers/assistant_notifier.dart';

/// "Service Locator" — nơi khai báo mọi phụ thuộc của app.
final sl = GetIt.instance;

/// Gọi 1 lần ở main() trước runApp().
Future<void> initDependencies() async {
  // ---- Core ----
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => TokenStorage(prefs));
  sl.registerLazySingleton(() => DioClient(sl()));

  // ---- Feature: auth ----
  // DataSource — gọi API thật của smartstayai-system.
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  // Chưa có backend? Đổi sang bản giả lập:
  // sl.registerLazySingleton<AuthRemoteDataSource>(
  //   () => AuthMockRemoteDataSource(),
  // );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: sl(), tokenStorage: sl()),
  );

  // UseCase
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => SendOtp(sl()));
  sl.registerLazySingleton(() => RefreshTokens(sl()));
  sl.registerLazySingleton(() => ForgotPassword(sl()));
  sl.registerLazySingleton(() => ResetPassword(sl()));
  sl.registerLazySingleton(() => SendVerificationEmail(sl()));
  sl.registerLazySingleton(() => VerifyEmail(sl()));

  // Notifier (factory: tạo mới mỗi lần dùng)
  sl.registerFactory(
    () => AuthNotifier(
      loginUser: sl(),
      registerUser: sl(),
      logoutUser: sl(),
      sendOtpUseCase: sl(),
      refreshTokensUseCase: sl(),
      forgotPasswordUseCase: sl(),
      resetPasswordUseCase: sl(),
      sendVerificationEmailUseCase: sl(),
      verifyEmailUseCase: sl(),
    ),
  );

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

  // ============================================================
  // Thêm bởi BinhKhiem (feat: myBooking/detail/cancel/review/AI)
  // ============================================================

  // ---- Feature: booking history (My Bookings 3 tab + Cancel) ----
  sl.registerLazySingleton<BookingHistoryLocalDataSource>(
    () => BookingHistoryLocalDataSourceImpl(),
  );
  // Truyền cả kho lịch sử (seeded + huỷ) và kho booking thật của Phat.
  sl.registerLazySingleton<BookingHistoryRepository>(
    () => BookingHistoryRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton(() => GetBookingHistory(sl()));
  sl.registerLazySingleton(() => CancelBooking(sl()));
  // Singleton: huỷ ở màn chi tiết thì danh sách My Bookings tự cập nhật.
  sl.registerLazySingleton(
    () => BookingHistoryNotifier(
      getBookingHistory: sl(),
      cancelBooking: sl(),
      createBooking: sl(),
    ),
  );

  // ---- Feature: review (Write Review) ----
  sl.registerLazySingleton<ReviewLocalDataSource>(
    () => ReviewLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => SubmitReview(sl()));
  sl.registerLazySingleton(() => GetMyReviews(sl()));
  sl.registerFactory(() => ReviewNotifier(sl(), sl()));

  // ---- Feature: assistant (AI Assistant) ----
  sl.registerLazySingleton<AssistantLocalDataSource>(
    () => AssistantLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<AssistantRepository>(
    () => AssistantRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => SendMessage(sl()));
  sl.registerFactory(() => AssistantNotifier(sl()));
}
