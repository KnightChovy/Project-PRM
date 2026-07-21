import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/features/hotel/domain/entities/hotel.dart';

/// Hợp đồng wishlist (lưu LOCAL). Domain khai báo, Data hiện thực.
abstract interface class WishlistRepository {
  /// Danh sách khách sạn đã lưu.
  Future<Either<Failure, List<Hotel>>> getWishlist();

  /// Bật/tắt lưu một khách sạn; trả về danh sách MỚI sau khi đổi.
  Future<Either<Failure, List<Hotel>>> toggle(Hotel hotel);
}
