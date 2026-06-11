import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist_app_tekber10/providers/theme_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeProvider', () {
    group('default values', () {
      test('should default to ThemeMode.light', () {
        final provider = ThemeProvider();
        expect(provider.themeMode, ThemeMode.light);
      });

      test('should default to theme index 1 (Purple)', () {
        final provider = ThemeProvider();
        expect(provider.themeIndex, 1);
      });

      test('should have 4 light themes', () {
        final provider = ThemeProvider();
        expect(provider.lightThemes.length, 4);
      });

      test('should have 4 dark themes', () {
        final provider = ThemeProvider();
        expect(provider.darkThemes.length, 4);
      });

      test('should have 4 theme names', () {
        final provider = ThemeProvider();
        expect(provider.themeNames.length, 4);
        expect(provider.themeNames, containsAll(['Blue', 'Purple', 'Green', 'Orange']));
      });
    });

    group('lightTheme getter', () {
      test('should return theme at current themeIndex', () {
        final provider = ThemeProvider();
        expect(provider.lightTheme, provider.lightThemes[provider.themeIndex]);
      });

      test('should return correct theme after index change', () async {
        final provider = ThemeProvider();
        await provider.setThemeIndex(0);
        expect(provider.lightTheme, provider.lightThemes[0]);
      });
    });

    group('darkTheme getter', () {
      test('should return theme at current themeIndex', () {
        final provider = ThemeProvider();
        expect(provider.darkTheme, provider.darkThemes[provider.themeIndex]);
      });

      test('should return correct dark theme after index change', () async {
        final provider = ThemeProvider();
        await provider.setThemeIndex(2);
        expect(provider.darkTheme, provider.darkThemes[2]);
      });
    });

    group('setThemeMode', () {
      test('should update themeMode to dark', () async {
        final provider = ThemeProvider();
        await provider.setThemeMode(ThemeMode.dark);
        expect(provider.themeMode, ThemeMode.dark);
      });

      test('should update themeMode to system', () async {
        final provider = ThemeProvider();
        await provider.setThemeMode(ThemeMode.system);
        expect(provider.themeMode, ThemeMode.system);
      });

      test('should switch back to light from dark', () async {
        final provider = ThemeProvider();
        await provider.setThemeMode(ThemeMode.dark);
        await provider.setThemeMode(ThemeMode.light);
        expect(provider.themeMode, ThemeMode.light);
      });

      test('should persist themeMode via SharedPreferences', () async {
        final provider = ThemeProvider();
        await provider.setThemeMode(ThemeMode.dark);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt('themeMode'), ThemeMode.dark.index);
      });
    });

    group('setThemeIndex', () {
      test('should update themeIndex to 0 (Blue)', () async {
        final provider = ThemeProvider();
        await provider.setThemeIndex(0);
        expect(provider.themeIndex, 0);
      });

      test('should update themeIndex to 2 (Green)', () async {
        final provider = ThemeProvider();
        await provider.setThemeIndex(2);
        expect(provider.themeIndex, 2);
      });

      test('should update themeIndex to 3 (Orange)', () async {
        final provider = ThemeProvider();
        await provider.setThemeIndex(3);
        expect(provider.themeIndex, 3);
      });

      test('should persist themeIndex via SharedPreferences', () async {
        final provider = ThemeProvider();
        await provider.setThemeIndex(3);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt('themeIndex'), 3);
      });
    });

    group('loadTheme', () {
      test('should load default values when no preferences saved', () async {
        final provider = ThemeProvider();
        await provider.loadTheme();

        expect(provider.themeMode, ThemeMode.system); // index 0 = system
        expect(provider.themeIndex, 1); // default Purple
      });

      test('should load saved themeMode from preferences', () async {
        SharedPreferences.setMockInitialValues({
          'themeMode': ThemeMode.dark.index,
          'themeIndex': 1,
        });

        final provider = ThemeProvider();
        await provider.loadTheme();

        expect(provider.themeMode, ThemeMode.dark);
      });

      test('should load saved themeIndex from preferences', () async {
        SharedPreferences.setMockInitialValues({
          'themeMode': 0,
          'themeIndex': 3,
        });

        final provider = ThemeProvider();
        await provider.loadTheme();

        expect(provider.themeIndex, 3);
      });

      test('should restore theme settings saved by setThemeMode/setThemeIndex', () async {
        final provider = ThemeProvider();
        await provider.setThemeMode(ThemeMode.dark);
        await provider.setThemeIndex(2);

        // Simulate a fresh provider loading from SharedPreferences
        final newProvider = ThemeProvider();
        await newProvider.loadTheme();

        expect(newProvider.themeMode, ThemeMode.dark);
        expect(newProvider.themeIndex, 2);
      });
    });
  });
}
