import 'package:shared_preferences/shared_preferences.dart';

/// Lưu access/refresh token trên máy. Dùng chung cho [ApiInterceptor]
/// (gắn header) và tầng Data của feature auth (đọc/ghi khi login/refresh/logout).
class TokenStorage {
  final SharedPreferences prefs;
  const TokenStorage(this.prefs);

  static const _kAccessToken = 'auth_access_token';
  static const _kRefreshToken = 'auth_refresh_token';
  static const _kTenantId = 'auth_tenant_id';

  String? get accessToken => prefs.getString(_kAccessToken);
  String? get refreshToken => prefs.getString(_kRefreshToken);
  String? get tenantId => prefs.getString(_kTenantId);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await prefs.setString(_kAccessToken, accessToken);
    await prefs.setString(_kRefreshToken, refreshToken);
  }

  Future<void> clear() async {
    await prefs.remove(_kAccessToken);
    await prefs.remove(_kRefreshToken);
  }
}
