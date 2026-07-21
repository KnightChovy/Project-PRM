import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_stay_ai/core/di/injection.dart';
import 'package:smart_stay_ai/core/router/app_router.dart';
import 'package:smart_stay_ai/core/session/app_session.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';
import 'package:smart_stay_ai/core/widgets/sign_in_required_sheet.dart';
import 'package:smart_stay_ai/core/utils/amenity_icons.dart';
import 'package:smart_stay_ai/core/widgets/app_network_image.dart';
import 'package:smart_stay_ai/features/hotel/domain/entities/hotel.dart';
import 'package:smart_stay_ai/features/rooms/domain/entities/room.dart';

/// Trang chi tiết một phòng. Nhận [hotel] + [room] để hiển thị & bắt đầu đặt.
class RoomDetailPage extends StatelessWidget {
  const RoomDetailPage({super.key, required this.hotel, required this.room});

  final Hotel hotel;
  final Room room;

  /// Đặt phòng cần tài khoản (booking gắn với user phía server).
  ///
  /// Mời đăng nhập ngay tại đây bằng bottom sheet thay vì để router đá sang màn
  /// Login: khách xem tới bước này rồi mà bị nhảy nguyên trang là mất phòng
  /// đang chọn, quay lại phải dò từ đầu.
  Future<void> _startBooking(BuildContext context) async {
    if (!sl<AppSession>().isSignedIn) {
      await showSignInRequiredSheet(
        context,
        message: 'Đăng nhập để đặt ${room.name} và quản lý chuyến đi của bạn.',
      );
      return;
    }
    context.push(AppRoutes.bookingDetails, extra: (hotel, room));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Room Details',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        children: [
          _Carousel(images: room.images),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name,
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _infoLine(),
                const SizedBox(height: 8),
                Text(
                  room.floor,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                if (room.freeCancellationBefore != null) ...[
                  const SizedBox(height: 16),
                  _CancellationBadge(date: room.freeCancellationBefore!),
                ],
                const SizedBox(height: 28),
                const Text(
                  'Room Amenities',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _AmenitiesGrid(amenities: room.amenities),
                const SizedBox(height: 28),
                _PriceBreakdown(room: room),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BookBar(onBook: () => _startBooking(context)),
    );
  }

  Widget _infoLine() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 6,
      children: [
        _InfoItem(icon: Icons.king_bed_outlined, text: room.bedType),
        const _Dot(),
        Text(
          '${room.sizeSqm} sqm',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        const _Dot(),
        _InfoItem(icon: Icons.group_outlined, text: '${room.maxGuests} Guests'),
      ],
    );
  }
}

/// Băng ảnh phòng lướt ngang (có lộ một phần ảnh kế bên).
///
/// Là StatefulWidget vì [PageController] phải sống lâu hơn một lần build:
/// tạo controller ngay trong `build()` sẽ khiến vị trí lướt bị nhảy về ảnh đầu
/// mỗi lần widget cha vẽ lại, và mỗi lần như vậy lại rò một controller không ai
/// dispose.
class _Carousel extends StatefulWidget {
  const _Carousel({required this.images});

  final List<String> images;

  @override
  State<_Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<_Carousel> {
  final _controller = PageController(viewportFraction: 0.88);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    return SizedBox(
      height: 250,
      child: PageView.builder(
        controller: _controller,
        itemCount: images.length,
        padEnds: false,
        itemBuilder: (_, i) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: i == images.length - 1 ? 24 : 0,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AppNetworkImage(url: images[i]),
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: AppColors.textPrimary)),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) => const Text(
    '·',
    style: TextStyle(color: AppColors.textSecondary, fontSize: 18),
  );
}

class _CancellationBadge extends StatelessWidget {
  const _CancellationBadge({required this.date});
  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.creamDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.goldDark,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'Free cancellation before $date',
            style: const TextStyle(color: AppColors.goldDark),
          ),
        ],
      ),
    );
  }
}

/// Lưới tiện ích phòng — 2 cột (icon tròn + tên).
class _AmenitiesGrid extends StatelessWidget {
  const _AmenitiesGrid({required this.amenities});
  final List<String> amenities;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 4.2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: amenities.map((a) {
        return Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.creamDark,
                shape: BoxShape.circle,
              ),
              child: Icon(amenityIcon(a), color: AppColors.goldDark, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                a,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

/// Thẻ tổng kết chi phí.
class _PriceBreakdown extends StatelessWidget {
  const _PriceBreakdown({required this.room});
  final Room room;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Price Breakdown',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.goldLight),
          const SizedBox(height: 14),
          _row('Price per night', room.pricePerNight),
          const SizedBox(height: 12),
          _row('Taxes & Fees', room.taxesAndFees),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.goldLight),
          const SizedBox(height: 14),
          _row('Total', room.total, bold: true),
        ],
      ),
    );
  }

  Widget _row(String label, double value, {bool bold = false}) {
    final style = TextStyle(
      fontSize: bold ? 18 : 15,
      fontWeight: bold ? FontWeight.bold : FontWeight.w400,
      color: AppColors.textPrimary,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text('\$${value.toStringAsFixed(0)}', style: style),
      ],
    );
  }
}

/// Thanh dưới cùng: nút "Book This Room".
class _BookBar extends StatelessWidget {
  const _BookBar({required this.onBook});
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
        child: GestureDetector(
          onTap: onBook,
          child: Container(
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.goldLight, AppColors.goldDark],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x338B6F3D),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              'Book This Room',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
