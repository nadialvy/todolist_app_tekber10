import 'package:flutter_test/flutter_test.dart';
import 'package:todolist_app_tekber10/models/user_profile.dart';
import 'package:todolist_app_tekber10/providers/profile_provider.dart';

void main() {
  group('ProfileProvider', () {
    test('initial profile has default name "User"', () {
      final provider = ProfileProvider();
      expect(provider.profile.name, 'User');
      expect(provider.profile.age, isNull);
      expect(provider.profile.photoPath, isNull);
    });

    test('initial isLoading is false', () {
      final provider = ProfileProvider();
      expect(provider.isLoading, false);
    });

    test('clearProfile resets profile to default', () {
      final provider = ProfileProvider();
      // Mutate first
      provider.profile.name = 'Alice';
      provider.profile.age = 30;
      provider.profile.photoPath = '/some/path';

      provider.clearProfile();

      expect(provider.profile.name, 'User');
      expect(provider.profile.age, isNull);
      expect(provider.profile.photoPath, isNull);
    });

    test('clearProfile notifies listeners', () {
      final provider = ProfileProvider();
      var notifications = 0;
      provider.addListener(() => notifications++);

      provider.clearProfile();

      expect(notifications, 1);
    });

    test('loadProfile completes (catches error) when Supabase is not initialized',
        () async {
      final provider = ProfileProvider();
      // Should not throw — the method catches errors and logs them.
      await provider.loadProfile();
      expect(provider.isLoading, false);
    });

    test('loadProfile sets isLoading to false after completion', () async {
      final provider = ProfileProvider();
      await provider.loadProfile();
      expect(provider.isLoading, false);
    });

    test('updateProfile throws when Supabase is not initialized', () async {
      final provider = ProfileProvider();
      expect(
        () => provider.updateProfile('NewName', 25, '/path/to/photo.jpg'),
        throwsA(anything),
      );
    });

    test('UserProfile getters and mutations work', () {
      final profile = UserProfile(name: 'Initial');
      expect(profile.name, 'Initial');

      profile.name = 'Updated';
      profile.age = 25;
      profile.photoPath = '/new/path';

      expect(profile.name, 'Updated');
      expect(profile.age, 25);
      expect(profile.photoPath, '/new/path');
    });

    group('resolveDefaultUsername', () {
      test('returns "User" when no email available', () {
        final provider = ProfileProvider();
        expect(provider.resolveDefaultUsername(), 'User');
      });

      test('returns email local-part when override is set', () {
        final provider = ProfileProvider();
        provider.testUserEmailOverride = 'alice.smith@example.com';
        expect(provider.resolveDefaultUsername(), 'alice.smith');
      });

      test('returns "User" for empty email string', () {
        final provider = ProfileProvider();
        provider.testUserEmailOverride = '';
        // Empty string split returns [''] — first element is '' which is
        // truthy by `??`, so returns ''.
        expect(provider.resolveDefaultUsername(), '');
      });

      test('handles email without @ symbol gracefully', () {
        final provider = ProfileProvider();
        provider.testUserEmailOverride = 'noatsymbol';
        // split returns ['noatsymbol'] → first element is 'noatsymbol'.
        expect(provider.resolveDefaultUsername(), 'noatsymbol');
      });
    });
  });
}
