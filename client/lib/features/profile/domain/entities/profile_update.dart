import 'package:equatable/equatable.dart';

/// Tập thay đổi gửi lên `PATCH /v1/users/me`.
///
/// Mọi field đều nullable với ý nghĩa **"không đụng tới"** — chỉ những field
/// khác null mới được đưa vào body. Backend bắt buộc body có tối thiểu 1 key
/// và từ chối key lạ, nên đừng thêm field mà API không khai báo
/// (`email`, `role`, `status`, `gender`, `address` đều KHÔNG hợp lệ).
///
/// Muốn xoá một field chữ thì truyền chuỗi rỗng — Joi phía server cho phép
/// `''` với phone/avatarUrl/nationality/idCardNumber/passportNumber.
class ProfileUpdate extends Equatable {
  final String? fullName;
  final String? phone;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final String? nationality;
  final String? idCardNumber;
  final String? passportNumber;

  /// Chỉ nhận `'vi'` hoặc `'en'`.
  final String? preferredLanguage;

  /// Chỉ nhận `'VND'` hoặc `'USD'`.
  final String? preferredCurrency;

  final bool? marketingOptIn;

  const ProfileUpdate({
    this.fullName,
    this.phone,
    this.avatarUrl,
    this.dateOfBirth,
    this.nationality,
    this.idCardNumber,
    this.passportNumber,
    this.preferredLanguage,
    this.preferredCurrency,
    this.marketingOptIn,
  });

  /// Không có gì để gửi → tránh gọi API và dính lỗi 400 "min 1 key".
  bool get isEmpty =>
      fullName == null &&
      phone == null &&
      avatarUrl == null &&
      dateOfBirth == null &&
      nationality == null &&
      idCardNumber == null &&
      passportNumber == null &&
      preferredLanguage == null &&
      preferredCurrency == null &&
      marketingOptIn == null;

  @override
  List<Object?> get props => [
    fullName,
    phone,
    avatarUrl,
    dateOfBirth,
    nationality,
    idCardNumber,
    passportNumber,
    preferredLanguage,
    preferredCurrency,
    marketingOptIn,
  ];
}
