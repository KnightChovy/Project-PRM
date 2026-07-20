import 'package:smart_stay_ai/core/error/exceptions.dart';
import '../../domain/entities/booking_status.dart';

/// Ánh xạ [BookingStatus] <-> chuỗi của API. Chỉ tồn tại ở tầng Data —
/// Domain không biết booking được truyền đi dưới dạng `checked_in`.
const Map<String, BookingStatus> _fromApi = {
  'pending': BookingStatus.pending,
  'confirmed': BookingStatus.confirmed,
  'checked_in': BookingStatus.checkedIn,
  'checked_out': BookingStatus.checkedOut,
  'cancelled': BookingStatus.cancelled,
  'no_show': BookingStatus.noShow,
};

const Map<BookingStatus, String> _toApi = {
  BookingStatus.pending: 'pending',
  BookingStatus.confirmed: 'confirmed',
  BookingStatus.checkedIn: 'checked_in',
  BookingStatus.checkedOut: 'checked_out',
  BookingStatus.cancelled: 'cancelled',
  BookingStatus.noShow: 'no_show',
};

/// Ném [ServerException] khi gặp trạng thái lạ thay vì đoán bừa: hiển thị một
/// booking `cancelled` thành `pending` sẽ mời user đi thanh toán một chỗ đã mất.
BookingStatus bookingStatusFromApi(Object? value) {
  final status = _fromApi[value];
  if (status == null) {
    throw ServerException(
      message: 'Trạng thái booking không hợp lệ: $value',
    );
  }
  return status;
}

String bookingStatusToApi(BookingStatus status) => _toApi[status]!;

const Map<PaymentMethod, String> _paymentMethodToApi = {
  PaymentMethod.vnpay: 'vnpay',
  PaymentMethod.sepay: 'sepay',
  PaymentMethod.cash: 'cash',
};

String paymentMethodToApi(PaymentMethod method) => _paymentMethodToApi[method]!;
