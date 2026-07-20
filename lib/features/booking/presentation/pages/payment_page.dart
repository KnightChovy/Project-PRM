import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smart_stay_ai/core/di/injection.dart';
import 'package:smart_stay_ai/core/router/app_router.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';
import 'package:smart_stay_ai/core/utils/currency_format.dart';
import 'package:smart_stay_ai/core/utils/date_format.dart';
import 'package:smart_stay_ai/features/booking/domain/entities/booking.dart';
import 'package:smart_stay_ai/features/booking/domain/entities/booking_status.dart';
import 'package:smart_stay_ai/features/booking/domain/usecases/create_booking.dart';
import 'package:smart_stay_ai/features/booking/presentation/models/booking_draft.dart';
import 'package:smart_stay_ai/features/booking/presentation/providers/booking_notifier.dart';
import 'package:url_launcher/url_launcher.dart';

/// Bước 3: chọn phương thức và thanh toán.
///
/// Luồng: chọn phương thức -> `POST /bookings` -> tuỳ phương thức mà đi tiếp
/// (VNPay mở cổng, SePay hiện QR rồi poll, tiền mặt xong luôn).
class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key, required this.draft});

  final BookingDraft draft;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late final BookingNotifier _notifier = sl<BookingNotifier>();

  PaymentMethod _method = PaymentMethod.vnpay;
  Timer? _countdownTimer;

  /// Cả `_submit` lẫn Consumer (khi poll thấy `confirmed`) đều muốn điều hướng
  /// sang màn xác nhận — chốt này đảm bảo chỉ đi một lần.
  bool _navigated = false;

  BookingDraft get draft => widget.draft;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _notifier.dispose();
    super.dispose();
  }

  /// Nhịp 1s để cập nhật đồng hồ đếm ngược hạn giữ chỗ.
  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _submit() async {
    final booking = await _notifier.create(
      CreateBookingParams(
        hotelId: draft.hotel.id,
        roomTypeId: draft.room.id,
        checkInDate: draft.checkIn,
        checkOutDate: draft.checkOut,
        numGuests: draft.totalGuests,
        specialRequests: draft.specialRequests,
        paymentMethod: _method,
      ),
    );
    if (!mounted) return;

    if (booking == null) {
      _showError(_notifier.errorMessage ?? 'Đặt phòng thất bại');
      return;
    }

    // Tiền mặt: server trả về `confirmed` kèm voucher ngay, xong luôn.
    if (booking.status == BookingStatus.confirmed) {
      _goToConfirmed(booking);
      return;
    }

    _startCountdown();
    if (_method == PaymentMethod.vnpay) await _openVnpay();
    if (_method == PaymentMethod.sepay) await _notifier.beginSepayCheckout();
  }

  Future<void> _openVnpay() async {
    final url = await _notifier.beginVnpayCheckout();
    if (!mounted) return;

    if (url == null) {
      _showError(_notifier.errorMessage ?? 'Không tạo được liên kết thanh toán');
      return;
    }

    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!mounted) return;
    if (!opened) _showError('Không mở được cổng thanh toán VNPay');
  }

  /// Sau khi quay lại từ cổng thanh toán, hỏi lại server chứ không tin
  /// query param redirect về.
  Future<void> _confirmFromServer() async {
    final booking = await _notifier.refresh();
    if (!mounted) return;

    if (booking == null) {
      _showError(_notifier.errorMessage ?? 'Không kiểm tra được trạng thái');
      return;
    }
    if (booking.status == BookingStatus.pending) {
      _showError('Chưa nhận được thanh toán. Vui lòng thử lại sau ít phút.');
      return;
    }
    _goToConfirmed(booking);
  }

  void _goToConfirmed(Booking booking) {
    if (_navigated) return;
    _navigated = true;
    context.go(AppRoutes.bookingConfirmed, extra: booking);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _notifier,
      child: Consumer<BookingNotifier>(
        builder: (context, notifier, _) {
          final booking = notifier.booking;

          // Booking đã confirmed (vd ví trả đủ, hoặc poll SePay thấy tiền về).
          if (booking != null &&
              booking.status == BookingStatus.confirmed &&
              !_navigated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _goToConfirmed(booking);
            });
          }

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
                const _StepHeader(),
                const SizedBox(height: 20),
                _summaryCard(notifier),
                const SizedBox(height: 20),
                if (booking == null)
                  _methodPicker()
                else ...[
                  _holdBanner(notifier),
                  const SizedBox(height: 20),
                  if (notifier.sepayCheckout != null) _sepayCard(notifier),
                  if (_method == PaymentMethod.vnpay) _vnpayCard(),
                ],
              ],
            ),
            bottomNavigationBar: _bottomBar(notifier),
          );
        },
      ),
    );
  }

  Widget _summaryCard(BookingNotifier notifier) {
    final booking = notifier.booking;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            booking?.roomName.isNotEmpty == true
                ? booking!.roomName
                : draft.room.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${formatShortDate(draft.checkIn)} - ${formatShortDate(draft.checkOut)}'
            ' · ${draft.totalGuests} khách',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.goldLight),
          const SizedBox(height: 14),
          if (booking == null)
            // Chưa gọi API: chỉ ước tính từ dữ liệu phòng, server mới là chuẩn.
            const Text(
              'Tổng tiền do máy chủ tính khi xác nhận đặt phòng.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            )
          else ...[
            _row('Tiền phòng', formatVnd(booking.subtotal)),
            const SizedBox(height: 10),
            _row('Thuế', formatVnd(booking.taxAmount)),
            const SizedBox(height: 10),
            _row('Phí dịch vụ', formatVnd(booking.feeAmount)),
            if (!booking.discountAmount.isZero) ...[
              const SizedBox(height: 10),
              _row('Giảm giá', '-${formatVnd(booking.discountAmount)}',
                  highlight: true),
            ],
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.goldLight),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng cộng',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  formatVnd(booking.totalAmount),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.goldDark,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool highlight = false}) {
    final color = highlight ? AppColors.goldDark : AppColors.textPrimary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: color)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _methodPicker() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phương thức thanh toán',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _methodTile(
            PaymentMethod.vnpay,
            'VNPay',
            'Chuyển sang cổng thanh toán · giữ chỗ 15 phút',
            Icons.credit_card,
          ),
          _methodTile(
            PaymentMethod.sepay,
            'Chuyển khoản QR (SePay)',
            'Quét mã bằng app ngân hàng · giữ chỗ 30 phút',
            Icons.qr_code_2,
          ),
          _methodTile(
            PaymentMethod.cash,
            'Trả tại quầy',
            'Xác nhận ngay, thanh toán khi nhận phòng',
            Icons.payments_outlined,
          ),
        ],
      ),
    );
  }

  Widget _methodTile(
    PaymentMethod method,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return RadioListTile<PaymentMethod>(
      value: method,
      // ignore: deprecated_member_use
      groupValue: _method,
      // ignore: deprecated_member_use
      onChanged: (value) => setState(() => _method = value ?? _method),
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.goldDark,
      title: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.goldDark),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
    );
  }

  /// Đồng hồ đếm ngược tới `holdExpiresAt` — quá hạn là mất phòng.
  Widget _holdBanner(BookingNotifier notifier) {
    final remaining = notifier.remainingHold;
    if (remaining == null) return const SizedBox.shrink();

    final expired = remaining == Duration.zero;
    final minutes = remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: expired ? Colors.red.shade50 : AppColors.goldLight.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            expired ? Icons.error_outline : Icons.timer_outlined,
            size: 18,
            color: expired ? Colors.red : AppColors.goldDark,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              expired
                  ? 'Đã quá hạn giữ chỗ. Vui lòng đặt lại.'
                  : 'Giữ chỗ còn $minutes:$seconds',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: expired ? Colors.red : AppColors.goldDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sepayCard(BookingNotifier notifier) {
    final checkout = notifier.sepayCheckout!;
    return _Card(
      child: Column(
        children: [
          const Text(
            'Quét mã để chuyển khoản',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // QR do SePay sinh sẵn dưới dạng ảnh.
          Image.network(
            checkout.qrUrl,
            height: 220,
            errorBuilder: (_, _, _) => QrImageView(
              data: checkout.transferContent,
              size: 200,
            ),
          ),
          const SizedBox(height: 16),
          _transferRow('Ngân hàng', checkout.bankCode),
          _transferRow('Số tài khoản', checkout.accountNumber),
          _transferRow('Số tiền', formatVnd(checkout.amount)),
          _transferRow('Nội dung', checkout.transferContent, emphasize: true),
          const SizedBox(height: 12),
          const Text(
            'Nội dung chuyển khoản phải ghi đúng, nếu sai hệ thống không khớp '
            'được giao dịch với đơn của bạn.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 14,
                width: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text(
                'Đang chờ ngân hàng xác nhận…',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _transferRow(String label, String value, {bool emphasize = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: emphasize ? AppColors.goldDark : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vnpayCard() {
    return _Card(
      child: Column(
        children: [
          const Icon(Icons.open_in_new, color: AppColors.goldDark),
          const SizedBox(height: 12),
          const Text(
            'Hoàn tất thanh toán trên cổng VNPay rồi quay lại đây.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _openVnpay,
            child: const Text('Mở lại cổng thanh toán'),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar(BookingNotifier notifier) {
    final booking = notifier.booking;
    final busy = notifier.isLoading;

    // Chưa tạo booking -> nút đặt phòng. Đã tạo -> nút kiểm tra trạng thái.
    final label = booking == null
        ? 'Xác nhận đặt phòng'
        : 'Tôi đã thanh toán · kiểm tra lại';
    final action = booking == null ? _submit : _confirmFromServer;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
        child: GestureDetector(
          onTap: busy ? null : action,
          child: Opacity(
            opacity: busy ? 0.6 : 1,
            child: Container(
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.goldLight, AppColors.goldDark],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: busy
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      label,
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

class _StepHeader extends StatelessWidget {
  const _StepHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'STEP 3 OF 3',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Payment',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }
}
