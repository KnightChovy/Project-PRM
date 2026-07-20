import 'package:smart_stay_ai/features/hotel/domain/entities/hotel.dart';

/// Cách sắp xếp danh sách khách sạn (khớp mục "Sort By" trong design).
enum HotelSortBy {
  recommended('Recommended'),
  priceLowToHigh('Price: Low to High'),
  priceHighToLow('Price: High to Low'),
  topRated('Top Rated');

  const HotelSortBy(this.label);
  final String label;
}

/// Bộ lọc + sắp xếp do màn "Filter & Sort" tạo ra và màn Search áp dụng.
/// Immutable — đổi giá trị bằng [copyWith].
class HotelFilter {
  final HotelSortBy sortBy;
  final double minPrice;
  final double maxPrice;

  /// Số sao tối thiểu (0 = không lọc).
  final int minStars;

  const HotelFilter({
    this.sortBy = HotelSortBy.recommended,
    this.minPrice = priceFloor,
    this.maxPrice = priceCeil,
    this.minStars = 0,
  });

  static const double priceFloor = 0;
  static const double priceCeil = 1000;

  HotelFilter copyWith({
    HotelSortBy? sortBy,
    double? minPrice,
    double? maxPrice,
    int? minStars,
  }) {
    return HotelFilter(
      sortBy: sortBy ?? this.sortBy,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minStars: minStars ?? this.minStars,
    );
  }

  /// Đếm số tiêu chí đang khác mặc định — để hiện badge trên nút Filter.
  int get activeCount {
    var n = 0;
    if (sortBy != HotelSortBy.recommended) n++;
    if (minPrice > priceFloor || maxPrice < priceCeil) n++;
    if (minStars > 0) n++;
    return n;
  }

  /// Áp bộ lọc + sắp xếp lên danh sách khách sạn.
  List<Hotel> apply(List<Hotel> hotels) {
    final filtered = hotels.where((h) {
      final inPrice =
          h.pricePerNight >= minPrice && h.pricePerNight <= maxPrice;
      final enoughStars = h.rating >= minStars;
      return inPrice && enoughStars;
    }).toList();

    switch (sortBy) {
      case HotelSortBy.priceLowToHigh:
        filtered.sort((a, b) => a.pricePerNight.compareTo(b.pricePerNight));
      case HotelSortBy.priceHighToLow:
        filtered.sort((a, b) => b.pricePerNight.compareTo(a.pricePerNight));
      case HotelSortBy.topRated:
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
      case HotelSortBy.recommended:
        break; // giữ thứ tự gốc
    }
    return filtered;
  }
}
