import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/exception_to_failure.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/features/hotel/domain/entities/hotel.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_local_data_source.dart';

/// Hiện thực [WishlistRepository] trên bộ nhớ local.
/// `guardApiCall` là chỗ DUY NHẤT đổi Exception → Failure.
class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistLocalDataSource local;
  const WishlistRepositoryImpl(this.local);

  @override
  Future<Either<Failure, List<Hotel>>> getWishlist() {
    return guardApiCall(() async => local.getAll());
  }

  @override
  Future<Either<Failure, List<Hotel>>> toggle(Hotel hotel) {
    return guardApiCall(() async {
      final current = List<Hotel>.from(local.getAll());
      final index = current.indexWhere((h) => h.id == hotel.id);
      if (index >= 0) {
        current.removeAt(index);
      } else {
        // Thêm lên đầu để món vừa lưu hiện trước.
        current.insert(0, hotel);
      }
      await local.saveAll(current);
      return current;
    });
  }
}
