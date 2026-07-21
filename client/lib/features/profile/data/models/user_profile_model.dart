import '../../domain/entities/profile_update.dart';
import '../../domain/entities/user_profile.dart';

/// DTO của [UserProfile]: nơi DUY NHẤT map JSON ↔ Entity.
class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.phone,
    super.avatarUrl,
    required super.role,
    required super.status,
    super.emailVerifiedAt,
    super.dateOfBirth,
    super.nationality,
    super.idCardNumber,
    super.passportNumber,
    required super.preferredLanguage,
    required super.preferredCurrency,
    required super.marketingOptIn,
    super.travelStyles,
    super.notificationPrefs,
    super.loyaltyPoints,
    super.loyaltyTier,
    super.tripsCount,
    super.reviewsCount,
  });

  /// Nhận nguyên response của `GET`/`PATCH /v1/users/me`.
  ///
  /// `profile` là object lồng và CÓ THỂ null (user chưa từng cập nhật hồ sơ),
  /// nên mọi field bên trong đều phải đọc phòng thủ.
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>?;
    final loyalty = json['loyaltyAccount'] as Map<String, dynamic>?;
    final stats = json['stats'] as Map<String, dynamic>?;

    return UserProfileModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      phone: json['phone']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      role: json['role']?.toString() ?? 'customer',
      status: json['status']?.toString() ?? 'active',
      emailVerifiedAt: _parseDate(json['emailVerifiedAt']),
      dateOfBirth: _parseDate(profile?['dateOfBirth']),
      nationality: profile?['nationality']?.toString(),
      idCardNumber: profile?['idCardNumber']?.toString(),
      passportNumber: profile?['passportNumber']?.toString(),
      preferredLanguage: profile?['preferredLanguage']?.toString() ?? 'vi',
      preferredCurrency: profile?['preferredCurrency']?.toString() ?? 'VND',
      marketingOptIn: profile?['marketingOptIn'] as bool? ?? false,
      travelStyles: _strList(profile?['travelStyles']),
      notificationPrefs: _boolMap(profile?['notificationPrefs']),
      loyaltyPoints: (loyalty?['totalPoints'] as num?)?.toInt() ?? 0,
      loyaltyTier: loyalty?['tier']?.toString() ?? 'bronze',
      tripsCount: (stats?['trips'] as num?)?.toInt() ?? 0,
      reviewsCount: (stats?['reviews'] as num?)?.toInt() ?? 0,
    );
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString());
  }

  static List<String> _strList(Object? v) =>
      v is List ? v.whereType<String>().toList() : const [];

  static Map<String, bool> _boolMap(Object? v) {
    if (v is Map) {
      return {
        for (final e in v.entries)
          if (e.value is bool) e.key.toString(): e.value as bool,
      };
    }
    return const {};
  }
}

/// Dựng body cho `PATCH /v1/users/me`: CHỈ đưa vào những field khác null.
///
/// Gửi thừa key sẽ bị Joi từ chối (schema không cho unknown key), còn gửi
/// `null` cho field người dùng không đụng tới sẽ vô tình xoá dữ liệu.
Map<String, dynamic> profileUpdateToJson(ProfileUpdate changes) {
  final body = <String, dynamic>{};

  void put(String key, Object? value) {
    if (value != null) body[key] = value;
  }

  put('fullName', changes.fullName);
  put('phone', changes.phone);
  put('avatarUrl', changes.avatarUrl);
  // Server khai báo Joi.date().iso() → phải là chuỗi ISO 8601.
  put('dateOfBirth', changes.dateOfBirth?.toIso8601String());
  put('nationality', changes.nationality);
  put('idCardNumber', changes.idCardNumber);
  put('passportNumber', changes.passportNumber);
  put('preferredLanguage', changes.preferredLanguage);
  put('preferredCurrency', changes.preferredCurrency);
  put('marketingOptIn', changes.marketingOptIn);
  put('travelStyles', changes.travelStyles);
  put('notificationPrefs', changes.notificationPrefs);

  return body;
}
