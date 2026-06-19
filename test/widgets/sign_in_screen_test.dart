import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:todolist_app_tekber10/providers/task_provider.dart';
import 'package:todolist_app_tekber10/providers/profile_provider.dart';
import 'package:todolist_app_tekber10/screens/sign_in_screen.dart';

Widget buildTestApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => TaskProvider()),
      ChangeNotifierProvider(create: (_) => ProfileProvider()),
    ],
    child: const MaterialApp(home: SignInScreen()),
  );
}

void main() {
  group('SignInScreen', () {
    testWidgets('should render welcome heading', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Welcome to My Vlog!'), findsOneWidget);
    });

    testWidgets('should render subtitle text', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Please enter your details.'), findsOneWidget);
    });

    testWidgets('should render email field label', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Email address'), findsOneWidget);
    });

    testWidgets('should render password field label', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('should render email hint text', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Enter email address'), findsOneWidget);
    });

    testWidgets('should render password hint text', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Enter password'), findsOneWidget);
    });

    testWidgets('should render Sign in button', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.widgetWithText(ElevatedButton, 'Sign in'), findsOneWidget);
    });

    testWidgets('should render Sign up link', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Sign up'), findsOneWidget);
    });

    testWidgets('should render "You don\'t have an account?" text', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.textContaining("don't have an account"), findsOneWidget);
    });

    testWidgets('password visibility toggle icon is present', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('tapping password visibility icon toggles the icon', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      // Initially shows visibility_off (password hidden)
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      // After tap shows visibility (password visible)
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
    });

    testWidgets('shows snackbar when sign in attempted with empty fields', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
      await tester.pump();

      expect(find.text('Mohon isi email dan password'), findsOneWidget);
    });

    testWidgets('shows snackbar when only email is filled', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
      await tester.pump();

      expect(find.text('Mohon isi email dan password'), findsOneWidget);
    });

    testWidgets('shows snackbar when only password is filled', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
      await tester.pump();

      expect(find.text('Mohon isi email dan password'), findsOneWidget);
    });

    testWidgets('sign in attempt with valid input triggers Supabase call (fails)',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Supabase fails (uninitialized) — error snackbar is shown.
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('tapping Sign up link navigates to sign up screen',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      // SignUpScreen has 'Create Account' header
      expect(find.text('Create Account'), findsOneWidget);
    });
  });
}
