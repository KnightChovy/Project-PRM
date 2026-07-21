import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_stay_ai/core/error/exceptions.dart';
import 'package:smart_stay_ai/features/hotel/domain/entities/hotel.dart';
import '../models/wishlist_hotel_model.dart';

/// Lưu wishlist NGAY TRÊN MÁY (shared_preferences) — backend chưa có API wishlist.
/// Lỗi ghi thì NÉM Exception (RepositoryImpl đổi thành Failure).
abstract interface class WishlistLocalDataSource {
  List<WishlistHotelModel> getAll();
  Future<void> saveAll(List<Hotel> hotels);
}

class WishlistLocalDataSourceImpl implements WishlistLocalDataSource {
  final SharedPreferences prefs;
  const WishlistLocalDataSourceImpl(this.prefs);

  static const _key = 'wishlist_hotels_v1';

  @override
  List<WishlistHotelModel> getAll() {
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(WishlistHotelModel.fromJson)
          .toList();
    } catch (_) {
      // Dữ liệu local hỏng thì coi như wishlist rỗng thay vì làm sập màn hình.
      return const [];
    }
  }

  @override
  Future<void> saveAll(List<Hotel> hotels) async {
    try {
      final data =
          hotels.map((h) => WishlistHotelModel.from(h).toJson()).toList();
      await prefs.setString(_key, jsonEncode(data));
    } catch (e) {
      throw ServerException(message: 'Không lưu được wishlist: $e');
    }
  }
}
