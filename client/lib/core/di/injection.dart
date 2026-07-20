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
import 'package:smart_stay_ai/features/booking/data/datasources/booking_remote_data_source.dart';
import 'package:smart_stay_ai/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:smart_stay_ai/features/booking/domain/repositories/booking_repository.dart';
import 'package:smart_stay_ai/features/booking/domain/usecases/cancel_booking.dart';
import 'package:smart_stay_ai/features/booking/domain/usecases/create_booking.dart';
import 'package:smart_stay_ai/features/booking/domain/usecases/get_booking_detail.dart';
import 'package:smart_stay_ai/features/booking/domain/usecases/get_my_bookings.dart';
import 'package:smart_stay_ai/features/booking/domain/usecases/pay_with_wallet.dart';
import 'package:smart_stay_ai/features/booking/domain/usecases/start_sepay_checkout.dart';
import 'package:smart_stay_ai/features/booking/domain/usecases/start_vnpay_checkout.dart';
import 'package:smart_stay_ai/features/booking/presentation/providers/booking_notifier.dart';
import 'package:smart_stay_ai/features/booking/presentation/providers/my_bookings_notifier.dart';
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

  // ---- Feature: booking (API thật) ----
  sl.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => CreateBooking(sl()));
  sl.registerLazySingleton(() => GetMyBookings(sl()));
  sl.registerLazySingleton(() => GetBookingDetail(sl()));
  sl.registerLazySingleton(() => CancelBooking(sl()));
  sl.registerLazySingleton(() => StartVnpayCheckout(sl()));
  sl.registerLazySingleton(() => StartSepayCheckout(sl()));
  sl.registerLazySingleton(() => PayWithWallet(sl()));

  // Factory: mỗi luồng đặt phòng là một phiên riêng, và notifier có Timer
  // poll SePay cần được dispose cùng màn hình.
  sl.registerFactory(
    () => BookingNotifier(
      createBooking: sl(),
      getBookingDetail: sl(),
      startVnpayCheckout: sl(),
      startSepayCheckout: sl(),
      payWithWallet: sl(),
      cancelBooking: sl(),
    ),
  );
  // Singleton: huỷ ở màn chi tiết thì tab My Bookings tự cập nhật.
  sl.registerLazySingleton(() => MyBookingsNotifier(sl()));

  // ============================================================
  // Thêm bởi BinhKhiem (feat: review/AI)
  // ============================================================

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
