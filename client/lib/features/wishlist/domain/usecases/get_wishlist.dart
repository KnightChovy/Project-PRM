import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import 'package:smart_stay_ai/features/hotel/domain/entities/hotel.dart';
import '../repositories/wishlist_repository.dart';

/// Use case: lấy danh sách khách sạn đã lưu (local).
class GetWishlist implements UseCase<List<Hotel>, NoParams> {
  final WishlistRepository repository;
  const GetWishlist(this.repository);

  @override
  Future<Either<Failure, List<Hotel>>> call(NoParams params) {
    return repository.getWishlist();
  }
}
