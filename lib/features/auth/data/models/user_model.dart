import '../../domain/entities/user.dart';

/// Model = Entity + khả năng đọc/ghi JSON.
/// Việc map JSON CHỈ được phép ở đây (tầng Data).
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
      };
}
