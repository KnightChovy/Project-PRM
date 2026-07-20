import '../../domain/entities/user.dart';

/// Model = Entity + khả năng đọc/ghi JSON.
/// Việc map JSON CHỈ được phép ở đây (tầng Data).
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final email = json['email']?.toString() ?? '';
    final name = json['name'] ?? json['fullName'] ?? json['username'] ?? email;

    return UserModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: name.toString(),
      email: email,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};
}
