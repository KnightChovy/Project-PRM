import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import '../../domain/entities/checkout.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_status.dart';
import '../../domain/usecases/cancel_booking.dart';
import '../../domain/usecases/create_booking.dart';
import '../../domain/usecases/get_booking_detail.dart';
import '../../domain/usecases/pay_with_wallet.dart';
import '../../domain/usecases/start_sepay_checkout.dart';
import '../../domain/usecases/start_vnpay_checkout.dart';

enum RequestStatus { initial, loading, success, error }

/// Điều phối luồng đặt phòng + thanh toán của MỘT booking.
///
/// Chỉ gọi UseCase, không chạm repository/Dio. Mọi điều hướng và snackbar do
/// widget làm sau khi `await` các hàm ở đây.
class BookingNotifier extends ChangeNotifier {
  final CreateBooking createBooking;
  final GetBookingDetail getBookingDetail;
  final StartVnpayCheckout startVnpayCheckout;
  final StartSepayCheckout startSepayCheckout;
  final PayWithWallet payWithWallet;
  final CancelBooking cancelBooking;

  BookingNotifier({
    required this.createBooking,
    required this.getBookingDetail,
    required this.startVnpayCheckout,
    required this.startSepayCheckout,
    required this.payWithWallet,
    required this.cancelBooking,
  });

  /// Nhịp poll SePay — không có callback về app nên phải tự hỏi lại server.
  static const Duration sepayPollInterval = Duration(seconds: 5);

  RequestStatus status = RequestStatus.initial;
  Booking? booking;
  SepayCheckout? sepayCheckout;
  WalletPaymentResult? walletResult;
  String? errorMessage;

  Timer? _pollTimer;
  bool _disposed = false;

  bool get isLoading => status == RequestStatus.loading;

  /// Còn bao lâu thì mất chỗ. `null` nếu booking không có hold (trả tiền mặt).
  Duration? get remainingHold => booking?.remainingHold(DateTime.now());

  /// Tạo booking. Trả về booking vừa tạo, hoặc `null` nếu lỗi
  /// (đọc [errorMessage] để hiển thị — message từ server đã là tiếng Việt).
  Future<Booking?> create(CreateBookingParams params) async {
    _begin();
    final result = await createBooking(params);
    return _settle(result, onSuccess: (r) => booking = r);
  }

  /// Lấy link cổng VNPay. Widget tự mở URL trả về.
  Future<String?> beginVnpayCheckout() async {
    final id = _requireBookingId();
    if (id == null) return null;

    _begin();
    final result = await startVnpayCheckout(id);
    return _settle(result.map((checkout) => checkout.paymentUrl));
  }


  /// Lấy QR SePay và bắt đầu poll trạng thái booking cho tới khi `confirmed`
  /// hoặc quá hạn.
  Future<SepayCheckout?> beginSepayCheckout() async {
    final id = _requireBookingId();
    if (id == null) return null;

    _begin();
    final result = await startSepayCheckout(id);
    final checkout = _settle(result, onSuccess: (c) => sepayCheckout = c);

    if (checkout != null) _startSepayPolling(id, checkout.expiresAt);
    return checkout;
  }

  /// Trừ ví. Nếu ví không đủ, booking vẫn `pending` và
  /// [WalletPaymentResult.remainingToPay] là phần phải trả tiếp qua VNPay/SePay.
  Future<WalletPaymentResult?> payFromWallet() async {
    final id = _requireBookingId();
    if (id == null) return null;

    _begin();
    final result = await payWithWallet(id);
    final wallet = _settle(result, onSuccess: (w) => walletResult = w);

    // Ví trả đủ -> booking đã đổi trạng thái, kéo bản mới nhất về.
    if (wallet != null && wallet.isFullyPaid) await refresh();
    return wallet;
  }

  /// Kéo lại chi tiết booking từ server. Đây là nguồn sự thật về trạng thái
  /// thanh toán — không tin query param mà cổng thanh toán redirect về.
  Future<Booking?> refresh([String? bookingId]) async {
    final id = bookingId ?? booking?.id;
    if (id == null) return null;

    final result = await getBookingDetail(id);
    return result.fold(
      (failure) {
        errorMessage = failure.message;
        _notify();
        return null;
      },
      (r) {
        booking = r;
        status = RequestStatus.success;
        _notify();
        return r;
      },
    );
  }

  /// Huỷ booking. [bookingId] cho phép huỷ một booking đến từ danh sách
  /// (màn Cancel nhận booking qua route chứ không tự tạo).
  Future<Booking?> cancel({
    required RefundDestination destination,
    String? reason,
    String? bookingId,
  }) async {
    final id = bookingId ?? _requireBookingId();
    if (id == null) return null;

    _begin();
    final result = await cancelBooking(
      CancelBookingParams(
        bookingId: id,
        destination: destination,
        reason: reason,
      ),
    );
    return _settle(result, onSuccess: (r) => booking = r);
  }

  /// Dừng poll khi rời màn thanh toán.
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void _startSepayPolling(String bookingId, DateTime expiresAt) {
    stopPolling();
    _pollTimer = Timer.periodic(sepayPollInterval, (timer) async {
      if (_disposed) {
        timer.cancel();
        return;
      }
      if (DateTime.now().isAfter(expiresAt)) {
        stopPolling();
        return;
      }
      final updated = await refresh(bookingId);
      if (updated != null && updated.status != BookingStatus.pending) {
        stopPolling();
      }
    });
  }

  String? _requireBookingId() {
    final id = booking?.id;
    if (id == null) {
      errorMessage = 'Chưa có booking nào để thanh toán';
      status = RequestStatus.error;
      _notify();
    }
    return id;
  }

  void _begin() {
    status = RequestStatus.loading;
    errorMessage = null;
    _notify();
  }

  /// Gộp phần "đổi status + notify" cho mọi thao tác, tránh lặp `fold` 6 lần.
  /// Trả `null` khi thất bại; lý do nằm ở [errorMessage].
  T? _settle<T>(
    Either<Failure, T> result, {
    void Function(T value)? onSuccess,
  }) {
    return result.fold(
      (failure) {
        status = RequestStatus.error;
        errorMessage = failure.message;
        _notify();
        return null;
      },
      (value) {
        onSuccess?.call(value);
        status = RequestStatus.success;
        _notify();
        return value;
      },
    );
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    stopPolling();
    super.dispose();
  }
}
