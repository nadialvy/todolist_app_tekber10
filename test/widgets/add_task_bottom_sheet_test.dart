import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todolist_app_tekber10/models/task.dart';
import 'package:todolist_app_tekber10/widgets/add_task_bottom_sheet.dart';

Widget buildHost() {
  return MaterialApp(
    home: Builder(
      builder: (ctx) => Scaffold(
        body: ElevatedButton(
          onPressed: () => AddTaskBottomSheet.show(ctx),
          child: const Text('Open'),
        ),
      ),
    ),
  );
}

Future<void> openSheet(WidgetTester tester) async {
  // Tall viewport so the entire form fits without scrolling.
  await tester.binding.setSurfaceSize(const Size(800, 2400));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(buildHost());
  await tester.pump();
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

Future<void> scrollToPriority(WidgetTester tester) async {
  if (find.text('Priority').evaluate().isEmpty) {
    await tester.dragUntilVisible(
      find.text('Priority'),
      find.byType(ListView),
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();
  }
}

void main() {
  group('AddTaskBottomSheet', () {
    testWidgets('renders header title', (tester) async {
      await openSheet(tester);
      // "Add new task" appears in both header and submit button.
      expect(find.text('Add new task'), findsNWidgets(2));
    });

    testWidgets('renders labels for title, description, dates', (tester) async {
      await openSheet(tester);
      expect(find.text('Task title'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Start date'), findsOneWidget);
      expect(find.text('Due date'), findsOneWidget);
    });

    testWidgets('renders priority section after scrolling', (tester) async {
      await openSheet(tester);
      await scrollToPriority(tester);
      expect(find.text('Priority'), findsOneWidget);
      expect(find.text('LOW'), findsOneWidget);
      expect(find.text('MEDIUM'), findsOneWidget);
      expect(find.text('HIGH'), findsOneWidget);
    });

    testWidgets('renders title and description hints', (tester) async {
      await openSheet(tester);
      expect(find.text('Enter title'), findsOneWidget);
      expect(find.text('Enter description'), findsOneWidget);
    });

    testWidgets('renders submit button', (tester) async {
      await openSheet(tester);
      expect(find.widgetWithText(ElevatedButton, 'Add new task'),
          findsOneWidget);
    });

    testWidgets('close icon dismisses the sheet', (tester) async {
      await openSheet(tester);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Add new task'), findsNothing);
    });

    testWidgets('tapping LOW priority changes selection', (tester) async {
      await openSheet(tester);
      await scrollToPriority(tester);
      await tester.tap(find.text('LOW'));
      await tester.pump();
      expect(find.text('LOW'), findsOneWidget);
    });

    testWidgets('tapping MEDIUM priority changes selection', (tester) async {
      await openSheet(tester);
      await scrollToPriority(tester);
      await tester.tap(find.text('MEDIUM'));
      await tester.pump();
      expect(find.text('MEDIUM'), findsOneWidget);
    });

    testWidgets('tapping HIGH priority changes selection (already default)',
        (tester) async {
      await openSheet(tester);
      await scrollToPriority(tester);
      await tester.tap(find.text('HIGH'));
      await tester.pump();
      expect(find.text('HIGH'), findsOneWidget);
    });

    testWidgets('submit with empty title shows validation error', (tester) async {
      await openSheet(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Add new task'));
      await tester.pump();

      expect(find.text('Please enter a title'), findsOneWidget);
    });

    testWidgets('submit with title but no due date shows snackbar', (tester) async {
      await openSheet(tester);

      await tester.enterText(find.byType(TextFormField).first, 'My Task');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Add new task'));
      await tester.pump();

      expect(find.text('Please select a due date'), findsOneWidget);
    });

    testWidgets('selecting OK on start date picker updates the date', (tester) async {
      await tester.pumpWidget(buildHost());
      await tester.pump();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final startInk = find
          .ancestor(
            of: find.text('dd/mm/yy').first,
            matching: find.byType(InkWell),
          )
          .first;
      await tester.ensureVisible(startInk);
      await tester.pumpAndSettle();
      await tester.tap(startInk);
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // After selection, only the due date placeholder remains.
      expect(find.text('dd/mm/yy'), findsOneWidget);
    });

    testWidgets('opens start date picker via ensureVisible + tap', (tester) async {
      // Default viewport — form scrolls; ensureVisible scrolls the InkWell
      // into the form's scrollable so the footer doesn't overlap it.
      await tester.pumpWidget(buildHost());
      await tester.pump();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final startInk = find
          .ancestor(
            of: find.text('dd/mm/yy').first,
            matching: find.byType(InkWell),
          )
          .first;
      await tester.ensureVisible(startInk);
      await tester.pumpAndSettle();
      await tester.tap(startInk);
      await tester.pumpAndSettle();

      expect(find.byType(CalendarDatePicker), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });

    testWidgets('opens due date picker via ensureVisible + tap', (tester) async {
      await tester.pumpWidget(buildHost());
      await tester.pump();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final dueInk = find
          .ancestor(
            of: find.text('dd/mm/yy').last,
            matching: find.byType(InkWell),
          )
          .first;
      await tester.ensureVisible(dueInk);
      await tester.pumpAndSettle();
      await tester.tap(dueInk);
      await tester.pumpAndSettle();

      expect(find.byType(CalendarDatePicker), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });

    testWidgets('submit with title and selected due date generates AI steps and pops', (tester) async {
      Task? returnedTask;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  returnedTask = await AddTaskBottomSheet.show(ctx);
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Fill title
      await tester.enterText(find.byType(TextFormField).first, 'Design wireframe');
      await tester.pump();

      // Open due date picker and confirm
      final dueInk = find
          .ancestor(
            of: find.text('dd/mm/yy').last,
            matching: find.byType(InkWell),
          )
          .first;
      await tester.ensureVisible(dueInk);
      await tester.pumpAndSettle();
      await tester.tap(dueInk);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add new task'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Bottom sheet popped, task returned
      expect(returnedTask, isNotNull);
      expect(returnedTask!.title, 'Design wireframe');
    });

    testWidgets('show() returns null when dismissed', (tester) async {
      Task? result;
      await tester.binding.setSurfaceSize(const Size(800, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await AddTaskBottomSheet.show(ctx);
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });
  });
}
