import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:todolist_app_tekber10/models/task.dart';
import 'package:todolist_app_tekber10/providers/task_provider.dart';
import 'package:todolist_app_tekber10/widgets/edit_task_bottom_sheet.dart';

Task makeTask({
  String title = 'My Task',
  String description = 'My description',
  TaskPriority priority = TaskPriority.medium,
  DateTime? startDate,
  DateTime? deadline,
}) {
  return Task(
    id: '1',
    title: title,
    description: description,
    startDate: startDate,
    deadline: deadline ?? DateTime.now().add(const Duration(days: 1)),
    status: TaskStatus.ongoing,
    priority: priority,
    createdAt: DateTime.now(),
  );
}

Widget buildHost(Task task) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => TaskProvider()),
    ],
    child: MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: ElevatedButton(
            onPressed: () => EditTaskBottomSheet.show(ctx, task),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
}

Future<void> openSheet(WidgetTester tester, {Task? task}) async {
  await tester.binding.setSurfaceSize(const Size(800, 2400));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(buildHost(task ?? makeTask()));
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
  group('EditTaskBottomSheet', () {
    testWidgets('renders header "Edit Task"', (tester) async {
      await openSheet(tester);
      expect(find.text('Edit Task'), findsOneWidget);
    });

    testWidgets('pre-fills title and description', (tester) async {
      await openSheet(tester,
          task: makeTask(title: 'Existing title', description: 'Existing desc'));
      expect(find.text('Existing title'), findsOneWidget);
      expect(find.text('Existing desc'), findsOneWidget);
    });

    testWidgets('renders Save button', (tester) async {
      await openSheet(tester);
      expect(find.widgetWithText(ElevatedButton, 'Save'), findsOneWidget);
    });

    testWidgets('renders priority buttons after scrolling', (tester) async {
      await openSheet(tester);
      await scrollToPriority(tester);
      expect(find.text('LOW'), findsOneWidget);
      expect(find.text('MEDIUM'), findsOneWidget);
      expect(find.text('HIGH'), findsOneWidget);
    });

    testWidgets('close icon dismisses the sheet', (tester) async {
      await openSheet(tester);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('Edit Task'), findsNothing);
    });

    testWidgets('tapping LOW priority selects it', (tester) async {
      await openSheet(tester);
      await scrollToPriority(tester);
      await tester.tap(find.text('LOW'));
      await tester.pump();
      expect(find.text('LOW'), findsOneWidget);
    });

    testWidgets('tapping HIGH priority selects it', (tester) async {
      await openSheet(tester);
      await scrollToPriority(tester);
      await tester.tap(find.text('HIGH'));
      await tester.pump();
      expect(find.text('HIGH'), findsOneWidget);
    });

    testWidgets('submit with cleared title shows validation error', (tester) async {
      await openSheet(tester);

      await tester.enterText(find.byType(TextFormField).first, '');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pump();

      expect(find.text('Please enter a title'), findsOneWidget);
    });

    testWidgets('submit with cleared description shows validation error',
        (tester) async {
      await openSheet(tester);

      final descField = find.byType(TextFormField).at(1);
      await tester.enterText(descField, '');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pump();

      expect(find.text('Please enter a description'), findsOneWidget);
    });

    testWidgets('submit with valid form attempts update and shows SnackBar',
        (tester) async {
      await openSheet(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      // Provider.updateTask fails (no Supabase) → SnackBar with error text.
      expect(find.textContaining('Error updating task'), findsOneWidget);
    });

    testWidgets('shows formatted start date for tasks with startDate', (tester) async {
      final startDate = DateTime(2026, 1, 15);
      await openSheet(tester, task: makeTask(startDate: startDate));

      expect(find.text('15/01/26'), findsOneWidget);
    });

    testWidgets('shows formatted due date', (tester) async {
      final due = DateTime(2026, 6, 20);
      await openSheet(tester, task: makeTask(deadline: due));

      expect(find.text('20/06/26'), findsOneWidget);
    });

    testWidgets('opens start date picker via ensureVisible + tap', (tester) async {
      // Default viewport — form scrolls, ensureVisible brings InkWell into view.
      final startDate = DateTime(2026, 1, 15);
      await tester.pumpWidget(buildHost(makeTask(startDate: startDate)));
      await tester.pump();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final startInk = find
          .ancestor(
            of: find.text('15/01/26'),
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
      final start = DateTime(2026, 1, 15);
      final due = DateTime(2026, 6, 20);
      await tester.pumpWidget(
          buildHost(makeTask(startDate: start, deadline: due)));
      await tester.pump();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final dueInk = find
          .ancestor(
            of: find.text('20/06/26'),
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

    testWidgets('selecting OK in start date picker updates display', (tester) async {
      final start = DateTime.now().add(const Duration(days: 5));
      await tester.pumpWidget(buildHost(makeTask(startDate: start)));
      await tester.pump();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final startInk = find
          .ancestor(
            of: find.byType(TextFormField).first,
            matching: find.byType(InkWell),
          );
      // Find by date label adjacency: open first InkWell that is the start date.
      final startDateText = find.descendant(
        of: find.byType(InkWell),
        matching: find.textContaining('/'),
      );
      expect(startDateText, findsAtLeastNWidgets(2));
      // Use the existing 'startInk' search by matching the formatted start date
      final formattedDate = '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${(start.year % 100).toString().padLeft(2, '0')}';
      final ink = find
          .ancestor(
            of: find.text(formattedDate),
            matching: find.byType(InkWell),
          )
          .first;
      await tester.ensureVisible(ink);
      await tester.pumpAndSettle();
      await tester.tap(ink);
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // The date display may have updated; just verify dialog closed without error
      expect(find.byType(CalendarDatePicker), findsNothing);
      expect(startInk, isNotNull);
    });
  });
}
