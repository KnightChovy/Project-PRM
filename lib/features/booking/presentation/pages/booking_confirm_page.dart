import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_stay_ai/core/di/injection.dart';
import 'package:smart_stay_ai/core/router/app_router.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';
import 'package:smart_stay_ai/core/widgets/app_network_image.dart';
import 'package:smart_stay_ai/features/booking/domain/usecases/create_booking.dart';
import 'package:smart_stay_ai/features/booking/presentation/providers/booking_notifier.dart';
import 'package:smart_stay_ai/features/rooms/domain/entities/room.dart';

/// Màn xác nhận đặt phòng: chọn số đêm / số khách rồi bấm "Confirm Booking".
class BookingConfirmPage extends StatefulWidget {
  const BookingConfirmPage({super.key, required this.room});

  final Room room;

  @override
  State<BookingConfirmPage> createState() => _BookingConfirmPageState();
}

class _BookingConfirmPageState extends State<BookingConfirmPage> {
  final _notifier = sl<BookingNotifier>();
  int _nights = 1;
  late int _guests = widget.room.maxGuests;
  bool _submitting = false;

  Room get room => widget.room;
  double get total => room.pricePerNight * _nights + room.taxesAndFees;

  Future<void> _confirm() async {
    setState(() => _submitting = true);
    final ok = await _notifier.book(
      CreateBookingParams(
        roomName: room.name,
        imageUrl: room.images.first,
        pricePerNight: room.pricePerNight,
        nights: _nights,
        guests: _guests,
        taxesAndFees: room.taxesAndFees,
      ),
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đặt phòng thành công!')),
      );
      // Về màn chính và mở thẳng tab "My Booking" (index 2).
      context.go(AppRoutes.home, extra: 2);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_notifier.errorMessage ?? 'Đặt phòng thất bại')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Confirm Booking',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _roomCard(),
          const SizedBox(height: 24),
          _Stepper(
            label: 'Số đêm',
            value: _nights,
            min: 1,
            max: 14,
            onChanged: (v) => setState(() => _nights = v),
          ),
          const SizedBox(height: 16),
          _Stepper(
            label: 'Số khách',
            value: _guests,
            min: 1,
            max: room.maxGuests,
            onChanged: (v) => setState(() => _guests = v),
          ),
          const SizedBox(height: 24),
          _breakdown(),
        ],
      ),
      bottomNavigationBar: _confirmBar(),
    );
  }

  Widget _roomCard() {
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
            height: 100,
            child: AppNetworkImage(url: room.images.first),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    room.name,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${room.pricePerNight.toStringAsFixed(0)} / đêm',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _breakdown() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          _row('\$${room.pricePerNight.toStringAsFixed(0)} × $_nights đêm',
              room.pricePerNight * _nights),
          const SizedBox(height: 12),
          _row('Taxes & Fees', room.taxesAndFees),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.goldLight),
          const SizedBox(height: 14),
          _row('Total', total, bold: true),
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

  Widget _confirmBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
        child: GestureDetector(
          onTap: _submitting ? null : _confirm,
          child: Opacity(
            opacity: _submitting ? 0.6 : 1,
            child: Container(
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.goldLight, AppColors.goldDark],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Confirm Booking · \$${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bộ tăng/giảm số lượng (số đêm, số khách).
class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _circleBtn(Icons.remove, value > min ? () => onChanged(value - 1) : null),
          SizedBox(
            width: 36,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _circleBtn(Icons.add, value < max ? () => onChanged(value + 1) : null),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback? onTap) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? AppColors.goldDark : AppColors.creamDark,
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? Colors.white : AppColors.hint,
        ),
      ),
    );
  }
}
