import 'package:equatable/equatable.dart';

/// Hồ sơ đầy đủ của người dùng đang đăng nhập (`GET /v1/users/me`).
///
/// Backend trả về 2 tầng: các cột trên bảng `User` và một object `profile`
/// (bảng `UserProfile`, có thể null khi user chưa từng cập nhật). Ở Domain ta
/// làm phẳng thành MỘT entity vì màn Edit Profile sửa cả hai cùng lúc và
/// `PATCH /v1/users/me` cũng nhận body phẳng.
class UserProfile extends Equatable {
  // --- bảng User ---
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final String role;
  final String status;
  final DateTime? emailVerifiedAt;

  // --- bảng UserProfile (null khi chưa có hàng tương ứng) ---
  final DateTime? dateOfBirth;
  final String? nationality;
  final String? idCardNumber;
  final String? passportNumber;
  final String preferredLanguage;
  final String preferredCurrency;
  final bool marketingOptIn;

  /// Gu du lịch (Beach, Luxury, Adventure...). Rỗng nếu chưa chọn.
  final List<String> travelStyles;

  /// Tuỳ chọn bật/tắt từng loại thông báo (key -> bool). Rỗng = dùng mặc định.
  final Map<String, bool> notificationPrefs;

  // --- Loyalty (bảng LoyaltyAccount) ---
  final int loyaltyPoints;

  /// bronze | silver | gold | platinum.
  final String loyaltyTier;

  // --- Thống kê nhanh (server tính) ---
  final int tripsCount;
  final int reviewsCount;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatarUrl,
    required this.role,
    required this.status,
    this.emailVerifiedAt,
    this.dateOfBirth,
    this.nationality,
    this.idCardNumber,
    this.passportNumber,
    required this.preferredLanguage,
    required this.preferredCurrency,
    required this.marketingOptIn,
    this.travelStyles = const [],
    this.notificationPrefs = const {},
    this.loyaltyPoints = 0,
    this.loyaltyTier = 'bronze',
    this.tripsCount = 0,
    this.reviewsCount = 0,
  });

  bool get isEmailVerified => emailVerifiedAt != null;

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    phone,
    avatarUrl,
    role,
    status,
    emailVerifiedAt,
    dateOfBirth,
    nationality,
    idCardNumber,
    passportNumber,
    preferredLanguage,
    preferredCurrency,
    marketingOptIn,
    travelStyles,
    notificationPrefs,
    loyaltyPoints,
    loyaltyTier,
    tripsCount,
    reviewsCount,
  ];
}
