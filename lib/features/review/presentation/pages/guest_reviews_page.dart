import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';
import 'package:smart_stay_ai/features/hotel/domain/entities/hotel.dart';

/// Một đánh giá của khách (hiển thị) — khác `Review` ở domain (vốn dành cho
/// "đánh giá của chính tôi"): ở đây cần tên + avatar người đánh giá.
class _GuestReview {
  final String name;
  final String avatarUrl;
  final String date;
  final int stars;
  final String comment;
  final int helpful;

  const _GuestReview({
    required this.name,
    required this.avatarUrl,
    required this.date,
    required this.stars,
    required this.comment,
    required this.helpful,
  });
}

/// Một tiêu chí điểm (Cleanliness, Location...) + phần trăm.
class _Category {
  final String label;
  final int percent;
  const _Category(this.label, this.percent);
}

/// Bộ lọc đánh giá hiển thị dưới dạng chip.
enum _ReviewFilter { all, recent, positive, critical }

/// Màn "Guest Reviews": điểm tổng, phân tích theo tiêu chí, tóm tắt AI
/// và danh sách đánh giá của khách.
///
/// NOTE: dùng dữ liệu mẫu [_demoReviews]. Khi có backend, lấy theo hotelId
/// qua UseCase + Notifier.
class GuestReviewsPage extends StatefulWidget {
  const GuestReviewsPage({super.key, required this.hotel});

  final Hotel hotel;

  @override
  State<GuestReviewsPage> createState() => _GuestReviewsPageState();
}

class _GuestReviewsPageState extends State<GuestReviewsPage> {
  _ReviewFilter _filter = _ReviewFilter.all;
  int _visible = 3;

  static const _categories = <_Category>[
    _Category('Cleanliness', 96),
    _Category('Location', 98),
    _Category('Service', 94),
    _Category('Value', 88),
    _Category('Comfort', 92),
  ];

  static const _demoReviews = <_GuestReview>[
    _GuestReview(
      name: 'James Wilson',
      avatarUrl: 'https://i.pravatar.cc/150?img=33',
      date: 'Oct 2025',
      stars: 5,
      comment:
          'An absolute dream. The AI recommendation was spot on — the wellness '
          'spa is world-class. Breakfast by the bay every morning was unforgettable.',
      helpful: 12,
    ),
    _GuestReview(
      name: 'Sophie Chen',
      avatarUrl: 'https://i.pravatar.cc/150?img=45',
      date: 'Sep 2025',
      stars: 4,
      comment:
          'Stunning views. Service was impeccable, though the check-in took a bit '
          'longer than expected. Worth every penny for the privacy.',
      helpful: 8,
    ),
    _GuestReview(
      name: 'Daniel Pham',
      avatarUrl: 'https://i.pravatar.cc/150?img=15',
      date: 'Sep 2025',
      stars: 5,
      comment:
          'The infinity pool villa is breathtaking. Staff remembered our names and '
          'preferences. Will definitely return.',
      helpful: 6,
    ),
    _GuestReview(
      name: 'Mai Tran',
      avatarUrl: 'https://i.pravatar.cc/150?img=20',
      date: 'Aug 2025',
      stars: 3,
      comment:
          'Beautiful resort but the WiFi was unreliable in the villas, which made '
          'remote work difficult. Everything else was excellent.',
      helpful: 4,
    ),
    _GuestReview(
      name: 'Lucas Meyer',
      avatarUrl: 'https://i.pravatar.cc/150?img=52',
      date: 'Aug 2025',
      stars: 5,
      comment:
          'Privacy and tranquility at its finest. The lakeside spa treatment was '
          'the highlight of our honeymoon.',
      helpful: 9,
    ),
  ];

  List<_GuestReview> get _filtered {
    switch (_filter) {
      case _ReviewFilter.positive:
        return _demoReviews.where((r) => r.stars >= 4).toList();
      case _ReviewFilter.critical:
        return _demoReviews.where((r) => r.stars <= 3).toList();
      case _ReviewFilter.recent:
      case _ReviewFilter.all:
        return _demoReviews;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;
    final filtered = _filtered;
    final shown = filtered.take(_visible).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: const Text(
          'Guest Reviews',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          _scoreHeader(hotel),
          const SizedBox(height: 20),
          ..._categories.map(_categoryBar),
          const SizedBox(height: 20),
          const _AiSummaryCard(),
          const SizedBox(height: 20),
          _filterChips(),
          const SizedBox(height: 16),
          ...shown.map(_reviewTile),
          if (_visible < filtered.length) ...[
            const SizedBox(height: 8),
            _loadMore(),
          ],
        ],
      ),
    );
  }

  Widget _scoreHeader(Hotel hotel) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              hotel.rating.toStringAsFixed(1),
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.star, color: AppColors.gold, size: 36),
          ],
        ),
        Text(
          'Based on ${_formatCount(hotel.reviewCount)} reviews',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _categoryBar(_Category c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              c.label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: c.percent / 100,
                minHeight: 8,
                backgroundColor: AppColors.creamDark,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.gold),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 36,
            child: Text(
              '${c.percent}%',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChips() {
    const labels = {
      _ReviewFilter.all: 'All',
      _ReviewFilter.recent: 'Most Recent',
      _ReviewFilter.positive: 'Positive',
      _ReviewFilter.critical: 'Critical',
    };
    return Wrap(
      spacing: 10,
      children: _ReviewFilter.values.map((f) {
        final selected = _filter == f;
        return GestureDetector(
          onTap: () => setState(() {
            _filter = f;
            _visible = 3;
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: selected ? AppColors.goldDark : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? AppColors.goldDark : AppColors.creamDark,
              ),
            ),
            child: Text(
              labels[f]!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _reviewTile(_GuestReview r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.goldLight,
                backgroundImage: NetworkImage(r.avatarUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      r.date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _stars(r.stars),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            r.comment,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.thumb_up_outlined,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                '${r.helpful} found helpful',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stars(int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < count ? Icons.star : Icons.star_border,
          size: 16,
          color: AppColors.gold,
        ),
      ),
    );
  }

  Widget _loadMore() {
    return Center(
      child: OutlinedButton(
        onPressed: () => setState(() => _visible += 3),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          side: const BorderSide(color: AppColors.goldDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Load More',
          style: TextStyle(
            color: AppColors.goldDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 1284 -> "1,284" (thêm dấu phẩy ngăn cách hàng nghìn).
  String _formatCount(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

/// Thẻ tóm tắt đánh giá bằng AI (nền xanh nhạt).
class _AiSummaryCard extends StatelessWidget {
  const _AiSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F2F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.auto_awesome, color: Color(0xFF2F7E78), size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Review Summary',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F7E78),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Guests love the ocean view and breakfast. Minor complaints '
                  'about slow WiFi in some villas.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF3D6D69),
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
