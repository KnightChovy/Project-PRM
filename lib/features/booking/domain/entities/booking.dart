import 'package:equatable/equatable.dart';

/// Một lượt đặt phòng đã hoàn tất. Thuần Dart.
class Booking extends Equatable {
  final String id;
  final String code; // mã hiển thị, vd 'SS-782910'
  final String hotelName;
  final String location;
  final String roomName;
  final String imageUrl;
  final String guestName;
  final DateTime checkIn;
  final DateTime checkOut;
  final String checkInTime;
  final String checkOutTime;
  final int adults;
  final int children;
  final double subtotal;
  final double taxes;
  final double discount;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.code,
    required this.hotelName,
    required this.location,
    required this.roomName,
    required this.imageUrl,
    required this.guestName,
    required this.checkIn,
    required this.checkOut,
    required this.checkInTime,
    required this.checkOutTime,
    required this.adults,
    required this.children,
    required this.subtotal,
    required this.taxes,
    required this.discount,
    required this.createdAt,
  });

  int get nights => checkOut.difference(checkIn).inDays;
  int get totalGuests => adults + children;
  double get total => subtotal + taxes - discount;

  @override
  List<Object?> get props => [
        id,
        code,
        hotelName,
        location,
        roomName,
        imageUrl,
        guestName,
        checkIn,
        checkOut,
        checkInTime,
        checkOutTime,
        adults,
        children,
        subtotal,
        taxes,
        discount,
        createdAt,
      ];
}
