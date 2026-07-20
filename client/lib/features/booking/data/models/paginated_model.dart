import '../../domain/entities/paginated.dart';
import 'json_reader.dart';

/// Dựng [Paginated] từ body của endpoint danh sách.
///
/// Spec chưa mô tả rõ envelope phân trang, nên chấp nhận cả hai dạng hay gặp:
/// một mảng trần, hoặc `{ results, page, limit, totalPages, totalResults }`.
Paginated<T> parsePaginated<T>(
  Object? data,
  T Function(Map<String, dynamic> json) itemMapper,
) {
  if (data is List) {
    final items = data
        .whereType<Map<String, dynamic>>()
        .map(itemMapper)
        .toList(growable: false);
    return Paginated<T>(
      items: items,
      page: 1,
      limit: items.length,
      totalPages: 1,
      totalResults: items.length,
    );
  }

  if (data is Map<String, dynamic>) {
    final items = data
        .readMapList('results')
        .map(itemMapper)
        .toList(growable: false);
    return Paginated<T>(
      items: items,
      page: data.readInt('page') ?? 1,
      limit: data.readInt('limit') ?? items.length,
      totalPages: data.readInt('totalPages') ?? 1,
      totalResults: data.readInt('totalResults') ?? items.length,
    );
  }

  return Paginated<T>(
    items: const [],
    page: 1,
    limit: 0,
    totalPages: 1,
    totalResults: 0,
  );
}
