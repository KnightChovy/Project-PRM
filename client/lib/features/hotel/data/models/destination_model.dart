import '../../domain/entities/destination.dart';

/// DTO của [Destination]: map JSON `GET /hotels/destinations` ↔ Entity.
/// Response: `[{ city, hotelCount, imageUrl }]`.
class DestinationModel extends Destination {
  const DestinationModel({
    required super.name,
    required super.hotelCount,
    required super.imageUrl,
  });

  factory DestinationModel.fromJson(Map<String, dynamic> json) =>
      DestinationModel(
        name: json['city'] as String? ?? '',
        hotelCount: (json['hotelCount'] as num?)?.toInt() ?? 0,
        imageUrl: json['imageUrl'] as String? ?? '',
      );
}
