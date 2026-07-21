import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_stay_ai/core/di/injection.dart';
import 'package:smart_stay_ai/core/router/app_router.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';
import 'package:smart_stay_ai/core/widgets/app_network_image.dart';
import 'package:smart_stay_ai/features/hotel/domain/entities/hotel.dart';
import 'package:smart_stay_ai/features/wishlist/presentation/providers/wishlist_notifier.dart';

/// Trang "My Wishlist": danh sách khách sạn đã lưu (LOCAL, shared_preferences).
class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  static const _filters = ['All', 'Summer Trip', 'Honeymoon'];

  // Singleton dùng chung với trang chi tiết — không dispose ở đây.
  final WishlistNotifier _wishlistN = sl<WishlistNotifier>();
  int _filter = 0;

  @override
  void initState() {
    super.initState();
    _wishlistN.addListener(_onChanged);
    // Luôn nạp lại khi mở tab để phản ánh thứ vừa lưu ở màn khác.
    _wishlistN.load();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _wishlistN.removeListener(_onChanged);
    super.dispose();
  }

  void _remove(Hotel hotel) => _wishlistN.toggle(hotel);

  void _openDetail(Hotel hotel) {
    context.push(AppRoutes.hotelDetail, extra: hotel);
  }

  void _openSearch() => context.push(AppRoutes.hotelSearch);

  @override
  Widget build(BuildContext context) {
    final saved = _wishlistN.hotels;
    return SafeArea(
      child: Column(
        children: [
          const _TopBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              children: [
                _header(),
                const SizedBox(height: 16),
                const _ConciergeCard(),
                const SizedBox(height: 20),
                _filterChips(),
                const SizedBox(height: 20),
                if (_wishlistN.isLoading && saved.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (saved.isEmpty)
                  _EmptyState(onExplore: _openSearch)
                else
                  ...saved.map(
                    (h) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _WishlistCard(
                        hotel: h,
                        onRemove: () => _remove(h),
                        onTap: () => _openDetail(h),
                        onBook: () => _openDetail(h),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'My Wishlist',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.creamDark,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_wishlistN.hotels.length} saved',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.goldDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Curated stays for your upcoming journeys.',
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final selected = i == _filter;
          return GestureDetector(
            onTap: () => setState(() => _filter = i),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: selected ? AppColors.goldDark : AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.goldLight),
              ),
              child: Text(
                _filters[i],
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Thanh trên cùng: icon trái, "SmartStay", avatar phải.
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.star_border, color: AppColors.textPrimary),
          const Text(
            'SmartStay',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.creamDark,
            child: Icon(Icons.person, size: 18, color: AppColors.goldDark),
          ),
        ],
      ),
    );
  }
}

/// Thẻ "Concierge update" báo giảm giá.
class _ConciergeCard extends StatelessWidget {
  const _ConciergeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.gold, size: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Giá đã giảm ở 2 khách sạn bạn lưu!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'CONCIERGE UPDATE',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1,
                    color: AppColors.goldDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

/// Thẻ một khách sạn đã lưu.
class _WishlistCard extends StatelessWidget {
  const _WishlistCard({
    required this.hotel,
    required this.onRemove,
    required this.onTap,
    required this.onBook,
  });

  final Hotel hotel;
  final VoidCallback onRemove;
  final VoidCallback onTap;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 170,
                  width: double.infinity,
                  child: AppNetworkImage(url: hotel.imageUrl),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.favorite, color: AppColors.gold, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hotel.name,
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      _RatingBadge(rating: hotel.rating),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: AppColors.gold, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        hotel.location,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: _PriceText(hotel: hotel)),
                      GestureDetector(
                        onTap: onBook,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.textPrimary,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Text(
                            'Book',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.creamDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 3),
          const Icon(Icons.star, color: AppColors.gold, size: 16),
        ],
      ),
    );
  }
}

class _PriceText extends StatelessWidget {
  const _PriceText({required this.hotel});
  final Hotel hotel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hotel.hasDiscount)
          Text(
            '\$${hotel.oldPrice!.toStringAsFixed(0)}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '\$${hotel.pricePerNight.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 2),
            const Text(
              '/night',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}

/// Trạng thái rỗng khi chưa lưu khách sạn nào.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onExplore});
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 12, offset: Offset(0, 4)),
              ],
            ),
            child: const Icon(Icons.favorite_border,
                size: 56, color: AppColors.goldLight),
          ),
          const SizedBox(height: 28),
          const Text(
            'Your wishlist is empty',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Bắt đầu lưu những khách sạn bạn thích để tạo nên những chuyến đi '
            'hoàn hảo trong tương lai.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: onExplore,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.goldLight, AppColors.goldDark],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Explore Hotels',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

