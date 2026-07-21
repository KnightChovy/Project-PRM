import 'package:equatable/equatable.dart';
import 'package:smart_stay_ai/core/utils/money.dart';
import 'booking_status.dart';

/// Kết quả khởi tạo thanh toán VNPay — chỉ có link để mở cổng thanh toán.
class VnpayCheckout extends Equatable {
  final String paymentUrl;

  const VnpayCheckout({required this.paymentUrl});

  @override
  List<Object?> get props => [paymentUrl];
}

/// Kết quả khởi tạo thanh toán SePay (chuyển khoản QR).
///
/// Không có callback về app — ngân hàng báo qua webhook server-to-server, nên
/// Presentation phải poll chi tiết booking cho tới khi `confirmed` hoặc quá
/// [expiresAt].
class SepayCheckout extends Equatable {
  final String qrUrl;

  /// Nội dung chuyển khoản — khách phải ghi ĐÚNG chuỗi này.
  final String transferContent;

  final Money amount;
  final String accountNumber;
  final String bankCode;
  final DateTime expiresAt;

  const SepayCheckout({
    required this.qrUrl,
    required this.transferContent,
    required this.amount,
    required this.accountNumber,
    required this.bankCode,
    required this.expiresAt,
  });

  @override
  List<Object?> get props => [
        qrUrl,
        transferContent,
        amount,
        accountNumber,
        bankCode,
        expiresAt,
      ];
}

/// Kết quả trừ ví. Ví có thể chỉ trả được một phần.
class WalletPaymentResult extends Equatable {
  final String bookingCode;

  /// Số tiền ví đã trừ (server tự tính `min(số dư, còn thiếu)`).
  final Money walletApplied;

  /// Còn thiếu bao nhiêu. `0` nghĩa là ví đã trả đủ.
  final Money remainingToPay;

  final BookingStatus bookingStatus;
  final String? voucherCode;

  /// Số dư ví còn lại sau khi trừ.
  final Money walletBalance;

  const WalletPaymentResult({
    required this.bookingCode,
    required this.walletApplied,
    required this.remainingToPay,
    required this.bookingStatus,
    required this.walletBalance,
    this.voucherCode,
  });

  /// Ví trả đủ — không cần gọi tiếp vnpay/sepay.
  bool get isFullyPaid => remainingToPay.isZero;

  @override
  List<Object?> get props => [
        bookingCode,
        walletApplied,
        remainingToPay,
        bookingStatus,
        voucherCode,
        walletBalance,
      ];
}
