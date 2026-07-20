import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';
import 'package:smart_stay_ai/features/hotel/presentation/models/hotel_filter.dart';

/// Màn "Filter & Sort": chọn cách sắp xếp, khoảng giá và số sao.
/// Trả [HotelFilter] về màn trước qua `context.pop(result)`.
class FilterSortPage extends StatefulWidget {
  const FilterSortPage({super.key, required this.initial});

  final HotelFilter initial;

  @override
  State<FilterSortPage> createState() => _FilterSortPageState();
}

class _FilterSortPageState extends State<FilterSortPage> {
  late HotelSortBy _sortBy = widget.initial.sortBy;
  late RangeValues _price =
      RangeValues(widget.initial.minPrice, widget.initial.maxPrice);
  late int _minStars = widget.initial.minStars;

  void _reset() {
    setState(() {
      _sortBy = HotelSortBy.recommended;
      _price = const RangeValues(HotelFilter.priceFloor, HotelFilter.priceCeil);
      _minStars = 0;
    });
  }

  void _apply() {
    context.pop(
      HotelFilter(
        sortBy: _sortBy,
        minPrice: _price.start,
        maxPrice: _price.end,
        minStars: _minStars,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            const Divider(height: 1, color: AppColors.creamDark),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                children: [
                  _sectionTitle('Sort By'),
                  const SizedBox(height: 8),
                  ...HotelSortBy.values.map(_sortRow),
                  const SizedBox(height: 24),
                  _sectionTitle('Price Range'),
                  const SizedBox(height: 4),
                  Text(
                    '\$${_price.start.round()} - \$${_price.end.round()}'
                    '${_price.end >= HotelFilter.priceCeil ? '+' : ''}',
                    style: const TextStyle(
                      color: AppColors.goldDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  RangeSlider(
                    values: _price,
                    min: HotelFilter.priceFloor,
                    max: HotelFilter.priceCeil,
                    divisions: 20,
                    activeColor: AppColors.gold,
                    inactiveColor: AppColors.creamDark,
                    labels: RangeLabels(
                      '\$${_price.start.round()}',
                      '\$${_price.end.round()}',
                    ),
                    onChanged: (v) => setState(() => _price = v),
                  ),
                  const SizedBox(height: 16),
                  _sectionTitle('Star Rating'),
                  const SizedBox(height: 12),
                  _starPicker(),
                ],
              ),
            ),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 12, 12),
      child: Row(
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Georgia',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _sortRow(HotelSortBy option) {
    final selected = _sortBy == option;
    return InkWell(
      onTap: () => setState(() => _sortBy = option),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option.label,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? AppColors.gold : AppColors.hint,
            ),
          ],
        ),
      ),
    );
  }

  Widget _starPicker() {
    return Row(
      children: List.generate(5, (i) {
        final value = i + 1;
        final active = value <= _minStars;
        return GestureDetector(
          // Bấm lại ngôi sao đang chọn -> bỏ lọc sao.
          onTap: () => setState(() => _minStars = _minStars == value ? 0 : value),
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              active ? Icons.star : Icons.star_border,
              color: active ? AppColors.gold : AppColors.hint,
              size: 36,
            ),
          ),
        );
      }),
    );
  }

  Widget _footer() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _reset,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.goldDark),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      color: AppColors.goldDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _apply,
                  child: Container(
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.goldLight, AppColors.goldDark],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Show Results',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
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
