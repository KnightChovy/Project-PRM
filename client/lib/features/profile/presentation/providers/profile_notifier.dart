import 'package:flutter/foundation.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import 'package:smart_stay_ai/features/profile/domain/entities/profile_update.dart';
import 'package:smart_stay_ai/features/profile/domain/entities/user_profile.dart';
import 'package:smart_stay_ai/features/profile/domain/usecases/change_my_password.dart';
import 'package:smart_stay_ai/features/profile/domain/usecases/get_my_profile.dart';
import 'package:smart_stay_ai/features/profile/domain/usecases/update_my_profile.dart';

enum ProfileStatus { initial, loading, loaded, error }

/// Quản lý hồ sơ người dùng cho 4 màn: Profile, Edit Profile,
/// Change Password và Notification Settings. Chỉ gọi UseCase.
///
/// Tách 2 kênh trạng thái: [status] cho việc TẢI hồ sơ (dựng khung màn hình),
/// [isSaving]/[actionErrorMessage] cho các hành động LƯU — nhờ vậy lúc bấm
/// Save màn hình không nháy về trạng thái loading toàn trang.
class ProfileNotifier extends ChangeNotifier {
  final GetMyProfile getMyProfile;
  final UpdateMyProfile updateMyProfile;
  final ChangeMyPassword changeMyPassword;

  ProfileNotifier({
    required this.getMyProfile,
    required this.updateMyProfile,
    required this.changeMyPassword,
  });

  ProfileStatus status = ProfileStatus.initial;
  UserProfile? profile;
  String? errorMessage;

  bool isSaving = false;
  String? actionErrorMessage;

  bool get isLoading => status == ProfileStatus.loading;

  /// Xoá hồ sơ đang giữ trong RAM. Gọi khi đăng xuất — notifier là singleton
  /// nên không dọn thì người đăng nhập kế tiếp thấy tên/ảnh của người trước.
  void reset() {
    status = ProfileStatus.initial;
    profile = null;
    errorMessage = null;
    isSaving = false;
    actionErrorMessage = null;
    notifyListeners();
  }

  /// Tải hồ sơ. Gọi khi mở tab Profile.
  Future<void> load() async {
    status = ProfileStatus.loading;
    errorMessage = null;
    notifyListeners();

    final result = await getMyProfile(const NoParams());
    result.fold(
      (failure) {
        status = ProfileStatus.error;
        errorMessage = failure.message;
      },
      (data) {
        status = ProfileStatus.loaded;
        profile = data;
      },
    );
    notifyListeners();
  }

  /// Lưu thay đổi hồ sơ. Trả về `true` khi thành công để widget điều hướng.
  Future<bool> save(ProfileUpdate changes) async {
    isSaving = true;
    actionErrorMessage = null;
    notifyListeners();

    final result = await updateMyProfile(changes);
    return result.fold(
      (failure) {
        actionErrorMessage = failure.message;
        isSaving = false;
        notifyListeners();
        return false;
      },
      (updated) {
        // API trả về hồ sơ sau cập nhật → dùng luôn, khỏi gọi lại GET.
        profile = updated;
        status = ProfileStatus.loaded;
        isSaving = false;
        notifyListeners();
        return true;
      },
    );
  }

  /// Bật/tắt nhận email marketing — cờ preference DUY NHẤT backend đang có.
  Future<bool> setMarketingOptIn(bool value) =>
      save(ProfileUpdate(marketingOptIn: value));

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    isSaving = true;
    actionErrorMessage = null;
    notifyListeners();

    final result = await changeMyPassword(
      ChangeMyPasswordParams(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );
    return result.fold(
      (failure) {
        actionErrorMessage = failure.message;
        isSaving = false;
        notifyListeners();
        return false;
      },
      (_) {
        isSaving = false;
        notifyListeners();
        return true;
      },
    );
  }
}
