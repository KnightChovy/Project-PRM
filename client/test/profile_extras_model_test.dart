import 'package:flutter_test/flutter_test.dart';
import 'package:smart_stay_ai/features/profile/data/models/user_profile_model.dart';
import 'package:smart_stay_ai/features/profile/domain/entities/profile_update.dart';
import 'package:smart_stay_ai/features/hotel/data/models/destination_model.dart';

void main() {
  group('UserProfileModel.fromJson — loyalty/stats/prefs', () {
    test('đọc loyaltyAccount, stats, travelStyles, notificationPrefs', () {
      final model = UserProfileModel.fromJson({
        'id': 'u1',
        'email': 'a@b.com',
        'fullName': 'Nguyễn Văn An',
        'role': 'customer',
        'status': 'active',
        'loyaltyAccount': {'totalPoints': 2450, 'tier': 'gold'},
        'stats': {'trips': 12, 'reviews': 8},
        'profile': {
          'travelStyles': ['Beach', 'Wellness'],
          'notificationPrefs': {'priceDrops': false, 'email': true},
        },
      });

      expect(model.loyaltyPoints, 2450);
      expect(model.loyaltyTier, 'gold');
      expect(model.tripsCount, 12);
      expect(model.reviewsCount, 8);
      expect(model.travelStyles, ['Beach', 'Wellness']);
      expect(model.notificationPrefs, {'priceDrops': false, 'email': true});
    });

    test('thiếu các khối mới thì về mặc định an toàn', () {
      final model = UserProfileModel.fromJson({
        'id': 'u1',
        'email': 'a@b.com',
        'fullName': 'Khách',
        'role': 'customer',
        'status': 'active',
      });

      expect(model.loyaltyPoints, 0);
      expect(model.loyaltyTier, 'bronze');
      expect(model.tripsCount, 0);
      expect(model.reviewsCount, 0);
      expect(model.travelStyles, isEmpty);
      expect(model.notificationPrefs, isEmpty);
    });
  });

  group('profileUpdateToJson — field mới', () {
    test('gửi travelStyles + notificationPrefs khi có', () {
      final body = profileUpdateToJson(const ProfileUpdate(
        travelStyles: ['City'],
        notificationPrefs: {'sms': false},
      ));

      expect(body['travelStyles'], ['City']);
      expect(body['notificationPrefs'], {'sms': false});
    });

    test('không đụng tới thì không đưa key vào body', () {
      final body = profileUpdateToJson(const ProfileUpdate(fullName: 'X'));

      expect(body.containsKey('travelStyles'), isFalse);
      expect(body.containsKey('notificationPrefs'), isFalse);
    });
  });

  group('DestinationModel.fromJson', () {
    test('map city -> name + hotelCount + imageUrl', () {
      final d = DestinationModel.fromJson({
        'city': 'Đà Nẵng',
        'hotelCount': 5,
        'imageUrl': 'https://x/dn.jpg',
      });

      expect(d.name, 'Đà Nẵng');
      expect(d.hotelCount, 5);
      expect(d.imageUrl, 'https://x/dn.jpg');
    });

    test('imageUrl null -> chuỗi rỗng', () {
      final d = DestinationModel.fromJson({'city': 'Huế', 'hotelCount': 1});
      expect(d.imageUrl, '');
    });
  });
}
