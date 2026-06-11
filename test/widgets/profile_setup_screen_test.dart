import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:todolist_app_tekber10/providers/profile_provider.dart';
import 'package:todolist_app_tekber10/providers/task_provider.dart';
import 'package:todolist_app_tekber10/screens/profile_setup_screen.dart';

Widget buildApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => TaskProvider()),
      ChangeNotifierProvider(create: (_) => ProfileProvider()),
    ],
    child: const MaterialApp(home: ProfileSetupScreen()),
  );
}

Future<void> pumpApp(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(800, 1200));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(buildApp());
  await tester.pump();
}

void main() {
  group('ProfileSetupScreen', () {
    testWidgets('renders title and description', (tester) async {
      await pumpApp(tester);

      expect(find.text('Set Up Your Profile'), findsOneWidget);
      expect(
        find.text(
          'Help us personalize your experience by\nfilling in your details.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Username and Age labels', (tester) async {
      await pumpApp(tester);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Age'), findsOneWidget);
    });

    testWidgets('renders hint text for fields', (tester) async {
      await pumpApp(tester);
      expect(find.text('Enter your username'), findsOneWidget);
      expect(find.text('Enter your age'), findsOneWidget);
    });

    testWidgets('renders Continue button', (tester) async {
      await pumpApp(tester);
      expect(find.widgetWithText(ElevatedButton, 'Continue'), findsOneWidget);
    });

    testWidgets('shows person icon initially', (tester) async {
      await pumpApp(tester);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('camera icon is rendered for photo picker', (tester) async {
      await pumpApp(tester);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    testWidgets('back button is rendered', (tester) async {
      await pumpApp(tester);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('empty username shows error snackbar on Continue', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pump();

      expect(find.text('Mohon isi username'), findsOneWidget);
    });

    testWidgets('username < 3 chars shows error snackbar', (tester) async {
      await pumpApp(tester);

      await tester.enterText(find.byType(TextField).first, 'Ab');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pump();

      expect(find.text('Username minimal 3 karakter'), findsOneWidget);
    });

    testWidgets('invalid age (non-numeric) shows error snackbar', (tester) async {
      await pumpApp(tester);

      await tester.enterText(find.byType(TextField).first, 'AliceLong');
      final ageField = find.byType(TextField).at(1);
      await tester.enterText(ageField, 'abc');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pump();

      expect(find.text('Umur tidak valid'), findsOneWidget);
    });

    testWidgets('age out of range shows error snackbar', (tester) async {
      await pumpApp(tester);

      await tester.enterText(find.byType(TextField).first, 'AliceLong');
      final ageField = find.byType(TextField).at(1);
      await tester.enterText(ageField, '300');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pump();

      expect(find.text('Umur tidak valid'), findsOneWidget);
    });

    testWidgets('valid input attempts continue (Supabase fails -> error snackbar)',
        (tester) async {
      await pumpApp(tester);

      await tester.enterText(find.byType(TextField).first, 'AliceLong');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Supabase is uninitialized → error path runs.
      expect(find.textContaining('Gagal membuat profile'), findsOneWidget);
    });

    testWidgets('valid input + age attempts continue', (tester) async {
      await pumpApp(tester);

      await tester.enterText(find.byType(TextField).first, 'AliceLong');
      await tester.enterText(find.byType(TextField).at(1), '25');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Gagal membuat profile'), findsOneWidget);
    });

    testWidgets('back button pops the route', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => TaskProvider()),
            ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (ctx) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).push(
                    MaterialPageRoute(
                        builder: (_) => const ProfileSetupScreen()),
                  ),
                  child: const Text('Go'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.text('Set Up Your Profile'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Set Up Your Profile'), findsNothing);
    });
  });
}
