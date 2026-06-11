import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:todolist_app_tekber10/providers/profile_provider.dart';
import 'package:todolist_app_tekber10/screens/edit_profile_screen.dart';

ProfileProvider _makeProvider({String name = 'User', int? age, String? photo}) {
  final provider = ProfileProvider();
  provider.profile.name = name;
  if (age != null) provider.profile.age = age;
  if (photo != null) provider.profile.photoPath = photo;
  return provider;
}

Widget buildApp(ProfileProvider provider) {
  return ChangeNotifierProvider.value(
    value: provider,
    child: const MaterialApp(home: EditProfileScreen()),
  );
}

void main() {
  group('EditProfileScreen', () {
    testWidgets('renders Edit profile title', (tester) async {
      await tester.pumpWidget(buildApp(_makeProvider()));
      await tester.pump();
      expect(find.text('Edit profile'), findsOneWidget);
    });

    testWidgets('renders Username and Age labels', (tester) async {
      await tester.pumpWidget(buildApp(_makeProvider()));
      await tester.pump();
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Age (optional)'), findsOneWidget);
    });

    testWidgets('renders hint text for username and age', (tester) async {
      await tester.pumpWidget(buildApp(_makeProvider()));
      await tester.pump();
      expect(find.text('Enter username'), findsOneWidget);
      expect(find.text('Enter age'), findsOneWidget);
    });

    testWidgets('pre-fills username from provider', (tester) async {
      await tester.pumpWidget(buildApp(_makeProvider(name: 'Alice')));
      await tester.pump();
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('pre-fills age from provider when available', (tester) async {
      await tester.pumpWidget(buildApp(_makeProvider(name: 'Alice', age: 25)));
      await tester.pump();
      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('renders Save button', (tester) async {
      await tester.pumpWidget(buildApp(_makeProvider()));
      await tester.pump();
      expect(find.widgetWithText(ElevatedButton, 'Save'), findsOneWidget);
    });

    testWidgets('shows person icon when no photo is set', (tester) async {
      await tester.pumpWidget(buildApp(_makeProvider()));
      await tester.pump();
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows camera icon overlay', (tester) async {
      await tester.pumpWidget(buildApp(_makeProvider()));
      await tester.pump();
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
    });

    testWidgets('back button is present', (tester) async {
      await tester.pumpWidget(buildApp(_makeProvider()));
      await tester.pump();
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });

    testWidgets('empty username shows validation snackbar on Save', (tester) async {
      await tester.pumpWidget(buildApp(_makeProvider(name: '')));
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pump();

      expect(find.text('Username tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('username < 3 chars shows validation snackbar', (tester) async {
      await tester.pumpWidget(buildApp(_makeProvider(name: 'Ab')));
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pump();

      expect(find.text('Username minimal 3 karakter'), findsOneWidget);
    });

    testWidgets('invalid age (non-numeric) shows validation snackbar',
        (tester) async {
      await tester.pumpWidget(buildApp(_makeProvider(name: 'Alice')));
      await tester.pump();

      // Find age TextField and enter invalid value
      final ageField = find.byType(TextField).at(1);
      await tester.enterText(ageField, 'abc');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pump();

      expect(find.text('Umur tidak valid'), findsOneWidget);
    });

    testWidgets('age out of range shows validation snackbar', (tester) async {
      await tester.pumpWidget(buildApp(_makeProvider(name: 'Alice')));
      await tester.pump();

      final ageField = find.byType(TextField).at(1);
      await tester.enterText(ageField, '200');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pump();

      expect(find.text('Umur tidak valid'), findsOneWidget);
    });

    testWidgets('valid input attempts save (and surfaces error from provider)',
        (tester) async {
      await tester.pumpWidget(buildApp(_makeProvider(name: 'AliceLongName')));
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Provider.updateProfile fails because Supabase isn't initialized.
      expect(find.textContaining('Gagal menyimpan profile'), findsOneWidget);
    });

    testWidgets('back button pops the route', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: _makeProvider(),
          child: MaterialApp(
            home: Builder(
              builder: (ctx) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).push(
                    MaterialPageRoute(
                        builder: (_) => const EditProfileScreen()),
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

      expect(find.text('Edit profile'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.text('Edit profile'), findsNothing);
      expect(find.text('Go'), findsOneWidget);
    });

  });
}
