import 'package:smart_stay_ai/core/utils/money.dart';
import '../../domain/entities/checkout.dart';
import 'json_reader.dart';
import 'booking_status_mapper.dart';

class VnpayCheckoutModel extends VnpayCheckout {
  const VnpayCheckoutModel({required super.paymentUrl});

  factory VnpayCheckoutModel.fromJson(Map<String, dynamic> json) {
    return VnpayCheckoutModel(paymentUrl: json.requireString('paymentUrl'));
  }
}

class SepayCheckoutModel extends SepayCheckout {
  const SepayCheckoutModel({
    required super.qrUrl,
    required super.transferContent,
    required super.amount,
    required super.accountNumber,
    required super.bankCode,
    required super.expiresAt,
  });

  factory SepayCheckoutModel.fromJson(Map<String, dynamic> json) {
    return SepayCheckoutModel(
      qrUrl: json.requireString('qrUrl'),
      // Sai nội dung CK là tiền không khớp được booking -> bắt buộc phải có.
      transferContent: json.requireString('transferContent'),
      // Riêng endpoint này trả `amount` dạng number chứ không phải string.
      amount: Money.fromJson(json['amount']),
      accountNumber: json.requireString('accountNumber'),
      bankCode: json.requireString('bankCode'),
      expiresAt: json.requireLocalDate('expiresAt'),
    );
  }
}

class WalletPaymentResultModel extends WalletPaymentResult {
  const WalletPaymentResultModel({
    required super.bookingCode,
    required super.walletApplied,
    required super.remainingToPay,
    required super.bookingStatus,
    required super.walletBalance,
    super.voucherCode,
  });

  factory WalletPaymentResultModel.fromJson(Map<String, dynamic> json) {
    return WalletPaymentResultModel(
      bookingCode: json.requireString('bookingCode'),
      walletApplied: Money.fromJson(json['walletApplied']),
      remainingToPay: Money.fromJson(json['remainingToPay']),
      bookingStatus: bookingStatusFromApi(json['bookingStatus']),
      walletBalance: Money.fromJson(json['walletBalance']),
      voucherCode: json.readString('voucherCode'),
    );
  }
}
