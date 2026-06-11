import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todolist_app_tekber10/screens/onboarding_screen.dart';

Widget buildTestApp() => const MaterialApp(home: OnboardingScreen());

void main() {
  group('OnboardingScreen', () {
    testWidgets('should render app name', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('FocusBuddy'), findsOneWidget);
    });

    testWidgets('should render headline text', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.textContaining('Stay Organized'), findsOneWidget);
    });

    testWidgets('should render description text', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.textContaining('Easily manage'), findsOneWidget);
    });

    testWidgets('should render Get started button', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.widgetWithText(ElevatedButton, 'Get started'), findsOneWidget);
    });

    testWidgets('should render Already have an account button', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.widgetWithText(OutlinedButton, 'Already have an account'), findsOneWidget);
    });

    testWidgets('should navigate to SignUpScreen on Get started tap', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Get started'));
      await tester.pumpAndSettle();
      // SignUpScreen shows "Create Account"
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('should navigate to SignInScreen on Already have an account tap', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Already have an account'));
      await tester.pumpAndSettle();
      // SignInScreen shows "Welcome to My Vlog!"
      expect(find.text('Welcome to My Vlog!'), findsOneWidget);
    });
  });
}
