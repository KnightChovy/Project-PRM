import 'package:equatable/equatable.dart';

/// Một điểm đến phổ biến (gom khách sạn theo thành phố) — dùng ở Home.
class Destination extends Equatable {
  /// Tên hiển thị (chính là thành phố).
  final String name;
  final int hotelCount;
  final String imageUrl;

  const Destination({
    required this.name,
    required this.hotelCount,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [name, hotelCount, imageUrl];
}
