import 'package:smart_stay_ai/features/booking/domain/entities/booking_status.dart';
import 'package:smart_stay_ai/features/hotel/domain/entities/hotel.dart';
import 'package:smart_stay_ai/features/rooms/domain/entities/room.dart';

/// Dữ liệu nháp gom dần qua các bước đặt phòng (chi tiết -> khách -> thanh toán).
/// Là object bất biến; mỗi bước tạo bản mới bằng [copyWith].
class BookingDraft {
  final Hotel hotel;
  final Room room;
  final DateTime checkIn;
  final DateTime checkOut;
  final int adults;
  final int children;
  final String specialRequests;
  // Thông tin khách
  final bool bookingForSelf;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String nationality;
  final String arrivalTime;
  final PaymentMethod paymentMethod;

  const BookingDraft({
    required this.hotel,
    required this.room,
    required this.checkIn,
    required this.checkOut,
    this.adults = 2,
    this.children = 0,
    this.specialRequests = '',
    this.bookingForSelf = true,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.nationality = '',
    this.arrivalTime = '',
    this.paymentMethod = PaymentMethod.vnpay,
  });

  int get nights => checkOut.difference(checkIn).inDays;

  /// API chỉ nhận MỘT con số khách (`numGuests`), không tách người lớn/trẻ em.
  /// Form vẫn cho tách để giữ trải nghiệm, nhưng gửi lên là tổng.
  int get totalGuests => adults + children;

  String get guestName => '$firstName $lastName'.trim();

  double get subtotal => room.pricePerNight * nights;
  double get taxes => subtotal * 0.10;

  /// Đặt từ 2 đêm trở lên được giảm 10% (loyalty).
  double get discount => nights >= 2 ? subtotal * 0.10 : 0;
  double get total => subtotal + taxes - discount;

  BookingDraft copyWith({
    DateTime? checkIn,
    DateTime? checkOut,
    int? adults,
    int? children,
    String? specialRequests,
    bool? bookingForSelf,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? nationality,
    String? arrivalTime,
    PaymentMethod? paymentMethod,
  }) {
    return BookingDraft(
      hotel: hotel,
      room: room,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      specialRequests: specialRequests ?? this.specialRequests,
      bookingForSelf: bookingForSelf ?? this.bookingForSelf,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      nationality: nationality ?? this.nationality,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
