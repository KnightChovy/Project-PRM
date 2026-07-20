import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_stay_ai/core/di/injection.dart';
import 'package:smart_stay_ai/core/router/app_router.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';
import 'package:smart_stay_ai/core/utils/date_format.dart';
import 'package:smart_stay_ai/core/widgets/app_network_image.dart';
import 'package:smart_stay_ai/features/booking/domain/entities/booking.dart';
import 'package:smart_stay_ai/features/booking/domain/entities/booking_history_item.dart';
import 'package:smart_stay_ai/features/booking/presentation/providers/booking_history_notifier.dart';
import 'package:smart_stay_ai/features/review/presentation/pages/write_review_page.dart';

/// Màn "My Bookings" nâng cấp: 3 tab Upcoming / Completed / Cancelled,
/// mỗi booking có nút hành động phù hợp (View Details, Cancel, Write Review...).
///
/// Đây là TRANG MỚI — không sửa `my_booking_page.dart` cũ của Phat.
class MyBookingsViewPage extends StatefulWidget {
  const MyBookingsViewPage({super.key});

  @override
  State<MyBookingsViewPage> createState() => _MyBookingsViewPageState();
}

class _MyBookingsViewPageState extends State<MyBookingsViewPage> {
  final _notifier = sl<BookingHistoryNotifier>();

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
                child: Consumer<BookingHistoryNotifier>(
                  builder: (context, notifier, _) {
                    if (notifier.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return TabBarView(
                      children: [
                        _BookingList(
                            items: notifier.upcoming,
                            onRefresh: notifier.load),
                        _BookingList(
                            items: notifier.completed,
                            onRefresh: notifier.load),
                        _BookingList(
                            items: notifier.cancelled,
                            onRefresh: notifier.load),
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

class _BookingList extends StatelessWidget {
  const _BookingList({required this.items, required this.onRefresh});
  final List<BookingHistoryItem> items;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    // Kéo xuống để tải lại — bắt được booking mới đặt qua luồng của Phat.
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
              itemBuilder: (_, i) => _BookingCard(item: items[i]),
            ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.item});
  final BookingHistoryItem item;

  void _openDetail(BuildContext context) =>
      context.push(AppRoutes.bookingDetailView, extra: item.booking);

  @override
  Widget build(BuildContext context) {
    final b = item.booking;
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
              SizedBox(
                  height: 130,
                  width: double.infinity,
                  child: AppNetworkImage(url: b.imageUrl)),
              Positioned(top: 10, left: 10, child: _StatusChip(item.status)),
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
                      child: Text(b.hotelName,
                          style: const TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                    ),
                    Text('\$${b.total.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.goldDark)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(formatDateRange(b.checkIn, b.checkOut),
                    style: const TextStyle(color: AppColors.textSecondary)),
                Text(b.roomName,
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

  /// Nút hành động tuỳ theo trạng thái (giống thiết kế Stitch).
  Widget _actions(BuildContext context) {
    final b = item.booking;
    switch (item.status) {
      case BookingLifecycle.upcoming:
        return Row(children: [
          Expanded(
              child: _OutlinedBtn(
                  'View Details', () => _openDetail(context))),
          const SizedBox(width: 10),
          Expanded(
            child: _OutlinedBtn(
              'Cancel',
              () => context.push(AppRoutes.cancelBooking, extra: b),
              danger: true,
            ),
          ),
        ]);
      case BookingLifecycle.completed:
        return Row(children: [
          Expanded(
              child: _OutlinedBtn(
                  'View Details', () => _openDetail(context))),
          const SizedBox(width: 10),
          Expanded(
            child: _FilledBtn(
              'Write Review',
              () => context.push(
                AppRoutes.writeReview,
                extra: WriteReviewArgs(
                  hotelName: b.hotelName,
                  location: b.location,
                  imageUrl: b.imageUrl,
                ),
              ),
            ),
          ),
        ]);
      case BookingLifecycle.cancelled:
        return Row(children: [
          Expanded(
              child: _OutlinedBtn(
                  'View Details', () => _openDetail(context))),
          const SizedBox(width: 10),
          Expanded(
            child: _FilledBtn('Rebook', () => _rebook(context, b)),
          ),
        ]);
    }
  }

  /// Đặt lại booking đã huỷ → tạo booking mới ở tab Upcoming.
  Future<void> _rebook(BuildContext context, Booking b) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await sl<BookingHistoryNotifier>().rebook(b);
    messenger.showSnackBar(SnackBar(
      content: Text(ok
          ? 'Đã đặt lại! Booking mới nằm ở tab Upcoming.'
          : 'Đặt lại thất bại, vui lòng thử lại.'),
    ));
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.status);
  final BookingLifecycle status;

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color bg;
    late final Color fg;
    switch (status) {
      case BookingLifecycle.upcoming:
        label = 'Confirmed';
        bg = const Color(0xFFEAF3EE);
        fg = const Color(0xFF3B7A57);
      case BookingLifecycle.completed:
        label = 'Completed';
        bg = const Color(0xFFEFEFEF);
        fg = AppColors.textSecondary;
      case BookingLifecycle.cancelled:
        label = 'Cancelled';
        bg = const Color(0xFFF6E5E5);
        fg = const Color(0xFFB23B3B);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onTap,
      child: Text(label),
    );
  }
}
