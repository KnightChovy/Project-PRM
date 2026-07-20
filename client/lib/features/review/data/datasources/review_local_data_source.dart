import 'package:smart_stay_ai/core/error/exceptions.dart';
import '../models/review_model.dart';

/// Kho lưu đánh giá TẠM trong bộ nhớ (RAM).
///
/// NOTE: khi có backend, thay bằng ReviewRemoteDataSource gọi REST API
/// (POST /reviews). DataSource ném Exception khi lỗi — RepositoryImpl bắt.
abstract interface class ReviewLocalDataSource {
  Future<ReviewModel> save(ReviewModel review);
  List<ReviewModel> getAll();
}

class ReviewLocalDataSourceImpl implements ReviewLocalDataSource {
  final List<ReviewModel> _items = [];

  @override
  Future<ReviewModel> save(ReviewModel review) async {
    try {
      _items.insert(0, review);
      return review;
    } catch (e) {
      throw ServerException(message: 'Không thể lưu đánh giá: $e');
    }
  }

  @override
  List<ReviewModel> getAll() => List.unmodifiable(_items);
}
