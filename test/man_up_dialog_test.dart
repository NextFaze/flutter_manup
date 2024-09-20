import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manup/manup.dart';

class DialogExample extends StatefulWidget {
  const DialogExample({super.key, required this.status});

  final ManUpStatus status;

  @override
  State<DialogExample> createState() => _DialogExampleState();
}

class _DialogExampleState extends State<DialogExample> with DialogMixin {
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          showManUpDialog(widget.status, 'This is the dialog', 'example.com');
        },
        child: Text('Show Dialog'));
  }
}

void main() {
  buildTestCase(WidgetTester tester, ManUpStatus status) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
      body: DialogExample(status: status),
    )));

    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows no dialog for latest status', (tester) async {
    await buildTestCase(tester, ManUpStatus.latest);

    expect(find.byType(AlertDialog), findsNothing);
  });
  testWidgets('shows an update dialog for an optional update', (tester) async {
    await buildTestCase(tester, ManUpStatus.supported);

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
        find.descendant(
            of: find.byType(AlertDialog), matching: find.byType(TextButton)),
        findsNWidgets(2));
    expect(find.text('This is the dialog'), findsOneWidget);
    expect(find.text('Update'), findsOneWidget);
    expect(find.text('Later'), findsOneWidget);
  });

  testWidgets('optional dialog is dismissible', (tester) async {
    await buildTestCase(tester, ManUpStatus.supported);

    expect(find.text('This is the dialog'), findsOneWidget);

    await tester.tapAt(const Offset(10.0, 10.0));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('This is the dialog'), findsNothing);

    await buildTestCase(tester, ManUpStatus.supported);
    expect(find.text('This is the dialog'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('This is the dialog'), findsNothing);
  });

  testWidgets('shows an update dialog for a required update', (tester) async {
    await buildTestCase(tester, ManUpStatus.unsupported);

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('This is the dialog'), findsOneWidget);
    expect(
        find.descendant(
            of: find.byType(AlertDialog), matching: find.byType(TextButton)),
        findsOneWidget);
    expect(find.text('Update'), findsOneWidget);
    expect(find.text('Later'), findsNothing);
  });

  testWidgets('required update dialog is not dismissible', (tester) async {
    await buildTestCase(tester, ManUpStatus.unsupported);

    expect(find.text('This is the dialog'), findsOneWidget);

    await tester.tapAt(const Offset(10.0, 10.0));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('This is the dialog'), findsOneWidget);
  });

  testWidgets('shows a kill switch dialog', (tester) async {
    await buildTestCase(tester, ManUpStatus.disabled);

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('This is the dialog'), findsOneWidget);
    expect(
        find.descendant(
            of: find.byType(AlertDialog), matching: find.byType(TextButton)),
        findsOneWidget);
    expect(find.text('Update'), findsNothing);
    expect(find.text('Later'), findsNothing);
    expect(find.text('OK'), findsOneWidget);
  });

  testWidgets('kill switch dialog is not dismissible', (tester) async {
    await buildTestCase(tester, ManUpStatus.unsupported);

    expect(find.text('This is the dialog'), findsOneWidget);

    await tester.tapAt(const Offset(10.0, 10.0));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('This is the dialog'), findsOneWidget);
  });
}
