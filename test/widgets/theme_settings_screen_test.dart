import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist_app_tekber10/providers/theme_provider.dart';
import 'package:todolist_app_tekber10/screens/theme_settings_screen.dart';

Widget buildTestApp(ThemeProvider provider) {
  return ChangeNotifierProvider.value(
    value: provider,
    child: Builder(
      builder: (ctx) {
        final tp = Provider.of<ThemeProvider>(ctx);
        return MaterialApp(
          theme: tp.lightTheme,
          darkTheme: tp.darkTheme,
          themeMode: tp.themeMode,
          home: const ThemeSettingsScreen(),
        );
      },
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeSettingsScreen', () {
    testWidgets('should render Settings AppBar title', (tester) async {
      final provider = ThemeProvider();
      await tester.pumpWidget(buildTestApp(provider));
      await tester.pump();
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('should render Theme Mode section header', (tester) async {
      final provider = ThemeProvider();
      await tester.pumpWidget(buildTestApp(provider));
      await tester.pump();
      expect(find.text('Theme Mode'), findsOneWidget);
    });

    testWidgets('should render Color Theme section header', (tester) async {
      final provider = ThemeProvider();
      await tester.pumpWidget(buildTestApp(provider));
      await tester.pump();
      expect(find.text('Color Theme'), findsOneWidget);
    });

    testWidgets('should render use case subtitles for theme mode options', (tester) async {
      final provider = ThemeProvider();
      await tester.pumpWidget(buildTestApp(provider));
      await tester.pump();
      expect(find.text('Use light theme'), findsOneWidget);
      expect(find.text('Use dark theme'), findsOneWidget);
      expect(find.text('Follow system theme'), findsOneWidget);
    });

    testWidgets('should render Light Mode option', (tester) async {
      final provider = ThemeProvider();
      await tester.pumpWidget(buildTestApp(provider));
      await tester.pump();
      expect(find.text('Light Mode'), findsOneWidget);
    });

    testWidgets('should render Dark Mode option', (tester) async {
      final provider = ThemeProvider();
      await tester.pumpWidget(buildTestApp(provider));
      await tester.pump();
      expect(find.text('Dark Mode'), findsOneWidget);
    });

    testWidgets('should render System option', (tester) async {
      final provider = ThemeProvider();
      await tester.pumpWidget(buildTestApp(provider));
      await tester.pump();
      expect(find.text('System'), findsOneWidget);
    });

    testWidgets('should render all 4 color theme names', (tester) async {
      final provider = ThemeProvider();
      await tester.pumpWidget(buildTestApp(provider));
      await tester.pump();
      expect(find.text('Blue'), findsOneWidget);
      expect(find.text('Purple'), findsOneWidget);
      expect(find.text('Green'), findsOneWidget);
      expect(find.text('Orange'), findsOneWidget);
    });

    testWidgets('tapping Purple theme card updates ThemeProvider index', (tester) async {
      // Purple is index 1 (default), switch to Blue first, then back to Purple
      final provider = ThemeProvider();
      await provider.setThemeIndex(0); // Blue first
      expect(provider.themeIndex, 0);

      await tester.pumpWidget(buildTestApp(provider));
      await tester.pump();

      await tester.tap(find.text('Purple'));
      await tester.pumpAndSettle();

      expect(provider.themeIndex, 1);
    });

    testWidgets('tapping Dark Mode updates ThemeProvider', (tester) async {
      final provider = ThemeProvider();
      expect(provider.themeMode, ThemeMode.light);

      await tester.pumpWidget(buildTestApp(provider));
      await tester.pump();

      await tester.tap(find.text('Dark Mode'));
      await tester.pumpAndSettle();

      expect(provider.themeMode, ThemeMode.dark);
    });

    testWidgets('tapping Light Mode updates ThemeProvider', (tester) async {
      final provider = ThemeProvider();
      await provider.setThemeMode(ThemeMode.dark);

      await tester.pumpWidget(buildTestApp(provider));
      await tester.pump();

      await tester.tap(find.text('Light Mode'));
      await tester.pumpAndSettle();

      expect(provider.themeMode, ThemeMode.light);
    });

    testWidgets('tapping Blue theme card updates ThemeProvider index', (tester) async {
      final provider = ThemeProvider();
      expect(provider.themeIndex, 1); // Default is Purple (index 1)

      await tester.pumpWidget(buildTestApp(provider));
      await tester.pump();

      await tester.tap(find.text('Blue'));
      await tester.pumpAndSettle();

      expect(provider.themeIndex, 0);
    });

    testWidgets('default selected theme shows check icon', (tester) async {
      final provider = ThemeProvider(); // default Purple (index 1)
      await tester.pumpWidget(buildTestApp(provider));
      await tester.pump();
      // The selected card shows Icons.check_circle
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('has back button in AppBar', (tester) async {
      final provider = ThemeProvider();
      await tester.pumpWidget(buildTestApp(provider));
      await tester.pump();
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('tapping back button pops the route', (tester) async {
      final provider = ThemeProvider();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: MaterialApp(
            home: Builder(
              builder: (ctx) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).push(
                    MaterialPageRoute(
                      builder: (_) => const ThemeSettingsScreen(),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('demo Elevated, Filled, Outlined buttons are tappable',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 2000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final provider = ThemeProvider();
      await tester.pumpWidget(buildTestApp(provider));
      await tester.pump();

      // Scroll to the demo buttons.
      await tester.dragUntilVisible(
        find.text('Elevated'),
        find.byType(ListView),
        const Offset(0, -100),
      );

      await tester.tap(find.text('Elevated'));
      await tester.pump();
      await tester.tap(find.text('Filled'));
      await tester.pump();
      await tester.tap(find.text('Outlined'));
      await tester.pump();
    });
  });
}
