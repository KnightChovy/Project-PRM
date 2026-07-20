import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Edit Profile — full form matching the mockup. Local state only.
/// ponytail: no bloc/usecase yet — wire when the profile-update API exists.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController(text: 'Alex');
  final _last = TextEditingController(text: 'Sterling');
  final _phone = TextEditingController(text: '+1 234 567 890');

  DateTime _dob = DateTime(1985, 10, 12);
  String _gender = 'Male';
  String _nationality = 'United States';

  static const _countries = [
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
    'France',
  ];
  static const _allPrefs = [
    'Beach',
    'City',
    'Culture',
    'Mountain',
    'Adventure',
    'Wellness',
  ];
  final _prefs = {'Beach', 'City', 'Culture'};

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated')),
    );
    Navigator.of(context).pop();
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  String get _dobLabel => '${_months[_dob.month - 1]} ${_dob.day}, ${_dob.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            children: [
              const _AvatarEditor(),
              const SizedBox(height: 40),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _FieldWrap(
                      label: 'First Name',
                      child: _LineField(
                        controller: _first,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _FieldWrap(
                      label: 'Last Name',
                      child: _LineField(
                        controller: _last,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _FieldWrap(
                label: 'Email',
                trailing: const _VerifiedBadge(),
                child: const _LineField(
                  initialValue: 'alex.sterling@example.com',
                  enabled: false,
                ),
              ),
              const SizedBox(height: 16),
              _FieldWrap(
                label: 'Phone Number',
                child: _LineField(controller: _phone, keyboardType: TextInputType.phone),
              ),
              const SizedBox(height: 16),
              _FieldWrap(
                label: 'Date of Birth',
                child: InkWell(
                  onTap: _pickDob,
                  child: IgnorePointer(
                    child: _LineField(
                      key: ValueKey(_dobLabel),
                      initialValue: _dobLabel,
                      suffixIcon: const Icon(Icons.calendar_month,
                          color: AppTheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _FieldWrap(
                label: 'Gender',
                child: _GenderToggle(
                  value: _gender,
                  onChanged: (g) => setState(() => _gender = g),
                ),
              ),
              const SizedBox(height: 24),
              _FieldWrap(
                label: 'Nationality',
                child: DropdownButtonFormField<String>(
                  initialValue: _nationality,
                  isExpanded: true,
                  icon: const Icon(Icons.expand_more, color: AppTheme.onSurfaceVariant),
                  decoration: _lineDecoration(),
                  items: [
                    for (final c in _countries)
                      DropdownMenuItem(value: c, child: Text(c)),
                  ],
                  onChanged: (v) => setState(() => _nationality = v ?? _nationality),
                ),
              ),
              const SizedBox(height: 40),
              Text('Travel Preferences',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final p in _allPrefs)
                    _PrefChip(
                      label: p,
                      selected: _prefs.contains(p),
                      onTap: () => setState(
                        () => _prefs.contains(p) ? _prefs.remove(p) : _prefs.add(p),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.secondary,
                foregroundColor: AppTheme.onSecondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _save,
              child: const Text(
                'SAVE CHANGES',
                style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Underline input on a tinted fill, reused by every field here.
InputDecoration _lineDecoration() => InputDecoration(
      filled: true,
      fillColor: AppTheme.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppTheme.outlineVariant),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppTheme.secondary),
      ),
      disabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
    );

class _LineField extends StatelessWidget {
  const _LineField({
    super.key,
    this.controller,
    this.initialValue,
    this.validator,
    this.keyboardType,
    this.suffixIcon,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      enabled: enabled,
      validator: validator,
      keyboardType: keyboardType,
      decoration: _lineDecoration().copyWith(suffixIcon: suffixIcon),
    );
  }
}

class _FieldWrap extends StatelessWidget {
  const _FieldWrap({required this.label, required this.child, this.trailing});
  final String label;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 12, color: Color(0xFF0D9488)),
          SizedBox(width: 4),
          Text('Verified',
              style: TextStyle(
                  fontSize: 10, color: Color(0xFF0D9488), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _GenderToggle extends StatelessWidget {
  const _GenderToggle({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  static const _options = ['Male', 'Female', 'Other'];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          for (final o in _options)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(o),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: o == value ? AppTheme.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: o == value
                        ? const [BoxShadow(color: Color(0x14000000), blurRadius: 4)]
                        : null,
                  ),
                  child: Text(
                    o,
                    textAlign: TextAlign.center,
                    style: t.labelLarge?.copyWith(
                      color: o == value ? AppTheme.secondary : AppTheme.onSurfaceVariant,
                      fontWeight: o == value ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PrefChip extends StatelessWidget {
  const _PrefChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.secondary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppTheme.secondary : AppTheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? AppTheme.secondary : AppTheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}

class _AvatarEditor extends StatelessWidget {
  const _AvatarEditor();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 128,
          height: 128,
          child: Stack(
            children: [
              Container(
                width: 128,
                height: 128,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.surfaceContainerLow,
                  boxShadow: [
                    BoxShadow(color: Color(0x14000000), blurRadius: 30, offset: Offset(0, 8)),
                  ],
                ),
                child: const Icon(Icons.person, size: 64, color: AppTheme.onSurfaceVariant),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.surface,
                    border: Border.all(color: AppTheme.surface, width: 2),
                    boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 6)],
                  ),
                  child: const Icon(Icons.edit, size: 20, color: AppTheme.secondary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'UPDATE PHOTO',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.onSurfaceVariant,
                letterSpacing: 2,
              ),
        ),
      ],
    );
  }
}
