import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/supabase_service.dart';

class ProfileProvider with ChangeNotifier {
  UserProfile _profile = UserProfile(name: 'User');
  bool _isLoading = false;

  UserProfile get profile => _profile;
  bool get isLoading => _isLoading;

  /// Override for tests — bypasses Supabase auth check when set.
  @visibleForTesting
  String? testUserIdOverride;

  @visibleForTesting
  String? testUserEmailOverride;

  String? get _currentUserId {
    if (testUserIdOverride != null) return testUserIdOverride;
    try {
      return supabase.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  String? get _currentUserEmail {
    if (testUserEmailOverride != null) return testUserEmailOverride;
    try {
      return supabase.auth.currentUser?.email;
    } catch (_) {
      return null;
    }
  }

  /// Derives a default username from the current user's email (the part
  /// before '@'). Falls back to 'User' when no email is available.
  ///
  /// Public so tests can verify the derivation without going through HTTP.
  @visibleForTesting
  String resolveDefaultUsername() {
    return _currentUserEmail?.split('@')[0] ?? 'User';
  }

  // Clear profile (for logout)
  void clearProfile() {
    _profile = UserProfile(name: 'User');
    notifyListeners();
  }

  // Load profile from Supabase
  Future<void> loadProfile() async {
    try {
      _isLoading = true;
      notifyListeners();

      final userId = _currentUserId;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        _profile = UserProfile(
          name: response['username'] ?? resolveDefaultUsername(),
          photoPath: response['photo_url'],
          age: response['age'],
        );
      } else {
        // Profile tidak ada, buat yang baru
        await _createProfile();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading profile: $e');
      // Tidak throw error supaya app tetap jalan
    }
  }

  // Create new profile
  Future<void> _createProfile() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      final username = resolveDefaultUsername();

      await supabase.from('profiles').insert({
        'id': userId,
        'username': username,
        'age': null,
        'photo_url': null,
      });

      _profile = UserProfile(name: username);
    } catch (e) {
      debugPrint('Error creating profile: $e');
    }
  }

  // Update profile
  Future<void> updateProfile(String name, int? age, String? photoPath) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      _profile.name = name;
      _profile.age = age;
      if (photoPath != null) {
        _profile.photoPath = photoPath;
      }

      await supabase.from('profiles').upsert({
        'id': userId,
        'username': name,
        'age': age,
        'photo_url': photoPath,
      });

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }
}
