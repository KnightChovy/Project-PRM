import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../entities/destination.dart';
import '../repositories/hotel_repository.dart';

/// Use case: lấy danh sách điểm đến phổ biến.
class GetDestinations implements UseCase<List<Destination>, NoParams> {
  final HotelRepository repository;
  const GetDestinations(this.repository);

  @override
  Future<Either<Failure, List<Destination>>> call(NoParams params) {
    return repository.getDestinations();
  }
}
