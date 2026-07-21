import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_stay_ai/core/di/injection.dart';
import 'package:smart_stay_ai/core/router/app_router.dart';
import 'package:smart_stay_ai/features/auth/presentation/providers/auth_notifier.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';
import 'package:smart_stay_ai/core/widgets/app_message_dialog.dart';

/// Màn hình tạo tài khoản (bước 1 / 2).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _agreed = false;
  bool _sendingCode = false;

  /// Chặn bấm CREATE ACCOUNT nhiều lần.
  ///
  /// Server tiêu thụ mã OTP ngay ở lần gọi đầu, nên lần gọi thứ hai luôn báo
  /// "Invalid or expired verification code" — người dùng thấy đăng ký thất bại
  /// dù tài khoản đã được tạo thành công.
  bool _creatingAccount = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  /// Bước bắt buộc trước khi đăng ký: xin mã OTP 6 chữ số gửi về email.
  Future<void> _sendCode() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      await _showError(
        title: 'Email required',
        message: 'Enter your email address first.',
      );
      return;
    }

    setState(() => _sendingCode = true);
    final auth = sl<AuthNotifier>();
    await auth.sendOtp(email: email);
    if (!mounted) return;
    setState(() => _sendingCode = false);

    if (auth.actionStatus == AuthStatus.success) {
      await showAppMessageDialog(
        context,
        type: AppMessageType.success,
        title: 'Code sent',
        message:
            'We sent a 6-digit verification code to $email. '
            'It expires in 10 minutes.',
      );
    } else {
      // Email đã tồn tại, sai định dạng, lỗi gửi mail...
      await _showError(
        title: 'Could not send code',
        message:
            auth.actionErrorMessage ?? 'Unable to send the verification code.',
      );
    }
  }

  Future<void> _createAccount() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;
    final code = _codeCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      await _showError(
        title: 'Missing information',
        message: 'Please complete all required fields.',
      );
      return;
    }
    if (password != _confirmCtrl.text) {
      await _showError(
        title: 'Passwords do not match',
        message: 'Re-enter the same password in both fields.',
      );
      return;
    }
    if (code.length != 6) {
      await _showError(
        title: 'Verification code required',
        message: 'Enter the 6-digit code sent to your email.',
      );
      return;
    }

    if (_creatingAccount) return;
    setState(() => _creatingAccount = true);

    final auth = sl<AuthNotifier>();
    await auth.register(
      name: name,
      email: email,
      password: password,
      verificationCode: code,
      phone: _phoneCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _creatingAccount = false);

    if (auth.status == AuthStatus.success) {
      context.push(AppRoutes.info);
    } else if (auth.status == AuthStatus.error) {
      // Mã OTP sai/hết hạn, email đã dùng, mật khẩu yếu... đều hiện ở đây.
      await _showError(
        title: 'Registration failed',
        message: auth.errorMessage ?? 'Unable to create your account.',
      );
    }
  }

  Future<void> _showError({
    String title = 'Something went wrong',
    required String message,
  }) {
    return showAppErrorDialog(context, title: title, message: message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Header: logo + bước
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.home_rounded, color: AppColors.gold, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'SmartStay',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'STEP 1 OF 2',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Text(
                'Create Account',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Join our exclusive community for personalized '
                'hospitality experiences.',
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 28),
              _Field(
                controller: _nameCtrl,
                hint: 'Full Name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 14),
              _Field(
                controller: _emailCtrl,
                hint: 'Email Address',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              _Field(
                controller: _phoneCtrl,
                hint: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              _Field(
                controller: _passCtrl,
                hint: 'Password',
                icon: Icons.lock_outline,
                obscure: _obscurePass,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePass ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
              ),
              const SizedBox(height: 14),
              _Field(
                controller: _confirmCtrl,
                hint: 'Confirm Password',
                icon: Icons.lock_outline,
                obscure: _obscureConfirm,
                suffix: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              const SizedBox(height: 14),
              // Mã OTP: backend bắt buộc verificationCode 6 chữ số khi đăng ký.
              _Field(
                controller: _codeCtrl,
                hint: '6-digit Verification Code',
                icon: Icons.verified_outlined,
                keyboardType: TextInputType.number,
                maxLength: 6,
                suffix: TextButton(
                  onPressed: _sendingCode ? null : _sendCode,
                  child: Text(
                    _sendingCode ? 'SENDING…' : 'SEND CODE',
                    style: const TextStyle(
                      color: AppColors.goldDark,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Đồng ý điều khoản
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreed,
                      activeColor: AppColors.goldDark,
                      shape: const CircleBorder(),
                      onChanged: (v) => setState(() => _agreed = v ?? false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              color: AppColors.goldDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: AppColors.goldDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Nút CREATE ACCOUNT (gradient gold)
              _GoldButton(
                label: _creatingAccount ? 'CREATING…' : 'CREATE ACCOUNT',
                onPressed: (_agreed && !_creatingAccount)
                    ? _createAccount
                    : null,
              ),
              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: AppColors.goldDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ô nhập liệu nền trắng bo tròn dùng cho register/info.
class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
    this.maxLength,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        maxLength: maxLength,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
          suffixIcon: suffix,
          counterText: '',
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.hint),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

/// Nút bấm nền gradient gold dùng chung.
class _GoldButton extends StatelessWidget {
  const _GoldButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.goldLight, AppColors.goldDark],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Color(0x338B6F3D),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
