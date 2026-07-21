import '../../domain/entities/hotel.dart';

/// DTO của [Hotel]: nơi DUY NHẤT map JSON ↔ Entity.
///
/// Khớp cả 2 dạng response của API:
///  - `GET /hotels`     → { ...cột hotel, images:[primary], minPrice }
///  - `GET /hotels/:id` → { ...cột hotel, images:[...], amenities:[{amenity:{name}}], roomTypes:[{basePrice}] }
///
/// API hotel KHÔNG trả điểm review → dùng `starRating` làm rating, reviewCount = 0.
class HotelModel extends Hotel {
  const HotelModel({
    required super.id,
    required super.name,
    required super.location,
    required super.imageUrl,
    required super.rating,
    required super.reviewCount,
    required super.pricePerNight,
    super.description,
    super.amenities,
    super.images,
    super.checkIn,
    super.checkOut,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    final images = _urls(json['images']);
    final locationParts = [json['address'], json['city']]
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty);

    return HotelModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      location: locationParts.join(', '),
      imageUrl: images.isNotEmpty ? images.first : '',
      rating: _toDouble(json['starRating']),
      reviewCount: 0,
      pricePerNight: _price(json),
      description: json['description'] as String? ?? '',
      amenities: _amenityNames(json['amenities']),
      images: images,
      checkIn: json['checkInTime'] as String? ?? '02:00 PM',
      checkOut: json['checkOutTime'] as String? ?? '12:00 PM',
    );
  }
}

/// Prisma Decimal có thể về dạng String hoặc number → chuẩn hoá về double.
double _toDouble(Object? v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}

/// Giá "từ": `minPrice` (search) hoặc basePrice thấp nhất trong roomTypes (detail).
double _price(Map<String, dynamic> json) {
  if (json['minPrice'] != null) return _toDouble(json['minPrice']);
  final rts = json['roomTypes'];
  if (rts is List && rts.isNotEmpty) {
    final prices = rts
        .whereType<Map>()
        .map((rt) => _toDouble(rt['basePrice']))
        .where((p) => p > 0);
    if (prices.isNotEmpty) return prices.reduce((a, b) => a < b ? a : b);
  }
  return 0;
}

List<String> _urls(Object? v) {
  if (v is List) {
    return v
        .whereType<Map>()
        .map((e) => e['url'] as String? ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }
  return const [];
}

/// amenities: [{ amenity: { name } }] → ['WiFi', 'Pool', ...]
List<String> _amenityNames(Object? v) {
  if (v is List) {
    return v
        .whereType<Map>()
        .map((e) {
          final a = e['amenity'];
          return a is Map ? (a['name'] as String? ?? '') : '';
        })
        .where((s) => s.isNotEmpty)
        .toList();
  }
  return const [];
}
