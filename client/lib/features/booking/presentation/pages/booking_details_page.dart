import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_stay_ai/core/router/app_router.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';
import 'package:smart_stay_ai/core/utils/date_format.dart';
import 'package:smart_stay_ai/core/widgets/app_network_image.dart';
import 'package:smart_stay_ai/features/booking/presentation/models/booking_draft.dart';
import 'package:smart_stay_ai/features/hotel/domain/entities/hotel.dart';
import 'package:smart_stay_ai/features/rooms/domain/entities/room.dart';

/// Bước 1: xem lại thông tin đặt phòng (ngày, số khách, yêu cầu thêm).
class BookingDetailsPage extends StatefulWidget {
  const BookingDetailsPage({super.key, required this.hotel, required this.room});

  final Hotel hotel;
  final Room room;

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  late DateTime _checkIn;
  late DateTime _checkOut;
  int _adults = 2;
  int _children = 0;
  final _requestsCtrl = TextEditingController();

  Room get room => widget.room;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _checkIn = DateTime(now.year, now.month, now.day);
    _checkOut = _checkIn.add(const Duration(days: 2));
  }

  @override
  void dispose() {
    _requestsCtrl.dispose();
    super.dispose();
  }

  int get _nights => _checkOut.difference(_checkIn).inDays;
  double get _subtotal => room.pricePerNight * _nights;
  double get _total =>
      _subtotal + _subtotal * 0.10 - (_nights >= 2 ? _subtotal * 0.10 : 0);

  Future<void> _pickCheckIn() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkIn,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      _checkIn = picked;
      if (!_checkOut.isAfter(_checkIn)) {
        _checkOut = _checkIn.add(const Duration(days: 1));
      }
    });
  }

  Future<void> _pickCheckOut() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkOut,
      firstDate: _checkIn.add(const Duration(days: 1)),
      lastDate: _checkIn.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() => _checkOut = picked);
  }

  void _continue() {
    final draft = BookingDraft(
      hotel: widget.hotel,
      room: room,
      checkIn: _checkIn,
      checkOut: _checkOut,
      adults: _adults,
      children: _children,
      specialRequests: _requestsCtrl.text.trim(),
    );
    context.push(AppRoutes.guestDetails, extra: draft);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SmartStay',
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
          const Text(
            'Complete Your Booking',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Almost there. Please review your details.',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          _roomCard(),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: 'CHECK-IN',
                  value: formatShortDate(_checkIn),
                  icon: Icons.login,
                  onTap: _pickCheckIn,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _DateField(
                  label: 'CHECK-OUT',
                  value: formatShortDate(_checkOut),
                  icon: Icons.event_available,
                  onTap: _pickCheckOut,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _guestsCard(),
          const SizedBox(height: 24),
          const Text(
            'Special Requests',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _requestsField(),
          if (_nights >= 2) ...[
            const SizedBox(height: 24),
            _conciergeBanner(),
          ],
        ],
      ),
      bottomNavigationBar: _bottomBar(),
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 90,
                height: 90,
                child: AppNetworkImage(url: room.images.first),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.hotel.name,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    room.name,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.creamDark,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 14, color: AppColors.goldDark),
                        const SizedBox(width: 6),
                        Text(
                          formatDateRange(_checkIn, _checkOut),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.nightlight_round,
                            size: 14, color: AppColors.goldDark),
                        const SizedBox(width: 4),
                        Text(
                          '$_nights NIGHTS',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _guestsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.goldLight),
      ),
      child: Column(
        children: [
          _GuestRow(
            title: 'Adults',
            subtitle: 'Ages 13 or above',
            value: _adults,
            min: 1,
            onChanged: (v) => setState(() => _adults = v),
          ),
          const Divider(height: 1, color: AppColors.goldLight),
          _GuestRow(
            title: 'Children',
            subtitle: 'Ages 0-12',
            value: _children,
            min: 0,
            onChanged: (v) => setState(() => _children = v),
          ),
        ],
      ),
    );
  }

  Widget _requestsField() {
    return TextField(
      controller: _requestsCtrl,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Any special requests? (optional)',
        hintStyle: const TextStyle(color: AppColors.hint),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.all(16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.goldLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.goldDark),
        ),
      ),
    );
  }

  Widget _conciergeBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3EE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: Color(0xFF3B7A57), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Color(0xFF3B7A57),
                  fontSize: 13,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(
                    text: 'CONCIERGE CHOICE\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextSpan(text: 'Booking $_nights nights qualifies you for a '),
                  const TextSpan(
                    text: '10% loyalty discount',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' at checkout!'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'TOTAL',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '\$${_total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: _continue,
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.goldLight, AppColors.goldDark],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue to Guest Info',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ô ngày Check-in / Check-out (bấm để chọn).
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.goldLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 1,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(icon, size: 18, color: AppColors.goldDark),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Dòng Adults/Children với nút +/-.
class _GuestRow extends StatelessWidget {
  const _GuestRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final int value;
  final int min;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _circle(Icons.remove, value > min ? () => onChanged(value - 1) : null),
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
          _circle(Icons.add, value < 10 ? () => onChanged(value + 1) : null),
        ],
      ),
    );
  }

  Widget _circle(IconData icon, VoidCallback? onTap) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled ? AppColors.goldDark : AppColors.goldLight,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.goldDark : AppColors.hint,
        ),
      ),
    );
  }
}
