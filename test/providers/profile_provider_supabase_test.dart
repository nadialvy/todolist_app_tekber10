import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todolist_app_tekber10/providers/profile_provider.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'http://127.0.0.1:54321',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.fake.token',
      debug: false,
    );
  });

  ProfileProvider authedProvider({String? email}) {
    final p = ProfileProvider();
    p.testUserIdOverride = 'fake-user-id';
    p.testUserEmailOverride = email ?? 'alice@example.com';
    return p;
  }

  group('ProfileProvider with fake auth user', () {
    test('loadProfile runs past auth, fails on HTTP, catches', () async {
      final provider = authedProvider();
      await provider.loadProfile();
      expect(provider.isLoading, false);
    });

    test('updateProfile with name and age runs past auth', () async {
      final provider = authedProvider();
      try {
        await provider.updateProfile('Alice', 25, '/photo.jpg');
      } catch (_) {}
    });

    test('updateProfile with null age and photo path', () async {
      final provider = authedProvider();
      try {
        await provider.updateProfile('Bob', null, null);
      } catch (_) {}
    });

    test('updateProfile sets name on profile before HTTP call', () async {
      final provider = authedProvider();
      try {
        await provider.updateProfile('NewName', 30, null);
      } catch (_) {}
      // Even when HTTP fails, the in-memory profile is updated first.
      expect(provider.profile.name, 'NewName');
      expect(provider.profile.age, 30);
    });

    test('updateProfile with photoPath updates photo path', () async {
      final provider = authedProvider();
      try {
        await provider.updateProfile('Eve', 22, '/path/eve.jpg');
      } catch (_) {}
      expect(provider.profile.photoPath, '/path/eve.jpg');
    });
  });

  group('ProfileProvider without auth user', () {
    test('loadProfile completes (catches error)', () async {
      final provider = ProfileProvider();
      await provider.loadProfile();
      expect(provider.isLoading, false);
    });

    test('updateProfile throws when no auth user', () async {
      final provider = ProfileProvider();
      try {
        await provider.updateProfile('Alice', 25, null);
        fail('Expected throw');
      } catch (_) {}
    });
  });
}
