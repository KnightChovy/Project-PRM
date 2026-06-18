import 'package:equatable/equatable.dart';

/// Thông tin một khách sạn — dùng chung cho danh sách, wishlist và trang chi tiết.
/// Thuần Dart, KHÔNG có fromJson/toJson (việc đó để Model ở tầng Data lo).
class Hotel extends Equatable {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final double pricePerNight;

  /// Giá cũ (gạch ngang) khi đang giảm giá; null nếu không giảm.
  final double? oldPrice;

  final String description;
  final List<String> amenities;

  /// Bộ ảnh cho carousel ở trang chi tiết. Có thể để trống.
  final List<String> images;

  final String checkIn;
  final String checkOut;

  const Hotel({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.pricePerNight,
    this.oldPrice,
    this.description = '',
    this.amenities = const [],
    this.images = const [],
    this.checkIn = '02:00 PM',
    this.checkOut = '12:00 PM',
  });

  bool get hasDiscount => oldPrice != null && oldPrice! > pricePerNight;

  /// Danh sách ảnh để hiển thị carousel — nếu chưa có ảnh riêng thì dùng [imageUrl].
  List<String> get gallery => images.isNotEmpty ? images : [imageUrl];

  @override
  List<Object?> get props => [
        id,
        name,
        location,
        imageUrl,
        rating,
        reviewCount,
        pricePerNight,
        oldPrice,
        description,
        amenities,
        images,
        checkIn,
        checkOut,
      ];
}
