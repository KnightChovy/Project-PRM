import 'package:smart_stay_ai/features/hotel/domain/entities/hotel.dart';

/// DTO của [Hotel] cho wishlist LOCAL (shared_preferences).
///
/// Khác model ở feature hotel (map JSON của API): đây là cách serialize/deserialize
/// ĐẦY ĐỦ một [Hotel] để lưu offline rồi dựng lại y nguyên khi mở app — không phụ
/// thuộc hình dạng response của server.
class WishlistHotelModel extends Hotel {
  const WishlistHotelModel({
    required super.id,
    required super.name,
    required super.location,
    required super.imageUrl,
    required super.rating,
    required super.reviewCount,
    required super.pricePerNight,
    super.oldPrice,
    super.description,
    super.amenities,
    super.images,
    super.checkIn,
    super.checkOut,
  });

  /// Bọc một [Hotel] bất kỳ để có thể `toJson`.
  factory WishlistHotelModel.from(Hotel h) => WishlistHotelModel(
        id: h.id,
        name: h.name,
        location: h.location,
        imageUrl: h.imageUrl,
        rating: h.rating,
        reviewCount: h.reviewCount,
        pricePerNight: h.pricePerNight,
        oldPrice: h.oldPrice,
        description: h.description,
        amenities: h.amenities,
        images: h.images,
        checkIn: h.checkIn,
        checkOut: h.checkOut,
      );

  factory WishlistHotelModel.fromJson(Map<String, dynamic> json) =>
      WishlistHotelModel(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        location: json['location'] as String? ?? '',
        imageUrl: json['imageUrl'] as String? ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
        pricePerNight: (json['pricePerNight'] as num?)?.toDouble() ?? 0,
        oldPrice: (json['oldPrice'] as num?)?.toDouble(),
        description: json['description'] as String? ?? '',
        amenities: _strList(json['amenities']),
        images: _strList(json['images']),
        checkIn: json['checkIn'] as String? ?? '02:00 PM',
        checkOut: json['checkOut'] as String? ?? '12:00 PM',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location,
        'imageUrl': imageUrl,
        'rating': rating,
        'reviewCount': reviewCount,
        'pricePerNight': pricePerNight,
        if (oldPrice != null) 'oldPrice': oldPrice,
        'description': description,
        'amenities': amenities,
        'images': images,
        'checkIn': checkIn,
        'checkOut': checkOut,
      };
}

List<String> _strList(Object? v) =>
    v is List ? v.whereType<String>().toList() : const [];
