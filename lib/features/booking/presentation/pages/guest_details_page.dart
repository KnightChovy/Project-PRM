import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_stay_ai/core/router/app_router.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';
import 'package:smart_stay_ai/features/booking/presentation/models/booking_draft.dart';

/// Bước 2: thông tin khách chính. Có thể tự điền sẵn từ tài khoản.
class GuestDetailsPage extends StatefulWidget {
  const GuestDetailsPage({super.key, required this.draft});

  final BookingDraft draft;

  @override
  State<GuestDetailsPage> createState() => _GuestDetailsPageState();
}

class _GuestDetailsPageState extends State<GuestDetailsPage> {
  // Tài khoản demo dùng để "tự điền".
  static const _accountFirst = 'Alex';
  static const _accountLast = 'Rivera';
  static const _accountEmail = 'alex.rivera@example.com';

  static const _nationalities = [
    'Vietnam',
    'United States',
    'Singapore',
    'Japan',
    'Other',
  ];

  bool _forSelf = true;
  final _firstCtrl = TextEditingController(text: _accountFirst);
  final _lastCtrl = TextEditingController(text: _accountLast);
  final _emailCtrl = TextEditingController(text: _accountEmail);
  final _phoneCtrl = TextEditingController();
  String? _nationality;
  TimeOfDay? _arrival;

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _toggleForSelf(bool v) {
    setState(() {
      _forSelf = v;
      if (v) {
        _firstCtrl.text = _accountFirst;
        _lastCtrl.text = _accountLast;
        _emailCtrl.text = _accountEmail;
      } else {
        _firstCtrl.clear();
        _lastCtrl.clear();
        _emailCtrl.clear();
      }
    });
  }

  Future<void> _pickArrival() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _arrival ?? const TimeOfDay(hour: 14, minute: 0),
    );
    if (picked != null) setState(() => _arrival = picked);
  }

  void _continue() {
    final draft = widget.draft.copyWith(
      bookingForSelf: _forSelf,
      firstName: _firstCtrl.text.trim(),
      lastName: _lastCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      nationality: _nationality ?? '',
      arrivalTime: _arrival?.format(context) ?? '',
    );
    context.push(AppRoutes.payment, extra: draft);
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Guest Details',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'STEP 2 OF 3',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Please provide the details for the main guest staying with us.',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          _forSelfCard(),
          const SizedBox(height: 20),
          _LabeledField(
            label: 'FIRST NAME',
            controller: _firstCtrl,
            readOnly: _forSelf,
            autoFilled: _forSelf,
          ),
          _LabeledField(
            label: 'LAST NAME',
            controller: _lastCtrl,
            readOnly: _forSelf,
            autoFilled: _forSelf,
          ),
          _LabeledField(
            label: 'EMAIL ADDRESS',
            controller: _emailCtrl,
            readOnly: _forSelf,
            autoFilled: _forSelf,
            keyboardType: TextInputType.emailAddress,
          ),
          _LabeledField(
            label: 'PHONE NUMBER',
            controller: _phoneCtrl,
            hint: '(555) 123-4567',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _nationalityField()),
              const SizedBox(width: 20),
              Expanded(child: _arrivalField()),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.goldLight),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Guest'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _forSelfCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.creamDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking for yourself?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "We'll use your account details.",
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _forSelf,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.goldDark,
            onChanged: _toggleForSelf,
          ),
        ],
      ),
    );
  }

  Widget _nationalityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'NATIONALITY',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        DropdownButtonFormField<String>(
          initialValue: _nationality,
          isExpanded: true,
          hint: const Text('Select'),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.textSecondary),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.goldLight),
            ),
          ),
          items: _nationalities
              .map((n) => DropdownMenuItem(value: n, child: Text(n)))
              .toList(),
          onChanged: (v) => setState(() => _nationality = v),
        ),
      ],
    );
  }

  Widget _arrivalField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ARRIVAL TIME',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        InkWell(
          onTap: _pickArrival,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.goldLight),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _arrival?.format(context) ?? '--:-- --',
                    style: TextStyle(
                      color: _arrival == null
                          ? AppColors.hint
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(Icons.access_time,
                    size: 20, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
        child: GestureDetector(
          onTap: _continue,
          child: Container(
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continue to Payment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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
    );
  }
}

/// Ô nhập có nhãn + huy hiệu "Auto-filled".
class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.hint,
    this.readOnly = false,
    this.autoFilled = false,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool readOnly;
  final bool autoFilled;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  readOnly: readOnly,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(color: AppColors.hint),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.goldLight),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.goldDark),
                    ),
                  ),
                ),
              ),
              if (autoFilled) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.goldLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Auto-filled',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.goldDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.check, size: 14, color: AppColors.goldDark),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
