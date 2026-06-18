import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smart_stay_ai/core/di/injection.dart';
import 'package:smart_stay_ai/core/router/app_router.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';
import 'package:smart_stay_ai/core/utils/date_format.dart';
import 'package:smart_stay_ai/features/booking/domain/usecases/create_booking.dart';
import 'package:smart_stay_ai/features/booking/presentation/models/booking_draft.dart';
import 'package:smart_stay_ai/features/booking/presentation/providers/booking_notifier.dart';

/// Bước 3: thanh toán bằng cách quét mã QR.
class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key, required this.draft});

  final BookingDraft draft;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _notifier = sl<BookingNotifier>();
  bool _paying = false;

  BookingDraft get draft => widget.draft;

  /// Chuỗi mã hoá vào QR để app ngân hàng/ví quét.
  String get _qrData =>
      'smartstay://pay?hotel=${Uri.encodeComponent(draft.hotel.name)}'
      '&room=${Uri.encodeComponent(draft.room.name)}'
      '&amount=${draft.total.toStringAsFixed(0)}';

  Future<void> _pay() async {
    setState(() => _paying = true);
    final booking = await _notifier.book(
      CreateBookingParams(
        hotelName: draft.hotel.name,
        location: draft.hotel.location,
        roomName: draft.room.name,
        imageUrl: draft.room.images.first,
        guestName: draft.guestName,
        checkIn: draft.checkIn,
        checkOut: draft.checkOut,
        checkInTime: draft.hotel.checkIn,
        checkOutTime: draft.hotel.checkOut,
        adults: draft.adults,
        children: draft.children,
        subtotal: draft.subtotal,
        taxes: draft.taxes,
        discount: draft.discount,
      ),
    );
    if (!mounted) return;
    setState(() => _paying = false);

    if (booking != null) {
      // Thanh toán xong -> màn xác nhận (thay cả luồng đặt phòng).
      context.go(AppRoutes.bookingConfirmed, extra: booking);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_notifier.errorMessage ?? 'Thanh toán lỗi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Secure Checkout',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          const Center(
            child: Text(
              'STEP 3 OF 3',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Payment',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _summaryCard(),
          const SizedBox(height: 28),
          _qrCard(),
        ],
      ),
      bottomNavigationBar: _payBar(),
    );
  }

  Widget _summaryCard() {
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
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              draft.room.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${formatShortDate(draft.checkIn)} - ${formatShortDate(draft.checkOut)}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.goldLight),
          const SizedBox(height: 14),
          _row('Subtotal', draft.subtotal),
          const SizedBox(height: 10),
          _row('Taxes & Fees', draft.taxes),
          if (draft.discount > 0) ...[
            const SizedBox(height: 10),
            _row('Loyalty Discount', -draft.discount, highlight: true),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.goldLight),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '\$${draft.total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.goldDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, double value, {bool highlight = false}) {
    final color = highlight ? AppColors.goldDark : AppColors.textPrimary;
    final sign = value < 0 ? '-' : '';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: color)),
        Text(
          '$sign\$${value.abs().toStringAsFixed(0)}',
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _qrCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Quét mã QR để thanh toán',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Dùng app ngân hàng / ví điện tử để quét',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.goldLight),
            ),
            child: QrImageView(
              data: _qrData,
              size: 200,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'Bảo mật bằng mã hoá 256-bit',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _payBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
        child: GestureDetector(
          onTap: _paying ? null : _pay,
          child: Opacity(
            opacity: _paying ? 0.6 : 1,
            child: Container(
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.goldLight, AppColors.goldDark],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: _paying
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Tôi đã thanh toán · \$${draft.total.toStringAsFixed(0)}',
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
