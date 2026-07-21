import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../repositories/review_repository.dart';

/// Use case: tải một ảnh lên `/uploads`, trả về URL để đính vào đánh giá.
class UploadReviewImage implements UseCase<String, UploadReviewImageParams> {
  final ReviewRepository repository;
  const UploadReviewImage(this.repository);

  @override
  Future<Either<Failure, String>> call(UploadReviewImageParams params) {
    return repository.uploadImage(
      bytes: params.bytes,
      filename: params.filename,
    );
  }
}

/// Một ảnh đã chọn (bytes + tên file) — dùng chung cho cả web lẫn mobile
/// (lấy bytes qua `XFile.readAsBytes`, tránh phụ thuộc `dart:io`).
class UploadReviewImageParams {
  final List<int> bytes;
  final String filename;
  const UploadReviewImageParams({required this.bytes, required this.filename});
}
