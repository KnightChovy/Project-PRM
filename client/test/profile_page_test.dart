import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_stay_ai/core/di/injection.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/network/token_storage.dart';
import 'package:smart_stay_ai/core/session/app_session.dart';
import 'package:smart_stay_ai/features/profile/domain/entities/profile_update.dart';
import 'package:smart_stay_ai/features/profile/domain/entities/user_profile.dart';
import 'package:smart_stay_ai/features/profile/domain/repositories/profile_repository.dart';
import 'package:smart_stay_ai/features/profile/domain/usecases/change_my_password.dart';
import 'package:smart_stay_ai/features/profile/domain/usecases/get_my_profile.dart';
import 'package:smart_stay_ai/features/profile/domain/usecases/update_my_profile.dart';
import 'package:smart_stay_ai/features/profile/presentation/pages/profile_page.dart';
import 'package:smart_stay_ai/features/profile/presentation/providers/profile_notifier.dart';

const _profile = UserProfile(
  id: 'u1',
  email: 'an@example.com',
  fullName: 'Nguyễn Văn An',
  role: 'customer',
  status: 'active',
  emailVerifiedAt: null,
  preferredLanguage: 'vi',
  preferredCurrency: 'VND',
  marketingOptIn: false,
);

/// Fake repository tự viết (không dùng mocktail để khỏi thêm thư viện).
class _FakeProfileRepository implements ProfileRepository {
  bool shouldFail = false;

  @override
  Future<Either<Failure, UserProfile>> getMyProfile() async => shouldFail
      ? const Left(ServerFailure(message: 'Mất kết nối tới máy chủ'))
      : const Right(_profile);

  @override
  Future<Either<Failure, UserProfile>> updateMyProfile(
    ProfileUpdate changes,
  ) async => const Right(_profile);

  @override
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async => const Right(unit);
}

/// Dựng DI cho ProfilePage: trang này lấy cả [ProfileNotifier] lẫn [AppSession]
/// qua `sl<>()`, và [AppSession] quyết định hiện hồ sơ hay lời mời đăng nhập.
Future<AppSession> _registerDeps(
  _FakeProfileRepository repo, {
  required bool signedIn,
}) async {
  SharedPreferences.setMockInitialValues(
    signedIn ? {'auth_refresh_token': 'r1'} : {},
  );
  final storage = TokenStorage(await SharedPreferences.getInstance());
  final session = AppSession(storage);

  sl.registerLazySingleton<AppSession>(() => session);
  sl.registerLazySingleton<ProfileNotifier>(
    () => ProfileNotifier(
      getMyProfile: GetMyProfile(repo),
      updateMyProfile: UpdateMyProfile(repo),
      changeMyPassword: ChangeMyPassword(repo),
    ),
  );
  return session;
}

/// App thật provide AppSession ở gốc (main.dart), test phải dựng lại như vậy.
Widget _wrap(AppSession session) => ChangeNotifierProvider<AppSession>.value(
  value: session,
  child: const MaterialApp(home: ProfilePage()),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(sl.reset);

  testWidgets('ProfilePage hiển thị tên và email lấy từ API', (tester) async {
    final session = await _registerDeps(
      _FakeProfileRepository(),
      signedIn: true,
    );

    await tester.pumpWidget(_wrap(session));
    await tester.pump(); // để load() hoàn tất

    expect(find.text('Nguyễn Văn An'), findsOneWidget);
    expect(find.text('an@example.com'), findsOneWidget);
    // Hồ sơ chưa xác thực email → phải cảnh báo.
    expect(find.text('Email chưa xác thực'), findsOneWidget);
  });

  testWidgets('ProfilePage báo lỗi kèm nút thử lại khi API hỏng', (
    tester,
  ) async {
    final session = await _registerDeps(
      _FakeProfileRepository()..shouldFail = true,
      signedIn: true,
    );

    await tester.pumpWidget(_wrap(session));
    await tester.pump();

    expect(find.text('Mất kết nối tới máy chủ'), findsOneWidget);
    expect(find.text('Thử lại'), findsOneWidget);
  });

  testWidgets('khách chưa đăng nhập thấy lời mời đăng nhập, không thấy hồ sơ', (
    tester,
  ) async {
    final session = await _registerDeps(
      _FakeProfileRepository(),
      signedIn: false,
    );

    await tester.pumpWidget(_wrap(session));
    await tester.pump();

    expect(find.text('Bạn chưa đăng nhập'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsOneWidget);
    // Không được lộ dữ liệu hay nút chỉ dành cho người đã đăng nhập.
    expect(find.text('Nguyễn Văn An'), findsNothing);
    expect(find.text('Log Out'), findsNothing);
    expect(find.text('SmartStay Gold'), findsNothing);
  });
}
