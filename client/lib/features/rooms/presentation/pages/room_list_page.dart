import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_stay_ai/core/router/app_router.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';
import 'package:smart_stay_ai/core/utils/amenity_icons.dart';
import 'package:smart_stay_ai/core/widgets/app_network_image.dart';
import 'package:smart_stay_ai/features/hotel/domain/entities/hotel.dart';
import 'package:smart_stay_ai/features/rooms/domain/entities/room.dart';

/// Trang danh sách các loại phòng (Deluxe, Standard, Suite...).
/// Chạm vào 1 phòng -> mở [RoomDetailPage] để xem chi tiết & đặt.
///
/// NOTE: dùng dữ liệu mẫu [_demoRooms]. Khi có backend, lấy danh sách phòng
/// theo hotelId qua UseCase + Notifier.
class RoomListPage extends StatelessWidget {
  const RoomListPage({super.key, required this.hotel});

  final Hotel hotel;

  void _openRoom(BuildContext context, Room room) {
    context.push(AppRoutes.roomDetail, extra: (hotel, room));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Available Rooms',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        itemCount: _demoRooms.length,
        separatorBuilder: (_, _) => const SizedBox(height: 20),
        itemBuilder: (_, i) {
          final room = _demoRooms[i];
          return _RoomCard(
            room: room,
            onTap: () => _openRoom(context, room),
          );
        },
      ),
    );
  }
}

/// Thẻ 1 loại phòng: ảnh + tên + giá + thông tin + tiện ích.
class _RoomCard extends StatelessWidget {
  const _RoomCard({required this.room, required this.onTap});

  final Room room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 160,
              width: double.infinity,
              child: AppNetworkImage(url: room.images.first),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          room.name,
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '\$${room.pricePerNight.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.goldDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      _meta(Icons.king_bed_outlined, room.bedType),
                      const Text('·', style: TextStyle(color: AppColors.textSecondary)),
                      Text('${room.sizeSqm} sqm',
                          style: const TextStyle(color: AppColors.textSecondary)),
                      const Text('·', style: TextStyle(color: AppColors.textSecondary)),
                      _meta(Icons.group_outlined, '${room.maxGuests} Guests'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Tiện ích phòng: hiện tối đa 4 cái cho gọn.
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: room.amenities
                        .take(4)
                        .map((a) => _AmenityChip(label: a))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: onTap,
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Text(
                          'Select Room',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _AmenityChip extends StatelessWidget {
  const _AmenityChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(amenityIcon(label), size: 16, color: AppColors.goldDark),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

/// Dữ liệu mẫu các loại phòng — thay bằng dữ liệu thật từ API khi sẵn sàng.
const _demoRooms = <Room>[
  Room(
    id: 'r1',
    name: 'Deluxe Ocean View',
    bedType: '1 King Bed',
    sizeSqm: 45,
    maxGuests: 2,
    floor: '5th Floor',
    images: [
      'https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800',
      'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800',
    ],
    amenities: ['King Bed', 'Sea View', 'Bathtub', 'Smart TV', 'Minibar', 'Balcony'],
    pricePerNight: 450,
    taxesAndFees: 45,
    freeCancellationBefore: 'Jun 10',
  ),
  Room(
    id: 'r2',
    name: 'Standard Garden View',
    bedType: '1 Queen Bed',
    sizeSqm: 30,
    maxGuests: 2,
    floor: '2nd Floor',
    images: [
      'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=800',
      'https://images.unsplash.com/photo-1566665797739-1674de7a421a?w=800',
    ],
    amenities: ['Queen Bed', 'Smart TV', 'Minibar', 'WiFi'],
    pricePerNight: 250,
    taxesAndFees: 25,
    freeCancellationBefore: 'Jun 12',
  ),
  Room(
    id: 'r3',
    name: 'Premier Suite',
    bedType: '1 King Bed + Sofa',
    sizeSqm: 70,
    maxGuests: 4,
    floor: '8th Floor',
    images: [
      'https://images.unsplash.com/photo-1591088398332-8a7791972843?w=800',
      'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800',
    ],
    amenities: ['King Bed', 'Sea View', 'Bathtub', 'Smart TV', 'Minibar', 'Balcony'],
    pricePerNight: 680,
    taxesAndFees: 68,
    freeCancellationBefore: 'Jun 8',
  ),
];
