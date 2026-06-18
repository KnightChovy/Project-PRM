import 'package:flutter/material.dart';
import 'package:smart_stay_ai/core/di/injection.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';
import 'package:smart_stay_ai/features/booking/domain/entities/booking.dart';
import 'package:smart_stay_ai/features/booking/presentation/providers/booking_history_notifier.dart';

/// Phí huỷ cố định (demo). Khi có backend, lấy theo chính sách từ API.
const double _kCancellationFee = 15;

/// Màn "Cancel Booking" — xác nhận huỷ, chọn lý do, xem hoàn tiền dự kiến.
class CancelBookingPage extends StatefulWidget {
  const CancelBookingPage({super.key, required this.booking});
  final Booking booking;

  @override
  State<CancelBookingPage> createState() => _CancelBookingPageState();
}

class _CancelBookingPageState extends State<CancelBookingPage> {
  static const _reasons = [
    'Change of plans',
    'Found a better option',
    'Emergency',
    'Other',
  ];
  String _reason = 'Other';
  final _commentCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    setState(() => _submitting = true);
    final ok = await sl<BookingHistoryNotifier>().cancel(widget.booking.id);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã huỷ booking. Hoàn tiền đang xử lý.')),
      );
      Navigator.of(context).maybePop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Huỷ thất bại, vui lòng thử lại.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.booking.total;
    final refund = (total - _kCancellationFee).clamp(0, double.infinity);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Cancel Booking',
            style:
                TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const SizedBox(height: 8),
            const Center(
              child: Icon(Icons.cancel_outlined, size: 64, color: AppColors.gold),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text('Bạn chắc chắn muốn huỷ?',
                  style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
            ),
            const SizedBox(height: 16),
            _feeWarning(),
            const SizedBox(height: 16),
            _summary(total.toDouble(), refund.toDouble()),
            const SizedBox(height: 20),
            const Text('Lý do huỷ',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            _reasonGroup(),
            const SizedBox(height: 8),
            TextField(
              controller: _commentCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Ghi chú thêm (không bắt buộc)',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.goldLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.goldLight),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _keepButton(),
            const SizedBox(height: 12),
            _confirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _feeWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.creamDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          Icon(Icons.warning_amber_rounded,
              size: 20, color: AppColors.goldDark),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Huỷ bây giờ chịu phí \$15. Cân nhắc đổi ngày thay vì huỷ.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summary(double total, double refund) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.creamDark),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Cancellation Summary',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
          ),
          const SizedBox(height: 10),
          _row('Booking Total', '\$${total.toStringAsFixed(2)}'),
          _row('Cancellation Fee', '\$${_kCancellationFee.toStringAsFixed(2)}',
              valueColor: const Color(0xFFB23B3B)),
          const Divider(height: 22),
          _row('ESTIMATED REFUND', '\$${refund.toStringAsFixed(2)}',
              bold: true, valueColor: const Color(0xFF3B7A57)),
        ],
      ),
    );
  }

  Widget _row(String label, String value,
      {bool bold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  color: valueColor ?? AppColors.textPrimary,
                  fontWeight: bold ? FontWeight.bold : FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _reasonGroup() {
    return RadioGroup<String>(
      groupValue: _reason,
      onChanged: (v) => setState(() => _reason = v ?? _reason),
      child: Column(
        children: _reasons.map(_reasonTile).toList(),
      ),
    );
  }

  Widget _reasonTile(String reason) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.creamDark),
      ),
      child: RadioListTile<String>(
        value: reason,
        activeColor: AppColors.gold,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        title: Text(reason,
            style: const TextStyle(color: AppColors.textPrimary)),
      ),
    );
  }

  Widget _keepButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldDark,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: _submitting ? null : () => Navigator.of(context).maybePop(),
        child: const Text('Keep Booking',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _confirmButton() {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFB23B3B),
          side: const BorderSide(color: Color(0xFFB23B3B)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: _submitting ? null : _confirm,
        child: _submitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Confirm Cancellation'),
      ),
    );
  }
}
