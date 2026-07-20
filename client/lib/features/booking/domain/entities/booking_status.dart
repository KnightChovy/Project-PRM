/// Trạng thái vòng đời của một lượt đặt phòng.
///
/// Thuần Dart — việc ánh xạ sang chuỗi của API (`checked_in`, ...) là việc của
/// tầng Data, Domain không biết tới định dạng trên đường truyền.
enum BookingStatus {
  pending,
  confirmed,
  checkedIn,
  checkedOut,
  cancelled,
  noShow,
}

/// Phương thức thanh toán khi tạo booking.
enum PaymentMethod {
  /// Chuyển hướng sang cổng VNPay. Booking `pending`, giữ chỗ 15 phút.
  vnpay,

  /// Chuyển khoản qua QR SePay. Booking `pending`, giữ chỗ 30 phút.
  sepay,

  /// Trả tại quầy. Booking `confirmed` ngay, không có hold.
  cash,
}
