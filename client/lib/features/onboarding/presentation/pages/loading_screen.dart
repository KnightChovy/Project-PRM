import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_stay_ai/core/di/injection.dart';
import 'package:smart_stay_ai/core/router/app_router.dart';
import 'package:smart_stay_ai/core/session/app_session.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';

/// Màn hình khởi động (splash) hiển thị khi mở app.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scale = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    // Sau ~2.6s rời splash. Ai đã đăng nhập lần trước thì vào thẳng màn chính.
    //
    // Token vẫn nằm trong SharedPreferences nhưng trước đây không ai đọc lúc
    // khởi động, nên người dùng bị bắt đăng nhập lại mỗi lần mở app dù phiên
    // còn hạn. Access token hết hạn cũng không sao: ApiInterceptor sẽ tự làm
    // mới bằng refresh token ở request đầu tiên.
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      context.go(
        sl<AppSession>().isSignedIn ? AppRoutes.home : AppRoutes.onboarding,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.9,
            colors: [AppColors.darkBg, AppColors.darkBg2],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo ngôi nhà với hiệu ứng phát sáng
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha: 0.35),
                                blurRadius: 60,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: const _HouseLogo(),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'SmartStay',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Thanh chỉ báo dưới đáy
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Container(
                    width: 120,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.goldLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Logo ngôi nhà vẽ bằng icon (kèm ngôi sao lấp lánh).
class _HouseLogo extends StatelessWidget {
  const _HouseLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.home_outlined, size: 90, color: AppColors.gold),
          Positioned(
            right: -6,
            top: -2,
            child: Icon(
              Icons.auto_awesome,
              size: 22,
              color: AppColors.goldLight,
            ),
          ),
        ],
      ),
    );
  }
}
