import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_stay_ai/core/router/app_router.dart';
import 'package:smart_stay_ai/core/session/app_session.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';
import 'package:smart_stay_ai/core/widgets/app_network_image.dart';
import 'package:smart_stay_ai/features/profile/presentation/providers/profile_notifier.dart';
import 'package:smart_stay_ai/features/hotel/domain/entities/hotel.dart';
import 'package:smart_stay_ai/features/hotel/presentation/demo_hotels.dart';
import 'package:smart_stay_ai/features/hotel/presentation/widgets/hotel_card.dart';

/// Trang chủ (tab Home): lời chào, ô tìm kiếm, gợi ý AI, điểm đến phổ biến
/// và danh sách khách sạn nổi bật.
///
/// NOTE: dùng [kDemoHotels]. Khi có backend, lấy qua UseCase + Notifier.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openHotel(BuildContext context, Hotel hotel) {
    context.push(AppRoutes.hotelDetail, extra: hotel);
  }

  void _openSearch(BuildContext context) {
    context.push(AppRoutes.hotelSearch);
  }

  @override
  Widget build(BuildContext context) {
    final aiPicks = kDemoHotels.take(3).toList();
    final featured = kDemoHotels.skip(1).toList();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const _Header(),
          const SizedBox(height: 20),
          _SearchBar(onTap: () => _openSearch(context)),
          const SizedBox(height: 28),
          _SectionTitle(
            title: 'Your AI Picks Today',
            trailing: const Icon(Icons.auto_awesome,
                color: AppColors.gold, size: 20),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 230,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              itemCount: aiPicks.length,
              separatorBuilder: (_, _) => const SizedBox(width: 16),
              itemBuilder: (_, i) {
                final hotel = aiPicks[i];
                return _AiPickCard(
                  hotel: hotel,
                  matchPercent: 96 - i * 4,
                  onTap: () => _openHotel(context, hotel),
                );
              },
            ),
          ),
          const SizedBox(height: 28),
          _SectionTitle(title: 'Popular Destinations'),
          const SizedBox(height: 14),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kPopularDestinations.length,
              separatorBuilder: (_, _) => const SizedBox(width: 18),
              itemBuilder: (_, i) =>
                  _DestinationItem(destination: kPopularDestinations[i]),
            ),
          ),
          const SizedBox(height: 28),
          _SectionTitle(
            title: 'Featured Hotels',
            trailing: GestureDetector(
              onTap: () => _openSearch(context),
              child: const Text(
                'See all',
                style: TextStyle(
                  color: AppColors.goldDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          ...featured.map(
            (h) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: HotelCard(hotel: h, onTap: () => _openHotel(context, h)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lời chào + chuông thông báo + avatar (hoặc nút đăng nhập cho khách).
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    // Nghe CẢ HAI: AppSession báo lúc đăng nhập/đăng xuất, ProfileNotifier báo
    // khi có tên và ảnh thật. Thiếu cái nào thì header cũng đứng im sai trạng
    // thái cho tới lần vẽ lại tiếp theo.
    return Consumer2<AppSession, ProfileNotifier>(
      builder: (context, session, notifier, _) {
        final signedIn = session.isSignedIn;
        final profile = notifier.profile;

        // Vừa đăng nhập ở màn khác quay về đây thì hồ sơ chưa được tải.
        if (signedIn && notifier.status == ProfileStatus.initial) {
          // Hoãn sang sau khung hình: gọi notifyListeners ngay trong build sẽ
          // ném "setState() called during build".
          WidgetsBinding.instance.addPostFrameCallback((_) => notifier.load());
        }

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    signedIn
                        ? 'Xin chào, ${_firstName(profile?.fullName)} 👋'
                        : 'Chào bạn 👋',
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Find your perfect stay',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (signedIn) ...[
              _circleIcon(Icons.notifications_none, badge: true),
              const SizedBox(width: 12),
              _HomeAvatar(url: profile?.avatarUrl),
            ] else
              // Khách vãng lai: không có avatar để hiện, đưa luôn lối đăng nhập.
              const _SignInButton(),
          ],
        );
      },
    );
  }

  /// Chỉ lấy tên gọi để lời chào không bị tràn trên màn hình hẹp.
  String _firstName(String? fullName) {
    final full = (fullName ?? '').trim();
    if (full.isEmpty) return 'bạn';
    return full.split(' ').last;
  }

  Widget _circleIcon(IconData icon, {bool badge = false}) {
    return Stack(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 22),
        ),
        if (badge)
          Positioned(
            top: 10,
            right: 11,
            child: Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

/// Ảnh đại diện thật của người đang đăng nhập.
///
/// KHÔNG dùng ảnh mẫu như trước (`pravatar.cc`) — người dùng tưởng đó là ảnh
/// của mình, mà khách chưa đăng nhập cũng thấy nên trông như đã có tài khoản.
class _HomeAvatar extends StatelessWidget {
  const _HomeAvatar({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final hasImage = url != null && url!.isNotEmpty;
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.goldLight,
      foregroundImage: hasImage ? NetworkImage(url!) : null,
      child: hasImage
          ? null
          : const Icon(Icons.person, size: 24, color: AppColors.textPrimary),
    );
  }
}

/// Lối vào đăng nhập cho khách vãng lai, thay chỗ của avatar.
class _SignInButton extends StatelessWidget {
  const _SignInButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.goldDark,
        foregroundColor: Colors.white,
        // Cao 44px cho dễ chạm bằng ngón tay trên điện thoại.
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      onPressed: () => context.push(AppRoutes.login),
      child: const Text(
        'Đăng nhập',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Ô tìm kiếm "Where do you want to stay?" — chạm vào mở màn Search.
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: const [
            Icon(Icons.search, color: AppColors.gold),
            SizedBox(width: 12),
            Text(
              'Where do you want to stay?',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
            Spacer(),
            Icon(Icons.tune, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// Tiêu đề một mục + (tuỳ chọn) widget bên phải.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        const Spacer(),
        ?trailing,
      ],
    );
  }
}

/// Thẻ gợi ý AI (lướt ngang): ảnh nền + nhãn % hợp + tên + giá.
class _AiPickCard extends StatelessWidget {
  const _AiPickCard({
    required this.hotel,
    required this.matchPercent,
    required this.onTap,
  });

  final Hotel hotel;
  final int matchPercent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 250,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppNetworkImage(url: hotel.imageUrl),
              // Lớp phủ tối ở đáy để chữ trắng dễ đọc.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                    stops: [0.45, 1],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome,
                          color: AppColors.gold, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '$matchPercent% match',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name,
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hotel.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '\$${hotel.pricePerNight.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          ' /night',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Một điểm đến tròn (ảnh + tên) trong "Popular Destinations".
class _DestinationItem extends StatelessWidget {
  const _DestinationItem({required this.destination});

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          clipBehavior: Clip.antiAlias,
          child: AppNetworkImage(url: destination.imageUrl),
        ),
        const SizedBox(height: 8),
        Text(
          destination.name,
          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
