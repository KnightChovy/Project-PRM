import 'package:equatable/equatable.dart';

/// Một lượt đặt phòng đã tạo. Thuần Dart.
class Booking extends Equatable {
  final String id;
  final String roomName;
  final String imageUrl;
  final double pricePerNight;
  final int nights;
  final int guests;
  final double taxesAndFees;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.roomName,
    required this.imageUrl,
    required this.pricePerNight,
    required this.nights,
    required this.guests,
    required this.taxesAndFees,
    required this.createdAt,
  });

  /// Tổng tiền = giá/đêm × số đêm + thuế & phí.
  double get total => pricePerNight * nights + taxesAndFees;

  @override
  List<Object?> get props => [
        id,
        roomName,
        imageUrl,
        pricePerNight,
        nights,
        guests,
        taxesAndFees,
        createdAt,
      ];
}
