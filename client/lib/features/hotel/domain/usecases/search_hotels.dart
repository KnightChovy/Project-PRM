import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../entities/hotel.dart';
import '../repositories/hotel_repository.dart';

/// Use case: tìm/lấy danh sách khách sạn.
class SearchHotels implements UseCase<List<Hotel>, SearchHotelsParams> {
  final HotelRepository repository;
  const SearchHotels(this.repository);

  @override
  Future<Either<Failure, List<Hotel>>> call(SearchHotelsParams params) {
    return repository.searchHotels(
      city: params.city,
      page: params.page,
      limit: params.limit,
      sortBy: params.sortBy,
    );
  }
}

class SearchHotelsParams extends Equatable {
  final String? city;
  final int? page;
  final int? limit;
  final String? sortBy;

  const SearchHotelsParams({this.city, this.page, this.limit, this.sortBy});

  @override
  List<Object?> get props => [city, page, limit, sortBy];
}
