import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_stay_ai/core/router/app_router.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';
import 'package:smart_stay_ai/core/utils/date_format.dart';
import 'package:smart_stay_ai/core/widgets/app_network_image.dart';
import 'package:smart_stay_ai/features/booking/domain/entities/booking.dart';

/// Màn "Booking Details" — xem chi tiết một booking ĐÃ đặt (kèm nút Huỷ /
/// tải biên nhận). Nhận [Booking] qua `extra` của go_router.
///
/// TRANG MỚI, khác với `booking_details_page.dart` (màn xác nhận trước khi
/// thanh toán) của Phat — không sửa file đó.
class BookingDetailViewPage extends StatelessWidget {
  const BookingDetailViewPage({super.key, required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Booking Details',
            style:
                TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _hero(),
            const SizedBox(height: 16),
            _idRow(),
            const Divider(height: 28),
            _dateCards(),
            const SizedBox(height: 16),
            _infoRow('Room Type', booking.roomName),
            _infoRow('Guests', '${booking.adults} Adults'),
            const Divider(height: 28),
            _paymentSummary(),
            const SizedBox(height: 16),
            _cancellationNote(),
            const SizedBox(height: 20),
            _downloadButton(context),
            const SizedBox(height: 12),
            _cancelButton(context),
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
              height: 170,
              width: double.infinity,
              child: AppNetworkImage(url: booking.imageUrl)),
        ),
        const SizedBox(height: 12),
        Text(booking.hotelName,
            style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        Row(
          children: [
            const Icon(Icons.place_outlined,
                size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(booking.location,
                  style: const TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _idRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Booking ID: #${booking.code}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            Text('Booked on ${formatShortDate(booking.createdAt)}',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3EE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text('CONFIRMED',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3B7A57))),
        ),
      ],
    );
  }

  Widget _dateCards() {
    return Row(
      children: [
        Expanded(
            child: _dateCard(
                'CHECK-IN', booking.checkIn, booking.checkInTime)),
        const SizedBox(width: 12),
        Expanded(
            child: _dateCard(
                'CHECK-OUT', booking.checkOut, booking.checkOutTime)),
      ],
    );
  }

  Widget _dateCard(String label, DateTime date, String time) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.creamDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 1,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(formatShortDate(date),
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          Text(time,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _paymentSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment Summary',
            style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        _priceRow('Room Rate (${booking.nights} nights)',
            '\$${booking.subtotal.toStringAsFixed(2)}'),
        _priceRow('Taxes & Fees', '\$${booking.taxes.toStringAsFixed(2)}'),
        if (booking.discount > 0)
          _priceRow('Loyalty Discount',
              '-\$${booking.discount.toStringAsFixed(2)}'),
        const Divider(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total Paid',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary)),
            Text('\$${booking.total.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.goldDark)),
          ],
        ),
      ],
    );
  }

  Widget _priceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _cancellationNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.creamDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          Icon(Icons.info_outline, size: 18, color: AppColors.textSecondary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Miễn phí huỷ trước ngày nhận phòng. Sau đó có thể áp dụng phí 50%.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _downloadButton(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldDark,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: const Icon(Icons.download_rounded, size: 18),
        label: const Text('Download Receipt'),
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đang tải biên nhận... (demo)')),
        ),
      ),
    );
  }

  Widget _cancelButton(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFB23B3B),
          side: const BorderSide(color: Color(0xFFB23B3B)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: () => context.push(AppRoutes.cancelBooking, extra: booking),
        child: const Text('Cancel Booking'),
      ),
    );
  }
}
