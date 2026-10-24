import 'package:dape_ma_mobile/features/account/profile/profile_completeness.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileCompleteness', () {
    test('empty profile is 0%', () {
      expect(ProfileCompleteness.score(name: '', photoUrl: null), 0);
      expect(
        ProfileCompleteness.isComplete(name: '', photoUrl: null),
        isFalse,
      );
    });

    test('name only is 40% and not complete', () {
      expect(ProfileCompleteness.score(name: 'Ana', photoUrl: null), 0.4);
      expect(
        ProfileCompleteness.isComplete(name: 'Ana', photoUrl: null),
        isFalse,
      );
    });

    test('name and saved photo is 100%', () {
      expect(
        ProfileCompleteness.score(
          name: 'Ana',
          photoUrl: 'https://example.com/a.jpg',
        ),
        1.0,
      );
      expect(
        ProfileCompleteness.isComplete(
          name: 'Ana',
          photoUrl: 'https://example.com/a.jpg',
        ),
        isTrue,
      );
    });

    test('local photo can fill the ring before upload finishes', () {
      expect(
        ProfileCompleteness.score(name: 'Ana', hasLocalPhoto: true),
        1.0,
      );
      expect(
        ProfileCompleteness.isComplete(
          name: 'Ana',
          photoUrl: null,
          hasLocalPhoto: false,
        ),
        isFalse,
      );
    });

    test('reads /auth/me payload', () {
      expect(
        ProfileCompleteness.isCompleteFromUser({
          'name': 'Ana',
          'profile_image_url': 'https://example.com/a.jpg',
        }),
        isTrue,
      );
      expect(
        ProfileCompleteness.isCompleteFromUser({
          'name': 'Ana',
          'nickname': 'Neneng',
          'profile_image_url': null,
        }),
        isFalse,
      );
    });
  });
}
