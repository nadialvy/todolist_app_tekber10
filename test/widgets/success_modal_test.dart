import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todolist_app_tekber10/widgets/success_modal.dart';

void main() {
  group('SuccessModal', () {
    testWidgets('renders title and description', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuccessModal(
              onCheckTask: () {},
              onBackToHome: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('New task Added'), findsOneWidget);
      expect(
        find.text('You can now begin working on the newly added task'),
        findsOneWidget,
      );
    });

    testWidgets('renders both action buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuccessModal(
              onCheckTask: () {},
              onBackToHome: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Check task'), findsOneWidget);
      expect(find.text('Back to home'), findsOneWidget);
    });

    testWidgets('tapping Check task triggers onCheckTask', (tester) async {
      var checkTaskCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuccessModal(
              onCheckTask: () => checkTaskCalled = true,
              onBackToHome: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Check task'));
      await tester.pump();

      expect(checkTaskCalled, true);
    });

    testWidgets('tapping Back to home triggers onBackToHome', (tester) async {
      var backToHomeCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuccessModal(
              onCheckTask: () {},
              onBackToHome: () => backToHomeCalled = true,
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Back to home'));
      await tester.pump();

      expect(backToHomeCalled, true);
    });

    testWidgets('static show() displays the modal and returns true on check task',
        (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await SuccessModal.show(ctx);
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('New task Added'), findsOneWidget);

      await tester.tap(find.text('Check task'));
      await tester.pumpAndSettle();

      expect(result, true);
    });

    testWidgets('static show() returns false on back to home',
        (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await SuccessModal.show(ctx);
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Back to home'));
      await tester.pumpAndSettle();

      expect(result, false);
    });
  });
}
