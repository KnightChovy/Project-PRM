import '../../domain/entities/hotel_review.dart';

/// DTO của [HotelReview]: map JSON review công khai ↔ Entity.
///
/// Khớp `GET /reviews?hotelId=`:
/// `{ id, overallRating, cleanlinessRating, serviceRating, locationRating,
///    valueRating, title, content, createdAt, customer: { fullName } }`
class HotelReviewModel extends HotelReview {
  const HotelReviewModel({
    required super.id,
    required super.authorName,
    required super.overall,
    required super.cleanliness,
    required super.service,
    required super.locationRating,
    required super.value,
    required super.content,
    required super.createdAt,
    super.title,
  });

  factory HotelReviewModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'];
    return HotelReviewModel(
      id: json['id'] as String,
      authorName:
          customer is Map ? (customer['fullName'] as String? ?? 'Khách') : 'Khách',
      overall: _toInt(json['overallRating']),
      cleanliness: _toInt(json['cleanlinessRating']),
      service: _toInt(json['serviceRating']),
      locationRating: _toInt(json['locationRating']),
      value: _toInt(json['valueRating']),
      title: (json['title'] as String?)?.trim(),
      content: json['content'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime(2000),
    );
  }
}

int _toInt(Object? v) {
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}
