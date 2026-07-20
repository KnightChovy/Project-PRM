import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// The four password rules, in display order. value = met?
Map<String, bool> passwordChecks(String v) => {
      '8+ characters': v.length >= 8,
      'One uppercase letter': RegExp(r'[A-Z]').hasMatch(v),
      'One number': RegExp(r'[0-9]').hasMatch(v),
      'One special character': RegExp(r'[^A-Za-z0-9]').hasMatch(v),
    };

/// Validator for the form: returns an error message, or null when all rules pass.
String? validateNewPassword(String? v) {
  if (v == null) return 'At least 8 characters';
  for (final e in passwordChecks(v).entries) {
    if (!e.value) {
      return switch (e.key) {
        '8+ characters' => 'At least 8 characters',
        'One uppercase letter' => 'Add an uppercase letter',
        'One number' => 'Add a number',
        _ => 'Add a special character',
      };
    }
  }
  return null;
}

/// 0 = empty .. 4 = all rules met.
int passwordStrength(String v) =>
    v.isEmpty ? 0 : passwordChecks(v).values.where((m) => m).length;

const _amber = Color(0xFFF59E0B);
const _gold = Color(0xFF8C6D1F);

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Change Password'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            children: [
              Text(
                'Your password must be at least 8 characters long and include a mix of '
                'uppercase letters, numbers, and special characters.',
                style: t.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              _PasswordField(
                label: 'Current Password',
                hint: 'Enter current password',
                controller: _current,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              _PasswordField(
                label: 'New Password',
                hint: 'Enter new password',
                controller: _next,
                validator: validateNewPassword,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              _StrengthMeter(value: _next.text),
              const SizedBox(height: 12),
              _Requirements(value: _next.text),
              const SizedBox(height: 24),
              _PasswordField(
                label: 'Confirm New Password',
                hint: 'Re-enter new password',
                controller: _confirm,
                validator: (v) => v != _next.text ? 'Passwords do not match' : null,
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
                backgroundColor: _gold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _submit,
              child: const Text('Update Password'),
            ),
          ),
        ),
      ),
    );
  }
}

class _StrengthMeter extends StatelessWidget {
  const _StrengthMeter({required this.value});
  final String value;

  static const _labels = ['', 'Weak', 'Fair', 'Good', 'Strong'];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final s = passwordStrength(value);
    final color = switch (s) {
      <= 1 => AppTheme.error,
      2 => _amber,
      3 => _amber,
      _ => const Color(0xFF15803D), // green
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Password Strength',
                style: t.labelSmall?.copyWith(color: AppTheme.onSurfaceVariant)),
            Text(_labels[s], style: t.labelSmall?.copyWith(color: color)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (var i = 0; i < 4; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: i < s ? color : AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _Requirements extends StatelessWidget {
  const _Requirements({required this.value});
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final e in passwordChecks(value).entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    e.value ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 18,
                    color: e.value ? AppTheme.secondary : AppTheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    e.key,
                    style: t.labelLarge?.copyWith(
                      color: e.value ? AppTheme.onSurface : AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.validator,
    this.onChanged,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final ValueChanged<String>? onChanged;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide(color: c),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: t.labelLarge?.copyWith(color: AppTheme.onSurface)),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscure,
          validator: widget.validator,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hint,
            filled: true,
            fillColor: AppTheme.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.onSurfaceVariant),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            enabledBorder: border(AppTheme.surfaceVariant),
            border: border(AppTheme.surfaceVariant),
            focusedBorder: border(AppTheme.secondary),
          ),
        ),
      ],
    );
  }
}
