import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_stay_ai/core/di/injection.dart';
import 'package:smart_stay_ai/core/router/app_router.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';
import 'package:smart_stay_ai/features/hotel/domain/entities/hotel.dart';
import 'package:smart_stay_ai/features/hotel/presentation/models/hotel_filter.dart';
import 'package:smart_stay_ai/features/hotel/presentation/providers/hotel_notifier.dart';
import 'package:smart_stay_ai/features/hotel/presentation/widgets/hotel_card.dart';

/// Màn kết quả tìm kiếm khách sạn: ô search, nút Filter & Sort, nút Map View
/// và danh sách thẻ khách sạn đã lọc/sắp xếp.
class HotelSearchPage extends StatefulWidget {
  const HotelSearchPage({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<HotelSearchPage> createState() => _HotelSearchPageState();
}

class _HotelSearchPageState extends State<HotelSearchPage> {
  // Singleton dùng chung với Home/Map — nếu Home đã tải thì không gọi API lại.
  final HotelNotifier _hotelN = sl<HotelNotifier>();
  late final TextEditingController _queryCtrl =
      TextEditingController(text: widget.initialQuery);
  HotelFilter _filter = const HotelFilter();

  @override
  void initState() {
    super.initState();
    _hotelN.addListener(_onHotels);
    if (_hotelN.status == HotelStatus.initial) _hotelN.load();
  }

  void _onHotels() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _hotelN.removeListener(_onHotels);
    _queryCtrl.dispose();
    super.dispose();
  }

  /// Lọc theo từ khoá (tên/địa điểm) rồi áp [HotelFilter].
  List<Hotel> get _results {
    final q = _queryCtrl.text.trim().toLowerCase();
    final source = _hotelN.hotels;
    final byQuery = q.isEmpty
        ? source
        : source
            .where((h) =>
                h.name.toLowerCase().contains(q) ||
                h.location.toLowerCase().contains(q))
            .toList();
    return _filter.apply(byQuery);
  }

  Future<void> _openFilter() async {
    final result =
        await context.push<HotelFilter>(AppRoutes.filterSort, extra: _filter);
    if (result != null && mounted) {
      setState(() => _filter = result);
    }
  }

  void _openMap() => context.push(AppRoutes.mapView);

  void _openHotel(Hotel hotel) =>
      context.push(AppRoutes.hotelDetail, extra: hotel);

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _searchRow(),
            _toolbar(results.length),
            Expanded(child: _body(results)),
          ],
        ),
      ),
    );
  }

  /// Thân danh sách: ưu tiên loading (khi chưa có dữ liệu) → lỗi → kết quả.
  Widget _body(List<Hotel> results) {
    if (_hotelN.isLoading && _hotelN.hotels.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_hotelN.status == HotelStatus.error && _hotelN.hotels.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _hotelN.errorMessage ?? 'Không tải được danh sách khách sạn',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }
    if (results.isEmpty) return _empty();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 18),
      itemBuilder: (_, i) => HotelCard(
        hotel: results[i],
        onTap: () => _openHotel(results[i]),
      ),
    );
  }

  Widget _searchRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.gold, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _queryCtrl,
                      textInputAction: TextInputAction.search,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Where do you want to stay?',
                        hintStyle: TextStyle(color: AppColors.hint),
                        border: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                  if (_queryCtrl.text.isNotEmpty)
                    GestureDetector(
                      onTap: () => setState(() => _queryCtrl.clear()),
                      child: const Icon(Icons.close,
                          color: AppColors.textSecondary, size: 18),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolbar(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Row(
        children: [
          Text(
            '$count stays found',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          _toolButton(
            icon: Icons.map_outlined,
            label: 'Map',
            onTap: _openMap,
          ),
          const SizedBox(width: 10),
          _toolButton(
            icon: Icons.tune,
            label: 'Filter',
            onTap: _openFilter,
            badge: _filter.activeCount,
          ),
        ],
      ),
    );
  }

  Widget _toolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    int badge = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.creamDark),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.goldDark),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            if (badge > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.search_off, size: 56, color: AppColors.goldLight),
          SizedBox(height: 12),
          Text(
            'No stays match your filters',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
