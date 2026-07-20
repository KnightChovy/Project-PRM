import 'package:smart_stay_ai/core/error/exceptions.dart';

/// Tiện ích đọc JSON an toàn cho tầng Data.
///
/// API có thể đổi/thiếu field, và một `as String` trần sẽ ném [TypeError] —
/// loại lỗi không đi qua được đường Exception -> Failure nên sẽ làm crash app.
/// Ở đây mọi trường hợp sai kiểu đều thành [ServerException] để RepositoryImpl
/// bắt được.
extension JsonReader on Map<String, dynamic> {
  /// Field bắt buộc: thiếu là dữ liệu hỏng, không thể dựng entity.
  String requireString(String key) {
    final value = this[key];
    if (value is String && value.isNotEmpty) return value;
    throw ServerException(
      message: 'Dữ liệu trả về thiếu trường bắt buộc "$key"',
    );
  }

  String? readString(String key) {
    final value = this[key];
    if (value is String) return value.isEmpty ? null : value;
    return null;
  }

  int? readInt(String key) {
    final value = this[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Ngày "thuần" (checkIn/checkOut): giữ nguyên UTC để thành phần ngày đúng
  /// bằng cái server gửi, không bị múi giờ kéo lệch.
  DateTime requireUtcDate(String key) {
    final parsed = _parseDate(this[key]);
    if (parsed == null) {
      throw ServerException(
        message: 'Dữ liệu trả về thiếu hoặc sai định dạng ngày "$key"',
      );
    }
    return parsed.toUtc();
  }

  /// Mốc thời gian thật (hold, createdAt, expiresAt): đổi sang giờ máy để
  /// đếm ngược/hiển thị đúng.
  DateTime? readLocalDate(String key) => _parseDate(this[key])?.toLocal();

  DateTime requireLocalDate(String key) {
    final parsed = readLocalDate(key);
    if (parsed == null) {
      throw ServerException(
        message: 'Dữ liệu trả về thiếu hoặc sai định dạng ngày "$key"',
      );
    }
    return parsed;
  }

  Map<String, dynamic>? readMap(String key) {
    final value = this[key];
    return value is Map<String, dynamic> ? value : null;
  }

  List<Map<String, dynamic>> readMapList(String key) {
    final value = this[key];
    if (value is! List) return const [];
    return value.whereType<Map<String, dynamic>>().toList(growable: false);
  }
}

DateTime? _parseDate(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

/// Cho phép viết `json.readMap('hotel').mapOrNull(Model.fromJson)` thay vì
/// phải gán biến tạm rồi kiểm tra null.
extension NullableJsonMapper on Map<String, dynamic>? {
  T? mapOrNull<T>(T Function(Map<String, dynamic> json) mapper) {
    final json = this;
    return json == null ? null : mapper(json);
  }
}
