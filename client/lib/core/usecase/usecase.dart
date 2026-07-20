import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';

/// Khuôn chung cho MỌI use case: nhận [Params], trả về [Either<Failure, Type>].
/// Quy ước: 1 use case = 1 hành động nghiệp vụ, chỉ có 1 hàm `call()`.
abstract interface class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Dùng khi use case không cần tham số đầu vào.
class NoParams {
  const NoParams();
}
