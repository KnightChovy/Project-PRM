import '../../domain/entities/review.dart';

/// DTO của [Review]: nơi DUY NHẤT được phép map JSON ↔ Entity.
class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
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

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        id: json['id'] as String,
        hotelName: json['hotelName'] as String,
        location: json['location'] as String,
        overall: (json['overall'] as num).toInt(),
        cleanliness: (json['cleanliness'] as num).toInt(),
        locationRating: (json['locationRating'] as num).toInt(),
        service: (json['service'] as num).toInt(),
        value: (json['value'] as num).toInt(),
        comment: json['comment'] as String,
        isAnonymous: json['isAnonymous'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'hotelName': hotelName,
        'location': location,
        'overall': overall,
        'cleanliness': cleanliness,
        'locationRating': locationRating,
        'service': service,
        'value': value,
        'comment': comment,
        'isAnonymous': isAnonymous,
        'createdAt': createdAt.toIso8601String(),
      };
}
