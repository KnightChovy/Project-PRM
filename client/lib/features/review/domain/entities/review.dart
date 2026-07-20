import 'package:equatable/equatable.dart';

/// Một đánh giá (review) của khách cho một resort/khách sạn. Thuần Dart.
class Review extends Equatable {
  final String id;
  final String hotelName;
  final String location;

  /// Điểm tổng (1..5). 0 nghĩa là chưa chấm.
  final int overall;

  // Các tiêu chí chi tiết (1..5), khớp với thiết kế Stitch.
  final int cleanliness;
  final int locationRating;
  final int service;
  final int value;

  final String comment;
  final bool isAnonymous;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.hotelName,
    required this.location,
    required this.overall,
    required this.cleanliness,
    required this.locationRating,
    required this.service,
    required this.value,
    required this.comment,
    required this.isAnonymous,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        hotelName,
        location,
        overall,
        cleanliness,
        locationRating,
        service,
        value,
        comment,
        isAnonymous,
        createdAt,
      ];
}
