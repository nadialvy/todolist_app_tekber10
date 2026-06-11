import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:todolist_app_tekber10/screens/signup_screen.dart';

class _DummyTaskProvider with ChangeNotifier {}

class _DummyProfileProvider with ChangeNotifier {}

Widget buildTestApp({bool fromOnboarding = false}) {
  return MaterialApp(home: SignUpScreen(fromOnboarding: fromOnboarding));
}

void main() {
  group('SignUpScreen', () {
    testWidgets('should render Create Account heading', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('should render subtitle text', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Sign up to get started.'), findsOneWidget);
    });

    testWidgets('should render email field', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Email address'), findsOneWidget);
    });

    testWidgets('should render password field', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('should render confirm password field', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('should render Sign up button', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.widgetWithText(ElevatedButton, 'Sign up'), findsOneWidget);
    });

    testWidgets('should render Sign in link text', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('should render two password visibility toggle icons', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off_outlined), findsNWidgets(2));
    });

    testWidgets('tapping password visibility toggles the icon', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      // Tap first visibility icon (password field)
      await tester.tap(find.byIcon(Icons.visibility_off_outlined).first);
      await tester.pump();

      // One should now be visible
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    group('form validation', () {
      Future<void> tapSignUpButton(WidgetTester tester) async {
        final btn = find.widgetWithText(ElevatedButton, 'Sign up');
        await tester.ensureVisible(btn);
        await tester.tap(btn);
        await tester.pump();
      }

      testWidgets('shows error when all fields empty', (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pump();
        await tapSignUpButton(tester);
        expect(find.text('Mohon isi semua kolom'), findsOneWidget);
      });

      testWidgets('shows error for invalid email format', (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pump();

        final fields = find.byType(TextField);
        await tester.enterText(fields.at(0), 'invalidemail');
        await tester.enterText(fields.at(1), 'password123');
        await tester.enterText(fields.at(2), 'password123');

        await tapSignUpButton(tester);
        expect(find.text('Format email tidak valid'), findsOneWidget);
      });

      testWidgets('shows error when password is too short', (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pump();

        final fields = find.byType(TextField);
        await tester.enterText(fields.at(0), 'test@email.com');
        await tester.enterText(fields.at(1), '123');
        await tester.enterText(fields.at(2), '123');

        await tapSignUpButton(tester);
        expect(find.text('Password minimal 6 karakter'), findsOneWidget);
      });

      testWidgets('shows error when passwords do not match', (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pump();

        final fields = find.byType(TextField);
        await tester.enterText(fields.at(0), 'test@email.com');
        await tester.enterText(fields.at(1), 'password123');
        await tester.enterText(fields.at(2), 'different123');

        await tapSignUpButton(tester);
        expect(find.text('Password tidak cocok'), findsOneWidget);
      });

      testWidgets('valid signup attempts Supabase signUp (which fails)',
          (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pump();

        final fields = find.byType(TextField);
        await tester.enterText(fields.at(0), 'test@email.com');
        await tester.enterText(fields.at(1), 'password123');
        await tester.enterText(fields.at(2), 'password123');

        await tapSignUpButton(tester);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Supabase fails — error snackbar appears.
        expect(find.byType(SnackBar), findsOneWidget);
      });
    });

    testWidgets('back button pops the screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => Scaffold(
              body: ElevatedButton(
                onPressed: () => Navigator.of(ctx).push(
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('Sign in link is present when fromOnboarding is true',
        (tester) async {
      await tester.pumpWidget(buildTestApp(fromOnboarding: true));
      await tester.pump();
      // The link triggers different navigation; just verify it renders.
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('tapping Sign in link with fromOnboarding=true replaces with SignInScreen',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
                create: (_) => _DummyTaskProvider()),
            ChangeNotifierProvider(create: (_) => _DummyProfileProvider()),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (ctx) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).push(
                    MaterialPageRoute(
                      builder: (_) => const SignUpScreen(fromOnboarding: true),
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

      expect(find.text('Create Account'), findsOneWidget);

      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      // SignInScreen has 'Welcome to My Vlog!' heading
      expect(find.text('Welcome to My Vlog!'), findsOneWidget);
    });

    testWidgets('tapping Sign in link with fromOnboarding=false pops the route',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => Scaffold(
              body: ElevatedButton(
                onPressed: () => Navigator.of(ctx).push(
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('tapping confirm password visibility toggles the icon',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      // Tap the second visibility icon (confirm password)
      await tester.tap(find.byIcon(Icons.visibility_off_outlined).last);
      await tester.pump();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });
  });
}

class SignUpScreenImports {
  // Just to silence unused import lint if SignInScreen reference is needed.
}
