import 'package:equatable/equatable.dart';

/// Một loại phòng của khách sạn (Deluxe, Standard, Suite...). Thuần Dart.
class Room extends Equatable {
  final String id;
  final String name;
  final String bedType;
  final int sizeSqm;
  final int maxGuests;
  final String floor;
  final List<String> images;
  final List<String> amenities;
  final double pricePerNight;
  final double taxesAndFees;

  /// Mốc hủy miễn phí (vd "Jun 10"); null nếu không cho hủy miễn phí.
  final String? freeCancellationBefore;

  const Room({
    required this.id,
    required this.name,
    required this.bedType,
    required this.sizeSqm,
    required this.maxGuests,
    required this.floor,
    required this.images,
    required this.amenities,
    required this.pricePerNight,
    this.taxesAndFees = 0,
    this.freeCancellationBefore,
  });

  /// Tổng tiền = giá/đêm + thuế & phí.
  double get total => pricePerNight + taxesAndFees;

  @override
  List<Object?> get props => [
        id,
        name,
        bedType,
        sizeSqm,
        maxGuests,
        floor,
        images,
        amenities,
        pricePerNight,
        taxesAndFees,
        freeCancellationBefore,
      ];
}
