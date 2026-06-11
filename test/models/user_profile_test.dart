import 'package:flutter_test/flutter_test.dart';
import 'package:todolist_app_tekber10/models/user_profile.dart';

void main() {
  group('UserProfile', () {
    group('constructor', () {
      test('should create profile with required name only', () {
        final profile = UserProfile(name: 'Alice');

        expect(profile.name, 'Alice');
        expect(profile.photoPath, isNull);
        expect(profile.age, isNull);
      });

      test('should create profile with all optional fields', () {
        final profile = UserProfile(
          name: 'Bob',
          photoPath: '/path/to/photo.jpg',
          age: 25,
        );

        expect(profile.name, 'Bob');
        expect(profile.photoPath, '/path/to/photo.jpg');
        expect(profile.age, 25);
      });

      test('should create profile with age zero', () {
        final profile = UserProfile(name: 'Test', age: 0);
        expect(profile.age, 0);
      });
    });

    group('mutability', () {
      test('should allow name to be updated', () {
        final profile = UserProfile(name: 'Old Name');
        profile.name = 'New Name';
        expect(profile.name, 'New Name');
      });

      test('should allow age to be updated', () {
        final profile = UserProfile(name: 'Test', age: 20);
        profile.age = 21;
        expect(profile.age, 21);
      });

      test('should allow age to be cleared to null', () {
        final profile = UserProfile(name: 'Test', age: 30);
        profile.age = null;
        expect(profile.age, isNull);
      });

      test('should allow photoPath to be set', () {
        final profile = UserProfile(name: 'Test');
        profile.photoPath = '/new/path.jpg';
        expect(profile.photoPath, '/new/path.jpg');
      });

      test('should allow photoPath to be cleared to null', () {
        final profile = UserProfile(name: 'Test', photoPath: '/photo.jpg');
        profile.photoPath = null;
        expect(profile.photoPath, isNull);
      });
    });

    group('toJson', () {
      test('should convert profile with all fields to JSON', () {
        final profile = UserProfile(
          name: 'Charlie',
          photoPath: '/photo.jpg',
          age: 30,
        );
        final json = profile.toJson();

        expect(json['name'], 'Charlie');
        expect(json['photoPath'], '/photo.jpg');
        expect(json['age'], 30);
      });

      test('should include null for optional fields in JSON', () {
        final profile = UserProfile(name: 'Dave');
        final json = profile.toJson();

        expect(json['name'], 'Dave');
        expect(json.containsKey('photoPath'), true);
        expect(json.containsKey('age'), true);
        expect(json['photoPath'], isNull);
        expect(json['age'], isNull);
      });

      test('should return a Map with exactly 3 keys', () {
        final profile = UserProfile(name: 'Test');
        final json = profile.toJson();

        expect(json.keys.length, 3);
        expect(json.containsKey('name'), true);
        expect(json.containsKey('photoPath'), true);
        expect(json.containsKey('age'), true);
      });
    });

    group('fromJson', () {
      test('should create profile from JSON with all fields', () {
        final json = {
          'name': 'Eve',
          'photoPath': '/photo.jpg',
          'age': 22,
        };
        final profile = UserProfile.fromJson(json);

        expect(profile.name, 'Eve');
        expect(profile.photoPath, '/photo.jpg');
        expect(profile.age, 22);
      });

      test('should handle null optional fields from JSON', () {
        final json = {
          'name': 'Frank',
          'photoPath': null,
          'age': null,
        };
        final profile = UserProfile.fromJson(json);

        expect(profile.name, 'Frank');
        expect(profile.photoPath, isNull);
        expect(profile.age, isNull);
      });

      test('should create mutable profile from JSON', () {
        final json = {'name': 'Grace', 'photoPath': null, 'age': null};
        final profile = UserProfile.fromJson(json);

        profile.name = 'Updated Grace';
        expect(profile.name, 'Updated Grace');
      });
    });

    group('JSON round-trip', () {
      test('should maintain all data through toJson/fromJson cycle', () {
        final original = UserProfile(
          name: 'Henry',
          photoPath: '/path/photo.png',
          age: 28,
        );
        final json = original.toJson();
        final restored = UserProfile.fromJson(json);

        expect(restored.name, original.name);
        expect(restored.photoPath, original.photoPath);
        expect(restored.age, original.age);
      });

      test('should maintain null fields through toJson/fromJson cycle', () {
        final original = UserProfile(name: 'Irene');
        final json = original.toJson();
        final restored = UserProfile.fromJson(json);

        expect(restored.name, original.name);
        expect(restored.photoPath, isNull);
        expect(restored.age, isNull);
      });
    });
  });
}
