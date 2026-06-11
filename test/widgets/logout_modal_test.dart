import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:todolist_app_tekber10/providers/profile_provider.dart';
import 'package:todolist_app_tekber10/providers/task_provider.dart';
import 'package:todolist_app_tekber10/widgets/logout_modal.dart';

Widget buildHost() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => TaskProvider()),
      ChangeNotifierProvider(create: (_) => ProfileProvider()),
    ],
    child: MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: ElevatedButton(
            onPressed: () => LogoutModal.show(ctx),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('LogoutModal', () {
    testWidgets('renders title and description', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LogoutModal()),
        ),
      );
      await tester.pump();

      expect(find.text('Are you sure you want to logout?'), findsOneWidget);
      expect(
        find.text(
          'You will be logged out of your account and need to log back in to continue.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Logout and Cancel buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LogoutModal()),
        ),
      );
      await tester.pump();

      expect(find.text('Logout'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('tapping Cancel closes the dialog', (tester) async {
      await tester.pumpWidget(buildHost());
      await tester.pump();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to logout?'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to logout?'), findsNothing);
    });

    testWidgets('tapping Logout triggers logout path (Supabase not initialized -> SnackBar)',
        (tester) async {
      await tester.pumpWidget(buildHost());
      await tester.pump();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap Logout — clearTasks/clearProfile run, then supabase.auth.signOut throws,
      // which is caught and surfaces a snackbar.
      await tester.tap(find.text('Logout'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // SnackBar should show with logout failure text
      expect(find.textContaining('Logout failed'), findsOneWidget);
    });

    testWidgets('static show() displays the modal', (tester) async {
      await tester.pumpWidget(buildHost());
      await tester.pump();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(LogoutModal), findsOneWidget);
    });
  });
}
