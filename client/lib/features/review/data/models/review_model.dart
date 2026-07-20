import '../../domain/entities/review.dart';

/// DTO của [Review]: nơi DUY NHẤT map JSON ↔ Entity.
///
/// Khớp với review trả về từ API SmartStay:
/// `{ id, bookingId, overallRating, cleanlinessRating, serviceRating,
///    locationRating, valueRating, content, title, createdAt,
///    hotel: { name } }` (hotel chỉ có ở GET /reviews/me).
class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.bookingId,
    required super.hotelName,
    required super.location,
    required super.overall,
    required super.cleanliness,
    required super.locationRating,
    required super.service,
    required super.value,
    required super.comment,
    required super.isAnonymous,
    required super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final hotel = json['hotel'];
    return ReviewModel(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String? ?? '',
      hotelName: hotel is Map ? (hotel['name'] as String? ?? '') : '',
      location: '', // API review không có trường location riêng
      overall: (json['overallRating'] as num).toInt(),
      cleanliness: (json['cleanlinessRating'] as num).toInt(),
      locationRating: (json['locationRating'] as num).toInt(),
      service: (json['serviceRating'] as num).toInt(),
      value: (json['valueRating'] as num).toInt(),
      comment: json['content'] as String? ?? '',
      isAnonymous: false, // API chưa hỗ trợ đánh giá ẩn danh
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
