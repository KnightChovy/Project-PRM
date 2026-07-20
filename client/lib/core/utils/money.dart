import 'package:equatable/equatable.dart';

/// Số tiền do API trả về.
///
/// Backend serialize Decimal thành **chuỗi** (`"1130000"`), nên ta giữ nguyên
/// chuỗi gốc làm nguồn sự thật và chỉ parse khi cần tính/hiển thị. Không cộng
/// trừ trực tiếp trên [raw].
class Money extends Equatable {
  final String raw;

  const Money(this.raw);

  static const Money zero = Money('0');

  /// Đọc từ JSON: API trả string, nhưng có endpoint trả number (vd SePay
  /// `amount`), nên nhận cả hai.
  factory Money.fromJson(Object? value) {
    if (value == null) return Money.zero;
    return Money(value.toString());
  }

  double get amount => double.tryParse(raw) ?? 0;

  /// VND không dùng phần lẻ — dùng khi cần số nguyên (vd nội dung chuyển khoản).
  int get amountAsInt => amount.round();

  bool get isZero => amount == 0;

  @override
  String toString() => raw;

  @override
  List<Object?> get props => [raw];
}
