import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_stay_ai/core/di/injection.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';
import 'package:smart_stay_ai/features/hotel/domain/entities/hotel.dart';
import 'package:smart_stay_ai/features/review/domain/entities/hotel_review.dart';
import 'package:smart_stay_ai/features/review/presentation/providers/hotel_reviews_notifier.dart';

/// Một tiêu chí điểm (Cleanliness, Location...) + phần trăm.
class _Category {
  final String label;
  final int percent;
  const _Category(this.label, this.percent);
}

/// Bộ lọc đánh giá hiển thị dưới dạng chip.
enum _ReviewFilter { all, recent, positive, critical }

/// Màn "Guest Reviews": điểm tổng, phân tích theo tiêu chí, tóm tắt AI
/// và danh sách đánh giá thật của khách (GET /reviews?hotelId=).
class GuestReviewsPage extends StatefulWidget {
  const GuestReviewsPage({super.key, required this.hotel});

  final Hotel hotel;

  @override
  State<GuestReviewsPage> createState() => _GuestReviewsPageState();
}

class _GuestReviewsPageState extends State<GuestReviewsPage> {
  // Factory — mỗi khách sạn một phiên riêng nên ta tự dispose.
  final HotelReviewsNotifier _reviewsN = sl<HotelReviewsNotifier>();
  _ReviewFilter _filter = _ReviewFilter.all;
  int _visible = 3;

  @override
  void initState() {
    super.initState();
    _reviewsN.addListener(_onReviews);
    _reviewsN.load(widget.hotel.id);
  }

  void _onReviews() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _reviewsN.removeListener(_onReviews);
    _reviewsN.dispose();
    super.dispose();
  }

  /// % theo tiêu chí, tính từ chính các đánh giá đã tải.
  List<_Category> _categories() => [
        _Category('Cleanliness', _reviewsN.cleanlinessPercent()),
        _Category('Location', _reviewsN.locationPercent()),
        _Category('Service', _reviewsN.servicePercent()),
        _Category('Value', _reviewsN.valuePercent()),
      ];

  List<HotelReview> get _filtered {
    final all = _reviewsN.reviews;
    switch (_filter) {
      case _ReviewFilter.positive:
        return all.where((r) => r.overall >= 4).toList();
      case _ReviewFilter.critical:
        return all.where((r) => r.overall <= 3).toList();
      case _ReviewFilter.recent:
      case _ReviewFilter.all:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: _body(),
    );
  }

  Widget _body() {
    if (_reviewsN.isLoading && _reviewsN.reviews.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_reviewsN.status == HotelReviewsStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _reviewsN.errorMessage ?? 'Không tải được đánh giá',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final filtered = _filtered;
    final shown = filtered.take(_visible).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        _scoreHeader(),
        const SizedBox(height: 20),
        if (_reviewsN.reviews.isNotEmpty) ...[
          ..._categories().map(_categoryBar),
          const SizedBox(height: 20),
          const _AiSummaryCard(),
          const SizedBox(height: 20),
          _filterChips(),
          const SizedBox(height: 16),
          if (shown.isEmpty) _emptyForFilter() else ...shown.map(_reviewTile),
          if (_visible < filtered.length) ...[
            const SizedBox(height: 8),
            _loadMore(),
          ],
        ] else
          _emptyState(),
      ],
    );
  }

  Widget _scoreHeader() {
    // Điểm hiển thị: trung bình thật từ đánh giá; nếu chưa có thì dùng hạng sao.
    final avg =
        _reviewsN.reviews.isEmpty ? widget.hotel.rating : _reviewsN.averageRating;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              avg.toStringAsFixed(1),
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
          'Based on ${_formatCount(_reviewsN.count)} reviews',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return const Padding(
      padding: EdgeInsets.only(top: 24),
      child: Center(
        child: Text(
          'Chưa có đánh giá nào cho khách sạn này.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _emptyForFilter() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          'Không có đánh giá khớp bộ lọc này.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
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

  Widget _reviewTile(HotelReview r) {
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
              // API không trả avatar → hiển thị chữ cái đầu của tên.
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.goldLight,
                child: Text(
                  _initial(r.authorName),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _formatDate(r.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _stars(r.overall),
            ],
          ),
          if (r.title != null && r.title!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              r.title!,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            r.content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _initial(String name) {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
  }

  /// DateTime → "Oct 2025".
  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.year}';
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
