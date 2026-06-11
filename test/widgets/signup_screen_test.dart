import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todolist_app_tekber10/screens/signup_screen.dart';

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
    });
  });
}
