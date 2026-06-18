import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smart_stay_ai/core/router/app_router.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';
import 'package:smart_stay_ai/core/utils/date_format.dart';
import 'package:smart_stay_ai/features/booking/domain/entities/booking.dart';

/// Màn xác nhận đặt phòng thành công (dạng vé).
class BookingConfirmedPage extends StatelessWidget {
  const BookingConfirmedPage({super.key, required this.booking});

  final Booking booking;

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          // Đóng -> về tab My Booking (index 2).
          onPressed: () => context.go(AppRoutes.home, extra: 2),
        ),
        title: const Text(
          'Booking Confirmed',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        children: [
          _ticket(),
          const SizedBox(height: 24),
          _OutlineAction(
            icon: Icons.download,
            label: 'Download PDF',
            onTap: () => _toast(context, 'Đang tải PDF... (demo)'),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _OutlineAction(
                  icon: Icons.calendar_today,
                  label: 'Add to Calendar',
                  onTap: () => _toast(context, 'Đã thêm vào lịch (demo)'),
                ),
              ),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: () => _toast(context, 'Chia sẻ... (demo)'),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.goldDark,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ticket() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7EFD6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle,
                            size: 14, color: AppColors.goldDark),
                        SizedBox(width: 4),
                        Text(
                          'CONFIRMED',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.goldDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.apartment,
                      color: AppColors.goldDark, size: 30),
                ),
                const SizedBox(height: 12),
                Text(
                  booking.hotelName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.goldDark,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on,
                        size: 16, color: AppColors.goldDark),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        booking.location,
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const _DashedDivider(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _info('GUEST', booking.guestName),
                _info('ROOM', booking.roomName),
                _info('CHECK-IN', formatShortDate(booking.checkIn),
                    sub: booking.checkInTime),
                _info('CHECK-OUT', formatShortDate(booking.checkOut),
                    sub: booking.checkOutTime),
                _info('TOTAL GUESTS',
                    '${booking.adults} Adults${booking.children > 0 ? ' · ${booking.children} Children' : ''}'),
              ],
            ),
          ),
          const _DashedDivider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: QrImageView(
                    data: booking.code,
                    size: 120,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppColors.textPrimary,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'BOOKING ID',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  booking.code,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: AppColors.goldDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(String label, String value, {String? sub}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          if (sub != null)
            Text(
              sub,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

/// Đường kẻ đứt (răng vé).
class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 6.0;
        final count = (constraints.maxWidth / (dashWidth * 2)).floor();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              count,
              (_) => Container(
                width: dashWidth,
                height: 1,
                color: AppColors.goldLight,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OutlineAction extends StatelessWidget {
  const _OutlineAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.goldLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.textPrimary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
