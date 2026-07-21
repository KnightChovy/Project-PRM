import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../entities/paginated.dart';
import '../entities/booking.dart';
import '../entities/booking_status.dart';
import '../repositories/booking_repository.dart';

/// Lấy danh sách booking của tôi, lọc theo trạng thái và phân trang.
class GetMyBookings
    implements UseCase<Paginated<Booking>, GetMyBookingsParams> {
  final BookingRepository repository;
  const GetMyBookings(this.repository);

  @override
  Future<Either<Failure, Paginated<Booking>>> call(
    GetMyBookingsParams params,
  ) {
    return repository.getMine(
      status: params.status,
      page: params.page,
      limit: params.limit,
      sortBy: params.sortBy,
    );
  }
}

class GetMyBookingsParams extends Equatable {
  final BookingStatus? status;
  final int? page;
  final int? limit;
  final String? sortBy;

  const GetMyBookingsParams({
    this.status,
    this.page,
    this.limit,
    this.sortBy,
  });

  @override
  List<Object?> get props => [status, page, limit, sortBy];
}
