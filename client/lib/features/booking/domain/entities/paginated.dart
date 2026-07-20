import 'package:equatable/equatable.dart';

/// Một trang kết quả từ API danh sách.
class Paginated<T> extends Equatable {
  final List<T> items;
  final int page;
  final int limit;
  final int totalPages;
  final int totalResults;

  const Paginated({
    required this.items,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.totalResults,
  });

  bool get hasNextPage => page < totalPages;

  @override
  List<Object?> get props => [items, page, limit, totalPages, totalResults];
}
