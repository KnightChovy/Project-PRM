import 'money.dart';

/// Định dạng tiền Việt: `1130000` -> `1.130.000 ₫`.
///
/// Tự nhóm chữ số thay vì dùng `intl` để khỏi thêm phụ thuộc chỉ cho một hàm.
String formatVnd(Money money) => '${_group(money.amountAsInt)} ₫';

String formatVndAmount(num amount) => '${_group(amount.round())} ₫';

String _group(int value) {
  final isNegative = value < 0;
  final digits = value.abs().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    // Chèn dấu chấm mỗi 3 chữ số tính từ phải sang.
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }

  return isNegative ? '-$buffer' : buffer.toString();
}
