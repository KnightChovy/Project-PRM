import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_stay_ai/core/network/dio_client.dart';
import 'package:smart_stay_ai/core/network/token_storage.dart';
import 'package:smart_stay_ai/core/session/app_session.dart';
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
import 'package:smart_stay_ai/features/review/data/datasources/review_remote_data_source.dart';
import 'package:smart_stay_ai/features/review/data/repositories/review_repository_impl.dart';
import 'package:smart_stay_ai/features/review/domain/repositories/review_repository.dart';
import 'package:smart_stay_ai/features/review/domain/usecases/submit_review.dart';
import 'package:smart_stay_ai/features/review/domain/usecases/get_my_reviews.dart';
import 'package:smart_stay_ai/features/review/presentation/providers/review_notifier.dart';
import 'package:smart_stay_ai/features/assistant/data/datasources/assistant_remote_data_source.dart';
import 'package:smart_stay_ai/features/assistant/data/repositories/assistant_repository_impl.dart';
import 'package:smart_stay_ai/features/assistant/domain/repositories/assistant_repository.dart';
import 'package:smart_stay_ai/features/assistant/domain/usecases/load_my_conversation.dart';
import 'package:smart_stay_ai/features/assistant/domain/usecases/send_message.dart';
import 'package:smart_stay_ai/features/assistant/presentation/providers/assistant_notifier.dart';
import 'package:smart_stay_ai/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:smart_stay_ai/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:smart_stay_ai/features/profile/domain/repositories/profile_repository.dart';
import 'package:smart_stay_ai/features/profile/domain/usecases/change_my_password.dart';
import 'package:smart_stay_ai/features/profile/domain/usecases/get_my_profile.dart';
import 'package:smart_stay_ai/features/profile/domain/usecases/update_my_profile.dart';
import 'package:smart_stay_ai/features/profile/presentation/providers/profile_notifier.dart';
import 'package:smart_stay_ai/features/hotel/data/datasources/hotel_remote_data_source.dart';
import 'package:smart_stay_ai/features/hotel/data/repositories/hotel_repository_impl.dart';
import 'package:smart_stay_ai/features/hotel/domain/repositories/hotel_repository.dart';
import 'package:smart_stay_ai/features/hotel/domain/usecases/search_hotels.dart';
import 'package:smart_stay_ai/features/hotel/domain/usecases/get_hotel_detail.dart';
import 'package:smart_stay_ai/features/hotel/presentation/providers/hotel_notifier.dart';
import 'package:smart_stay_ai/features/hotel/presentation/providers/hotel_detail_notifier.dart';

/// "Service Locator" — nơi khai báo mọi phụ thuộc của app.
final sl = GetIt.instance;

/// Gọi 1 lần ở main() trước runApp().
Future<void> initDependencies() async {
  // ---- Core ----
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => TokenStorage(prefs));
  sl.registerLazySingleton(() => AppSession(sl()));

  // DioClient nhận callback làm mới phiên thay vì phụ thuộc thẳng vào
  // AuthRepository — nếu không sẽ vòng tròn: repository cần DioClient.
  // Closure chỉ được gọi lúc gặp 401 nên tới lúc đó repository đã sẵn sàng.
  sl.registerLazySingleton(
    () => DioClient(
      sl(),
      refreshSession: () async {
        final result = await sl<AuthRepository>().refreshTokens();
        return result.isRight();
      },
    ),
  );

  // ---- Feature: auth ----
  // DataSource — gọi API thật của smartstayai-system.
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

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

  // Notifier — SINGLETON: đây là trạng thái phiên của cả app, không phải state
  // riêng của một màn. Trước đây để factory nên mỗi màn `sl<AuthNotifier>()`
  // lại dựng một instance rời, khiến `isAuthenticated` luôn sai.
  sl.registerLazySingleton(
    () => AuthNotifier(
      session: sl(),
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
  sl.registerLazySingleton<ReviewRemoteDataSource>(
    () => ReviewRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ReviewRepository>(() => ReviewRepositoryImpl(sl()));
  sl.registerLazySingleton(() => SubmitReview(sl()));
  sl.registerLazySingleton(() => GetMyReviews(sl()));
  sl.registerFactory(() => ReviewNotifier(sl(), sl()));

  // ---- Feature: assistant (AI Assistant) ----
  // DataSource — chatbot Gemini thật ở /v1/conversations.
  sl.registerLazySingleton<AssistantRemoteDataSource>(
    () => AssistantRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AssistantRepository>(
    () => AssistantRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => SendMessage(sl()));
  sl.registerLazySingleton(() => LoadMyConversation(sl()));
  // Singleton: vào chat từ tab Assistant hay từ Help & Support đều phải thấy
  // cùng một hội thoại (giữ conversationId, khỏi tạo hội thoại mới mỗi lần mở).
  sl.registerLazySingleton(
    () => AssistantNotifier(sendMessage: sl(), loadMyConversation: sl()),
  );

  // ---- Feature: profile ----
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetMyProfile(sl()));
  sl.registerLazySingleton(() => UpdateMyProfile(sl()));
  sl.registerLazySingleton(() => ChangeMyPassword(sl()));
  // Singleton: sửa hồ sơ ở Edit Profile thì màn Profile tự cập nhật theo.
  sl.registerLazySingleton(
    () => ProfileNotifier(
      getMyProfile: sl(),
      updateMyProfile: sl(),
      changeMyPassword: sl(),
    ),
  );

  // ---- Feature: hotel (API thật) ----
  sl.registerLazySingleton<HotelRemoteDataSource>(
    () => HotelRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<HotelRepository>(() => HotelRepositoryImpl(sl()));
  sl.registerLazySingleton(() => SearchHotels(sl()));
  sl.registerLazySingleton(() => GetHotelDetail(sl()));
  // Singleton: Home/Search/Map dùng chung danh sách khách sạn đã tải.
  sl.registerLazySingleton(() => HotelNotifier(sl()));
  // Factory: mỗi trang chi tiết là một phiên riêng.
  sl.registerFactory(() => HotelDetailNotifier(sl()));

  // ---- Dọn dữ liệu khi đăng xuất ----
  // Mọi notifier ở trên đều là lazy singleton, sống suốt vòng đời tiến trình.
  // Không dọn thì người đăng nhập kế tiếp trên cùng máy sẽ thấy hồ sơ, danh
  // sách booking và toàn bộ đoạn chat AI của người trước.
  final session = sl<AppSession>();
  session.addResetHandler(() => sl<ProfileNotifier>().reset());
  session.addResetHandler(() => sl<AssistantNotifier>().reset());
  // Chỉ MyBookingsNotifier cần dọn: BookingNotifier là factory, mỗi luồng đặt
  // phòng dùng một instance riêng rồi bị dispose cùng màn hình.
  session.addResetHandler(() => sl<MyBookingsNotifier>().reset());
}
