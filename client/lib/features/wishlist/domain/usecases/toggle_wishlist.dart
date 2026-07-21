import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import 'package:smart_stay_ai/features/hotel/domain/entities/hotel.dart';
import '../repositories/wishlist_repository.dart';

/// Use case: bật/tắt lưu một khách sạn vào wishlist. Trả về danh sách MỚI.
class ToggleWishlist implements UseCase<List<Hotel>, Hotel> {
  final WishlistRepository repository;
  const ToggleWishlist(this.repository);

  @override
  Future<Either<Failure, List<Hotel>>> call(Hotel hotel) {
    return repository.toggle(hotel);
  }
}
