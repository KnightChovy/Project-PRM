import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_stay_ai/core/di/injection.dart';
import 'package:smart_stay_ai/core/router/app_router.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';
import 'package:smart_stay_ai/core/widgets/app_network_image.dart';
import 'package:smart_stay_ai/features/hotel/domain/entities/hotel.dart';
import 'package:smart_stay_ai/features/hotel/presentation/providers/hotel_notifier.dart';

/// Màn "Map View": nền bản đồ tối cách điệu, các ghim giá khách sạn và
/// dải thẻ khách sạn lướt ngang ở đáy.
///
/// NOTE: chưa tích hợp SDK bản đồ thật (google_maps_flutter) — nền + vị trí
/// ghim chỉ mang tính minh hoạ. Khi cần bản đồ thật, thay [_MapBackground]
/// và toạ độ ghim bằng dữ liệu lat/lng.
class MapViewPage extends StatefulWidget {
  const MapViewPage({super.key});

  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  // Singleton dùng chung với Home/Search — dùng lại danh sách đã tải.
  final HotelNotifier _hotelN = sl<HotelNotifier>();
  late final PageController _pageCtrl =
      PageController(viewportFraction: 0.82);
  int _selected = 0;

  // Vị trí ghim trên bản đồ (toạ độ tương đối -1..1) — minh hoạ.
  static const _pinSpots = <Alignment>[
    Alignment(-0.55, -0.45),
    Alignment(0.35, -0.2),
    Alignment(-0.2, 0.15),
    Alignment(0.6, 0.35),
    Alignment(-0.7, 0.45),
    Alignment(0.1, -0.6),
  ];

  List<Hotel> get _hotels => _hotelN.hotels;

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
    _pageCtrl.dispose();
    super.dispose();
  }

  void _selectPin(int i) {
    setState(() => _selected = i);
    _pageCtrl.animateToPage(
      i,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _openHotel(Hotel hotel) =>
      context.push(AppRoutes.hotelDetail, extra: hotel);

  @override
  Widget build(BuildContext context) {
    final hotels = _hotels;
    return Scaffold(
      backgroundColor: AppColors.darkBg2,
      body: Stack(
        children: [
          const Positioned.fill(child: _MapBackground()),
          // Đang tải / lỗi khi chưa có dữ liệu — che giữa bản đồ.
          if (hotels.isEmpty) Positioned.fill(child: Center(child: _mapStatus())),
          // Ghim giá cho từng khách sạn.
          for (var i = 0; i < hotels.length && i < _pinSpots.length; i++)
            Align(
              alignment: _pinSpots[i],
              child: _PricePin(
                price: hotels[i].pricePerNight,
                selected: i == _selected,
                onTap: () => _selectPin(i),
              ),
            ),
          // Thanh tìm kiếm nổi ở trên.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _topBar(),
              ),
            ),
          ),
          // Nút về vị trí hiện tại, nằm ngay trên dải thẻ.
          if (hotels.isNotEmpty)
            Positioned(
              right: 16,
              bottom: 188,
              child: _RoundDarkButton(
                icon: Icons.my_location,
                onTap: () => _selectPin(0),
              ),
            ),
          // Dải thẻ khách sạn lướt ngang ở đáy.
          if (hotels.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 168,
                  child: PageView.builder(
                    controller: _pageCtrl,
                    itemCount: hotels.length,
                    onPageChanged: (i) => setState(() => _selected = i),
                    itemBuilder: (_, i) => _MapHotelCard(
                      hotel: hotels[i],
                      onTap: () => _openHotel(hotels[i]),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Vòng quay khi đang tải hoặc thông báo lỗi (chữ sáng cho nền bản đồ tối).
  Widget _mapStatus() {
    if (_hotelN.status == HotelStatus.error) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          _hotelN.errorMessage ?? 'Không tải được khách sạn',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }
    return const CircularProgressIndicator(color: Colors.white);
  }

  Widget _topBar() {
    return Row(
      children: [
        _RoundDarkButton(icon: Icons.arrow_back, onTap: () => context.pop()),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF332F2A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                Icon(Icons.search, color: AppColors.goldLight, size: 20),
                SizedBox(width: 10),
                Text(
                  'Phu Quoc, Vietnam',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        _RoundDarkButton(icon: Icons.layers_outlined, onTap: () {}),
      ],
    );
  }
}

/// Nền bản đồ tối cách điệu: lưới đường + vài mảng "công viên"/"nước".
class _MapBackground extends StatelessWidget {
  const _MapBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _MapPainter(), size: Size.infinite);
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Nền tối
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.darkBg,
    );

    // Mảng "nước" (xanh đậm) ở góc.
    final water = Paint()..color = const Color(0xFF223240);
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.55, size.height * 0.05, size.width * 0.7,
          size.height * 0.4),
      water,
    );
    canvas.drawOval(
      Rect.fromLTWH(-size.width * 0.25, size.height * 0.55, size.width * 0.6,
          size.height * 0.5),
      water,
    );

    // Mảng "công viên" (xanh lá đậm).
    final park = Paint()..color = const Color(0xFF2C3A2A);
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.3, size.width * 0.35,
          size.height * 0.25),
      park,
    );

    // Lưới đường mờ.
    final road = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.4;
    const step = 70.0;
    for (double x = step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), road);
    }
    for (double y = step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), road);
    }

    // Vài "đại lộ" sáng hơn.
    final avenue = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..strokeWidth = 3;
    canvas.drawLine(
        Offset(0, size.height * 0.35), Offset(size.width, size.height * 0.5), avenue);
    canvas.drawLine(
        Offset(size.width * 0.4, 0), Offset(size.width * 0.55, size.height), avenue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Ghim giá trên bản đồ — phóng to + đổi màu khi được chọn.
class _PricePin extends StatelessWidget {
  const _PricePin({
    required this.price,
    required this.selected,
    required this.onTap,
  });

  final double price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: selected ? 1.12 : 1,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? AppColors.goldDark : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          child: Text(
            '\$${price.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Nút tròn nền tối (back / layers / locate).
class _RoundDarkButton extends StatelessWidget {
  const _RoundDarkButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF332F2A),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

/// Thẻ khách sạn nhỏ (ảnh trái — thông tin phải) trong dải lướt ngang.
class _MapHotelCard extends StatelessWidget {
  const _MapHotelCard({required this.hotel, required this.onTap});

  final Hotel hotel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(color: Colors.black54, blurRadius: 14, offset: Offset(0, 6)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              SizedBox(
                width: 120,
                height: double.infinity,
                child: AppNetworkImage(url: hotel.imageUrl),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        hotel.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hotel.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.gold, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            hotel.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '\$${hotel.pricePerNight.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.goldDark,
                            ),
                          ),
                          const Text(
                            '/night',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
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
