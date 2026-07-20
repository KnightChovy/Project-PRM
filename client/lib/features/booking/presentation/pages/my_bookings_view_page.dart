import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_stay_ai/core/di/injection.dart';
import 'package:smart_stay_ai/core/router/app_router.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';
import 'package:smart_stay_ai/core/utils/currency_format.dart';
import 'package:smart_stay_ai/core/utils/date_format.dart';
import 'package:smart_stay_ai/features/booking/domain/entities/booking.dart';
import 'package:smart_stay_ai/features/booking/domain/entities/booking_status.dart';
import 'package:smart_stay_ai/features/booking/presentation/providers/booking_notifier.dart'
    show RequestStatus;
import 'package:smart_stay_ai/features/booking/presentation/providers/my_bookings_notifier.dart';
import 'package:smart_stay_ai/features/review/presentation/pages/write_review_page.dart';

/// Màn "My Bookings": 3 tab Upcoming / Completed / Cancelled, mỗi booking có
/// nút hành động phù hợp với trạng thái.
class MyBookingsViewPage extends StatefulWidget {
  const MyBookingsViewPage({super.key});

  @override
  State<MyBookingsViewPage> createState() => _MyBookingsViewPageState();
}

class _MyBookingsViewPageState extends State<MyBookingsViewPage> {
  final _notifier = sl<MyBookingsNotifier>();

  @override
  void initState() {
    super.initState();
    _notifier.load();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _notifier,
      child: DefaultTabController(
        length: 3,
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
              const TabBar(
                labelColor: AppColors.goldDark,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.gold,
                tabs: [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Completed'),
                  Tab(text: 'Cancelled'),
                ],
              ),
              Expanded(
                child: Consumer<MyBookingsNotifier>(
                  builder: (context, notifier, _) {
                    if (notifier.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (notifier.status == RequestStatus.error) {
                      return _ErrorState(
                        message: notifier.errorMessage ??
                            'Không tải được danh sách đặt phòng',
                        onRetry: notifier.load,
                      );
                    }
                    return TabBarView(
                      children: [
                        _BookingList(
                            items: notifier.upcoming, onRefresh: notifier.load),
                        _BookingList(
                            items: notifier.completed, onRefresh: notifier.load),
                        _BookingList(
                            items: notifier.cancelled, onRefresh: notifier.load),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            // Message từ server đã là tiếng Việt, hiển thị thẳng.
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  const _BookingList({required this.items, required this.onRefresh});
  final List<Booking> items;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.gold,
      child: items.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Center(
                  child: Text('Chưa có mục nào. Kéo xuống để làm mới.',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (_, i) => _BookingCard(booking: items[i]),
            ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});
  final Booking booking;

  void _openDetail(BuildContext context) =>
      context.push(AppRoutes.bookingDetailView, extra: booking);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              // API booking không trả ảnh khách sạn — dùng nền thương hiệu cho
              // tới khi tích hợp API hotel.
              Container(
                height: 130,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.goldLight, AppColors.goldDark],
                  ),
                ),
                child: const Icon(Icons.apartment, color: Colors.white, size: 40),
              ),
              Positioned(
                  top: 10, left: 10, child: _StatusChip(booking.status)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(booking.hotelName,
                          style: const TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                    ),
                    Text(formatVnd(booking.totalAmount),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.goldDark)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                    formatDateRange(booking.checkInDate, booking.checkOutDate),
                    style: const TextStyle(color: AppColors.textSecondary)),
                Text(booking.roomName,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 12),
                _actions(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Nút hành động tuỳ theo trạng thái.
  Widget _actions(BuildContext context) {
    final details = Expanded(
      child: _OutlinedBtn('View Details', () => _openDetail(context)),
    );

    switch (booking.status) {
      // Còn chờ trả tiền hoặc sắp tới: cho xem chi tiết và huỷ.
      case BookingStatus.pending:
      case BookingStatus.confirmed:
      case BookingStatus.checkedIn:
        return Row(children: [
          details,
          const SizedBox(width: 10),
          Expanded(
            child: _OutlinedBtn(
              'Cancel',
              () => context.push(AppRoutes.cancelBooking, extra: booking),
              danger: true,
            ),
          ),
        ]);

      case BookingStatus.checkedOut:
        return Row(children: [
          details,
          const SizedBox(width: 10),
          Expanded(
            child: _FilledBtn(
              'Write Review',
              () => context.push(
                AppRoutes.writeReview,
                extra: WriteReviewArgs(
                  bookingId: booking.id,
                  hotelName: booking.hotelName,
                  location: booking.location,
                  imageUrl: '',
                ),
              ),
            ),
          ),
        ]);

      case BookingStatus.cancelled:
      case BookingStatus.noShow:
        return Row(children: [details]);
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.status);
  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      BookingStatus.pending => (
          'Chờ thanh toán',
          const Color(0xFFFDF3E2),
          const Color(0xFF9A6B1F),
        ),
      BookingStatus.confirmed => (
          'Confirmed',
          const Color(0xFFEAF3EE),
          const Color(0xFF3B7A57),
        ),
      BookingStatus.checkedIn => (
          'Đang ở',
          const Color(0xFFEAF0F6),
          const Color(0xFF3B5F7A),
        ),
      BookingStatus.checkedOut => (
          'Completed',
          const Color(0xFFEFEFEF),
          AppColors.textSecondary,
        ),
      BookingStatus.cancelled => (
          'Cancelled',
          const Color(0xFFF6E5E5),
          const Color(0xFFB23B3B),
        ),
      BookingStatus.noShow => (
          'Không đến',
          const Color(0xFFF6E5E5),
          const Color(0xFFB23B3B),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label,
          style:
              TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

class _OutlinedBtn extends StatelessWidget {
  const _OutlinedBtn(this.label, this.onTap, {this.danger = false});
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFB23B3B) : AppColors.goldDark;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onTap,
      child: Text(label),
    );
  }
}

class _FilledBtn extends StatelessWidget {
  const _FilledBtn(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onTap,
      child: Text(label),
    );
  }
}
