import 'package:flutter_test/flutter_test.dart';
import 'package:smart_stay_ai/features/auth/data/models/user_model.dart';

void main() {
  test('uses email as a display-name fallback when the API omits name', () {
    final user = UserModel.fromJson({
      'id': 'user-1',
      'name': null,
      'email': 'guest@example.com',
    });

    expect(user.id, 'user-1');
    expect(user.name, 'guest@example.com');
    expect(user.email, 'guest@example.com');
  });
}
