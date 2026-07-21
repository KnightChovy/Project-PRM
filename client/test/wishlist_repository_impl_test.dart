import 'package:flutter_test/flutter_test.dart';
import 'package:smart_stay_ai/features/hotel/domain/entities/hotel.dart';
import 'package:smart_stay_ai/features/wishlist/data/datasources/wishlist_local_data_source.dart';
import 'package:smart_stay_ai/features/wishlist/data/models/wishlist_hotel_model.dart';
import 'package:smart_stay_ai/features/wishlist/data/repositories/wishlist_repository_impl.dart';

/// Fake datasource giữ list trong RAM (không chạm shared_preferences thật).
class _FakeLocal implements WishlistLocalDataSource {
  List<Hotel> store;
  _FakeLocal([this.store = const []]);

  @override
  List<WishlistHotelModel> getAll() =>
      store.map(WishlistHotelModel.from).toList();

  @override
  Future<void> saveAll(List<Hotel> hotels) async {
    store = List.of(hotels);
  }
}

Hotel _hotel(String id) => Hotel(
      id: id,
      name: 'Hotel $id',
      location: 'City',
      imageUrl: 'https://x/$id.jpg',
      rating: 4.5,
      reviewCount: 10,
      pricePerNight: 100,
    );

void main() {
  test('getWishlist trả về danh sách đang lưu', () async {
    final repo = WishlistRepositoryImpl(_FakeLocal([_hotel('a')]));

    final result = await repo.getWishlist();

    expect(result.getRight().toNullable()!.map((h) => h.id), ['a']);
  });

  test('toggle thêm khách sạn chưa có (chèn lên đầu)', () async {
    final local = _FakeLocal([_hotel('a')]);
    final repo = WishlistRepositoryImpl(local);

    final result = await repo.toggle(_hotel('b'));

    final list = result.getRight().toNullable()!;
    expect(list.map((h) => h.id), ['b', 'a']);
    // Đã ghi xuống local.
    expect(local.store.map((h) => h.id), ['b', 'a']);
  });

  test('toggle bỏ khách sạn đã có', () async {
    final local = _FakeLocal([_hotel('a'), _hotel('b')]);
    final repo = WishlistRepositoryImpl(local);

    final result = await repo.toggle(_hotel('a'));

    expect(result.getRight().toNullable()!.map((h) => h.id), ['b']);
    expect(local.store.map((h) => h.id), ['b']);
  });
}
