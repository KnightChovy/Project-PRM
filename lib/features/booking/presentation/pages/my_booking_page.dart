import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_stay_ai/core/di/injection.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';
import 'package:smart_stay_ai/core/widgets/app_network_image.dart';
import 'package:smart_stay_ai/features/booking/domain/entities/booking.dart';
import 'package:smart_stay_ai/features/booking/presentation/providers/booking_notifier.dart';

/// Tab "My Booking": danh sách các phòng đã đặt.
class MyBookingPage extends StatefulWidget {
  const MyBookingPage({super.key});

  @override
  State<MyBookingPage> createState() => _MyBookingPageState();
}

class _MyBookingPageState extends State<MyBookingPage> {
  // Dùng chung BookingNotifier singleton với màn xác nhận đặt phòng.
  final _notifier = sl<BookingNotifier>();

  @override
  void initState() {
    super.initState();
    _notifier.loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _notifier,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Text(
                'My Bookings',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: Consumer<BookingNotifier>(
                builder: (context, notifier, _) {
                  if (notifier.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (notifier.bookings.isEmpty) {
                    return const _EmptyBookings();
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    itemCount: notifier.bookings.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (_, i) =>
                        _BookingCard(booking: notifier.bookings[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          SizedBox(
            width: 110,
            height: 120,
            child: AppNetworkImage(url: booking.imageUrl),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    booking.roomName,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${booking.nights} đêm · ${booking.totalGuests} khách',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const _StatusChip(),
                      const Spacer(),
                      Text(
                        '\$${booking.total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.goldDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3EE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'Confirmed',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF3B7A57),
        ),
      ),
    );
  }
}

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_month, size: 64, color: AppColors.goldLight),
          const SizedBox(height: 16),
          const Text(
            'Chưa có đặt phòng nào',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hãy đặt phòng đầu tiên của bạn nhé!',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
