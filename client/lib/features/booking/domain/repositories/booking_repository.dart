import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import '../entities/checkout.dart';
import '../entities/paginated.dart';
import '../entities/booking.dart';
import '../entities/booking_status.dart';

/// Hợp đồng đặt phòng + thanh toán qua API. Domain khai báo, Data hiện thực.
abstract interface class BookingRepository {
  /// Tạo booking mới.
  ///
  /// KHÔNG gửi giá — server tự tính từ pricing rule của khách sạn. Client chỉ
  /// mô tả "muốn đặt gì", tiền là kết quả trả về.
  Future<Either<Failure, Booking>> create({
    required String hotelId,
    required String roomTypeId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int numGuests,
    String? specialRequests,
    PaymentMethod paymentMethod,
  });

  /// Danh sách booking của người dùng đang đăng nhập.
  Future<Either<Failure, Paginated<Booking>>> getMine({
    BookingStatus? status,
    int? page,
    int? limit,
    String? sortBy,
  });

  /// Chi tiết một booking (kèm `payments`). Đây là nguồn sự thật về trạng thái
  /// thanh toán — không tin query param mà cổng thanh toán redirect về.
  Future<Either<Failure, Booking>> getById(String bookingId);

  /// Huỷ booking. Chỉ gửi [reason]; tiền hoàn do server tự tính theo chính sách
  /// huỷ và trả về đúng nguồn đã thanh toán.
  Future<Either<Failure, Booking>> cancel({
    required String bookingId,
    String? reason,
  });

  /// Tạo link thanh toán VNPay để mở cổng.
  Future<Either<Failure, VnpayCheckout>> startVnpayCheckout(String bookingId);

  /// Tạo mã QR chuyển khoản SePay.
  Future<Either<Failure, SepayCheckout>> startSepayCheckout(String bookingId);

  /// Trừ ví cho booking. Server tự tính `min(số dư, còn thiếu)` nên không
  /// nhận số tiền từ client.
  Future<Either<Failure, WalletPaymentResult>> payWithWallet(String bookingId);
}
