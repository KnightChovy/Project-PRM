import 'package:equatable/equatable.dart';

/// Một đánh giá CÔNG KHAI của khách cho một khách sạn (dùng ở màn Guest Reviews).
///
/// Khác [Review] (đánh giá "của tôi"): ở đây cần TÊN người đánh giá để hiển thị,
/// và không mang bookingId. Thuần Dart, không JSON.
class HotelReview extends Equatable {
  final String id;

  /// Tên người đánh giá (từ `customer.fullName`).
  final String authorName;

  /// Điểm tổng (1..5).
  final int overall;

  // Điểm theo tiêu chí (1..5) — dùng để tính trung bình từng mục.
  final int cleanliness;
  final int service;
  final int locationRating;
  final int value;

  final String? title;
  final String content;
  final DateTime createdAt;

  const HotelReview({
    required this.id,
    required this.authorName,
    required this.overall,
    required this.cleanliness,
    required this.service,
    required this.locationRating,
    required this.value,
    required this.content,
    required this.createdAt,
    this.title,
  });

  @override
  List<Object?> get props => [
        id,
        authorName,
        overall,
        cleanliness,
        service,
        locationRating,
        value,
        title,
        content,
        createdAt,
      ];
}
