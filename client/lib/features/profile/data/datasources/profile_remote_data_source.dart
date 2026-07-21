import 'package:dio/dio.dart';
import 'package:smart_stay_ai/core/constants/api_constants.dart';
import 'package:smart_stay_ai/core/error/exceptions.dart';
import 'package:smart_stay_ai/core/network/dio_client.dart';
import '../../domain/entities/profile_update.dart';
import '../models/user_profile_model.dart';

/// Nguồn dữ liệu hồ sơ từ API. Ném [ServerException] khi lỗi.
abstract interface class ProfileRemoteDataSource {
  Future<UserProfileModel> getMyProfile();

  Future<UserProfileModel> updateMyProfile(ProfileUpdate changes);

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient client;
  const ProfileRemoteDataSourceImpl(this.client);

  @override
  Future<UserProfileModel> getMyProfile() async {
    try {
      final res = await client.dio.get(ApiConstants.me);
      return UserProfileModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
        message: _messageOf(e, 'Unable to load your profile.'),
      );
    }
  }

  @override
  Future<UserProfileModel> updateMyProfile(ProfileUpdate changes) async {
    try {
      final res = await client.dio.patch(
        ApiConstants.me,
        data: profileUpdateToJson(changes),
      );
      return UserProfileModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
        message: _messageOf(e, 'Unable to save your profile.'),
      );
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Server trả 204 KHÔNG kèm body — đừng đọc res.data.
      await client.dio.patch(
        ApiConstants.changePassword,
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );
    } on DioException catch (e) {
      throw ServerException(
        message: _messageOf(e, 'Unable to change your password.'),
      );
    }
  }

  /// Backend trả lỗi dạng `{ code, message }` — CHỈ lấy `message` đó.
  String _messageOf(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      final message = (data['message'] as String).trim();
      if (message.isNotEmpty) return message;
    }
    if (e.response == null) {
      return 'Cannot reach the server. Check your connection and try again.';
    }
    return fallback;
  }
}
