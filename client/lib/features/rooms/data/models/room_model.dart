import '../../domain/entities/room.dart';

/// DTO của [Room]: nơi DUY NHẤT map JSON ↔ Entity.
///
/// Khớp response `RoomType` của API:
///  - `GET /hotels/:id/room-types`            → [ { ...cột room_type, images:[{url}], amenities:[{amenity:{name}}] } ]
///  - `GET /hotels/:id/room-types/:roomTypeId` → { ...như trên, kèm hotel tối giản }
///
/// RoomType KHÔNG có "floor" (tầng thuộc phòng vật lý) → dùng `viewType` làm mô
/// tả phụ. Thuế/phí theo kỳ ở chỉ có khi truyền ngày → để 0 ở danh sách.
class RoomModel extends Room {
  const RoomModel({
    required super.id,
    required super.name,
    required super.bedType,
    required super.sizeSqm,
    required super.maxGuests,
    required super.floor,
    required super.images,
    required super.amenities,
    required super.pricePerNight,
    super.taxesAndFees,
    super.freeCancellationBefore,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    final images = _urls(json['images']);
    return RoomModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Room',
      bedType: _str(json['bedType'], fallback: 'Standard'),
      sizeSqm: _toDouble(json['areaSqm']).round(),
      maxGuests: (json['maxOccupancy'] as num?)?.toInt() ?? 2,
      // RoomType không có tầng → mượn viewType làm mô tả phụ.
      floor: _str(json['viewType'], fallback: ''),
      // Trang danh sách dùng images.first → luôn đảm bảo có ít nhất 1 ảnh.
      images: images.isNotEmpty ? images : const [_kRoomImageFallback],
      amenities: _amenityNames(json['amenities']),
      pricePerNight: _toDouble(json['basePrice']),
    );
  }
}

/// Ảnh dự phòng khi loại phòng chưa có ảnh (tránh `images.first` ném lỗi).
const String _kRoomImageFallback =
    'https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800';

/// Prisma Decimal có thể về dạng String hoặc number → chuẩn hoá về double.
double _toDouble(Object? v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}

String _str(Object? v, {required String fallback}) {
  final s = (v as String?)?.trim();
  return (s == null || s.isEmpty) ? fallback : s;
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

/// amenities: [{ amenity: { name } }] → ['WiFi', 'Minibar', ...]
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
