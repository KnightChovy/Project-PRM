import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_message_dialog.dart';
import '../../domain/entities/profile_update.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_notifier.dart';

/// Edit Profile — form gắn thẳng vào `PATCH /v1/users/me`.
///
/// Các field ở đây là ĐÚNG tập field mà Joi phía server chấp nhận. Backend
/// không có cột `gender` lẫn `address` nên hai ô đó đã bị bỏ, và tên được gộp
/// về một ô `fullName` thay vì First/Last (server chỉ lưu một chuỗi).
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _notifier = sl<ProfileNotifier>();
  final _formKey = GlobalKey<FormState>();

  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _nationality = TextEditingController();
  final _idCard = TextEditingController();
  final _passport = TextEditingController();

  DateTime? _dob;
  String _language = 'vi';
  String _currency = 'VND';

  /// Hồ sơ lúc mở màn — dùng để chỉ gửi lên những field thực sự đổi.
  UserProfile? _original;

  static const _allPrefs = [
    'Beach',
    'City',
    'Culture',
    'Mountain',
    'Adventure',
    'Wellness',
  ];
  final _prefs = <String>{};

  @override
  void initState() {
    super.initState();
    _seedFrom(_notifier.profile);
    // Vào thẳng màn này (deep-link / chưa mở tab Profile) thì hồ sơ chưa có.
    if (_notifier.profile == null) {
      _notifier.load().then((_) {
        if (mounted) setState(() => _seedFrom(_notifier.profile));
      });
    }
  }

  void _seedFrom(UserProfile? profile) {
    if (profile == null) return;
    _original = profile;
    _fullName.text = profile.fullName;
    _phone.text = profile.phone ?? '';
    _nationality.text = profile.nationality ?? '';
    _idCard.text = profile.idCardNumber ?? '';
    _passport.text = profile.passportNumber ?? '';
    _dob = profile.dateOfBirth;
    _language = profile.preferredLanguage;
    _currency = profile.preferredCurrency;
  }

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _nationality.dispose();
    _idCard.dispose();
    _passport.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(1995),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  /// Chỉ đưa vào body những field NGƯỜI DÙNG ĐÃ SỬA.
  ///
  /// Gửi cả form sẽ ghi đè dữ liệu do màn khác vừa đổi, còn gửi body rỗng thì
  /// server trả 400 ("min 1 key") — nên phải so với [_original].
  ProfileUpdate _buildChanges(UserProfile original) {
    String? changedText(String current, String? before) {
      final trimmed = current.trim();
      return trimmed == (before ?? '') ? null : trimmed;
    }

    return ProfileUpdate(
      fullName: changedText(_fullName.text, original.fullName),
      phone: changedText(_phone.text, original.phone),
      nationality: changedText(_nationality.text, original.nationality),
      idCardNumber: changedText(_idCard.text, original.idCardNumber),
      passportNumber: changedText(_passport.text, original.passportNumber),
      dateOfBirth: _dob == original.dateOfBirth ? null : _dob,
      preferredLanguage: _language == original.preferredLanguage
          ? null
          : _language,
      preferredCurrency: _currency == original.preferredCurrency
          ? null
          : _currency,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Lấy mốc so sánh MỚI NHẤT chứ không dùng ảnh chụp lúc initState:
    // ProfileNotifier là singleton, màn Notification Settings có thể đã đổi
    // marketingOptIn trong lúc form này đang mở.
    final original = _notifier.profile ?? _original;
    if (original == null) return;

    final changes = _buildChanges(original);
    if (changes.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    final ok = await _notifier.save(changes);
    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop();
      return;
    }
    await showAppErrorDialog(
      context,
      title: 'Không lưu được',
      message: _notifier.actionErrorMessage ?? 'Vui lòng thử lại.',
    );
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String get _dobLabel {
    final dob = _dob;
    if (dob == null) return 'Chưa chọn';
    return '${_months[dob.month - 1]} ${dob.day}, ${dob.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _notifier,
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('Edit Profile'),
        ),
        body: SafeArea(
          child: Consumer<ProfileNotifier>(
            builder: (context, notifier, _) {
              final profile = notifier.profile;
              if (profile == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  children: [
                    _AvatarEditor(url: profile.avatarUrl),
                    const SizedBox(height: 40),
                    _FieldWrap(
                      label: 'Full Name',
                      child: _LineField(
                        controller: _fullName,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Vui lòng nhập họ tên'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FieldWrap(
                      label: 'Email',
                      // Email chỉ đọc: `PATCH /users/me` không nhận field này.
                      trailing: profile.isEmailVerified
                          ? const _VerifiedBadge()
                          : null,
                      child: _LineField(
                        key: ValueKey(profile.email),
                        initialValue: profile.email,
                        enabled: false,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FieldWrap(
                      label: 'Phone Number',
                      child: _LineField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                      ),
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
                            suffixIcon: const Icon(
                              Icons.calendar_month,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Server để nationality là chuỗi tự do (max 100) chứ không
                    // phải enum, nên dùng ô nhập thay cho dropdown cố định.
                    _FieldWrap(
                      label: 'Nationality',
                      child: _LineField(controller: _nationality),
                    ),
                    const SizedBox(height: 16),
                    _FieldWrap(
                      label: 'ID Card Number',
                      child: _LineField(controller: _idCard),
                    ),
                    const SizedBox(height: 16),
                    _FieldWrap(
                      label: 'Passport Number',
                      child: _LineField(controller: _passport),
                    ),
                    const SizedBox(height: 24),
                    _FieldWrap(
                      label: 'Language',
                      child: _ChoiceToggle(
                        value: _language,
                        options: const {'vi': 'Tiếng Việt', 'en': 'English'},
                        onChanged: (v) => setState(() => _language = v),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _FieldWrap(
                      label: 'Currency',
                      child: _ChoiceToggle(
                        value: _currency,
                        options: const {'VND': 'VND', 'USD': 'USD'},
                        onChanged: (v) => setState(() => _currency = v),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Travel Preferences',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    // TODO(backend): chưa có API lưu sở thích du lịch — chọn ở
                    // đây chỉ sống trong phiên, thoát màn là mất.
                    Text(
                      'Chưa được lưu lên máy chủ.',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
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
                              () => _prefs.contains(p)
                                  ? _prefs.remove(p)
                                  : _prefs.add(p),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: Consumer<ProfileNotifier>(
                builder: (context, notifier, _) => FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.secondary,
                    foregroundColor: AppTheme.onSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: notifier.isSaving ? null : _save,
                  child: notifier.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.onSecondary,
                          ),
                        )
                      : const Text(
                          'SAVE CHANGES',
                          style: TextStyle(
                            letterSpacing: 2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
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
    borderSide: BorderSide(
      color: AppTheme.outlineVariant.withValues(alpha: 0.3),
    ),
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
          Text(
            'Verified',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF0D9488),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Nhóm nút chọn 1-trong-N.
///
/// [options] map giá trị GỬI LÊN API → nhãn hiển thị, để UI đổi chữ mà không
/// làm sai payload (ví dụ hiện "Tiếng Việt" nhưng gửi `vi`).
class _ChoiceToggle extends StatelessWidget {
  const _ChoiceToggle({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String value;
  final Map<String, String> options;
  final ValueChanged<String> onChanged;

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
          for (final entry in options.entries)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(entry.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: entry.key == value
                        ? AppTheme.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: entry.key == value
                        ? const [
                            BoxShadow(color: Color(0x14000000), blurRadius: 4),
                          ]
                        : null,
                  ),
                  child: Text(
                    entry.value,
                    textAlign: TextAlign.center,
                    style: t.labelLarge?.copyWith(
                      color: entry.key == value
                          ? AppTheme.secondary
                          : AppTheme.onSurfaceVariant,
                      fontWeight: entry.key == value
                          ? FontWeight.w600
                          : FontWeight.w500,
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
  const _PrefChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
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
          color: selected
              ? AppTheme.secondary.withValues(alpha: 0.1)
              : Colors.transparent,
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

/// Ảnh đại diện hiện tại.
///
/// TODO(client): chưa cho đổi ảnh — luồng đầy đủ là `POST /v1/uploads`
/// (multipart, field `file`) rồi `PATCH /users/me { avatarUrl }`, nhưng chọn
/// ảnh cần thêm dependency `image_picker` nên tách sang thay đổi riêng.
/// Lưu ý khi làm: enum `folder` phía server KHÔNG có giá trị `avatars`,
/// bỏ trống query đó thì file rơi vào thư mục `misc`.
class _AvatarEditor extends StatelessWidget {
  const _AvatarEditor({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final hasImage = url != null && url!.isNotEmpty;
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.surfaceContainerLow,
                  image: hasImage
                      ? DecorationImage(
                          image: NetworkImage(url!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 30,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: hasImage
                    ? null
                    : const Icon(
                        Icons.person,
                        size: 64,
                        color: AppTheme.onSurfaceVariant,
                      ),
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
                    boxShadow: const [
                      BoxShadow(color: Color(0x1F000000), blurRadius: 6),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 20,
                    color: AppTheme.secondary,
                  ),
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
