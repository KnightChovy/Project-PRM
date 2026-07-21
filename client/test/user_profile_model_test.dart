import 'package:flutter_test/flutter_test.dart';
import 'package:smart_stay_ai/features/profile/data/models/user_profile_model.dart';
import 'package:smart_stay_ai/features/profile/domain/entities/profile_update.dart';

void main() {
  group('UserProfileModel.fromJson', () {
    test('đọc được cả cột User lẫn object profile lồng bên trong', () {
      final model = UserProfileModel.fromJson({
        'id': 'u1',
        'email': 'an@example.com',
        'fullName': 'Nguyễn Văn An',
        'phone': '0900000000',
        'avatarUrl': 'https://cdn.example.com/a.png',
        'role': 'customer',
        'status': 'active',
        'emailVerifiedAt': '2026-01-02T03:04:05.000Z',
        'profile': {
          'dateOfBirth': '1995-10-12T00:00:00.000Z',
          'nationality': 'Vietnam',
          'idCardNumber': '0790123',
          'passportNumber': 'P123',
          'preferredLanguage': 'en',
          'preferredCurrency': 'USD',
          'marketingOptIn': true,
        },
      });

      expect(model.fullName, 'Nguyễn Văn An');
      expect(model.isEmailVerified, isTrue);
      expect(model.dateOfBirth?.year, 1995);
      expect(model.preferredCurrency, 'USD');
      expect(model.marketingOptIn, isTrue);
    });

    test('chịu được profile null (user chưa từng cập nhật hồ sơ)', () {
      final model = UserProfileModel.fromJson({
        'id': 'u1',
        'email': 'an@example.com',
        'fullName': 'An',
        'role': 'customer',
        'status': 'active',
        'profile': null,
      });

      expect(model.dateOfBirth, isNull);
      expect(model.nationality, isNull);
      expect(model.isEmailVerified, isFalse);
      // Rơi về mặc định của server.
      expect(model.preferredLanguage, 'vi');
      expect(model.preferredCurrency, 'VND');
      expect(model.marketingOptIn, isFalse);
    });
  });

  group('profileUpdateToJson', () {
    test('chỉ đưa vào body những field khác null', () {
      final body = profileUpdateToJson(
        const ProfileUpdate(fullName: 'An', marketingOptIn: true),
      );

      expect(body, {'fullName': 'An', 'marketingOptIn': true});
      expect(body.containsKey('phone'), isFalse);
    });

    test('gửi dateOfBirth dạng chuỗi ISO như Joi yêu cầu', () {
      final body = profileUpdateToJson(
        ProfileUpdate(dateOfBirth: DateTime.utc(1995, 10, 12)),
      );

      expect(body['dateOfBirth'], '1995-10-12T00:00:00.000Z');
    });

    test('chuỗi rỗng vẫn được gửi để xoá field (server cho phép)', () {
      final body = profileUpdateToJson(const ProfileUpdate(phone: ''));

      expect(body, {'phone': ''});
    });
  });
}
