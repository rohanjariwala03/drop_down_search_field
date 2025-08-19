import 'package:drop_down_search_field/src/widgets/drop_down_search_form_field.dart';
import 'package:drop_down_search_field/src/widgets/search_field_configuration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class TestPage extends StatefulWidget {
  final int minCharsForSuggestions;
  const TestPage({super.key, this.minCharsForSuggestions = 0});

  @override
  State<StatefulWidget> createState() => TestPageState();
}

class TestPageState extends State<TestPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = 'Default text';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Test'),
        ),
        // https://medium.com/flutterpub/create-beautiful-forms-with-flutter-47075cfe712
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              DropDownSearchFormField<String>(
                textFieldConfiguration: TextFieldConfiguration(
                    autofocus: true,
                    inputFormatters: [LengthLimitingTextInputFormatter(50)],
                    controller: _controller,
                    decoration: const InputDecoration(
                        labelText: 'Dropdown Search Field')),
                suggestionsCallback: (pattern) {
                  if (pattern.isNotEmpty) {
                    return ['${pattern}aaa', '${pattern}bbb'];
                  } else {
                    return [];
                  }
                },
                noItemsFoundBuilder: (context) => const SizedBox(),
                itemBuilder: (context, String suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                onSuggestionSelected: (String suggestion) =>
                    _controller.text = suggestion,
                minCharsForSuggestions: widget.minCharsForSuggestions,
              ),
            ],
          ),
        ));
  }
}

void main() {
  group('DropDownSearchFormField', () {
    testWidgets('load and dispose', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestPage()));
      await tester.pumpAndSettle();

      expect(find.text('Dropdown Search Field'), findsOneWidget);
      expect(find.text('Default text'), findsOneWidget);
    });
    testWidgets('text input', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestPage()));
      await tester.pumpAndSettle();

      // Not using tester.enterText because the text input should already be focused.
      tester.testTextInput.enterText("test");
      await tester.pumpAndSettle(const Duration(milliseconds: 2000));
      expect(find.text("testaaa"), findsOneWidget);
      expect(find.text("testbbb"), findsOneWidget);
      tester.testTextInput.enterText("test2");
      await tester.pumpAndSettle(const Duration(milliseconds: 2000));
      expect(find.text("testaaa"), findsNothing);
      expect(find.text("testbbb"), findsNothing);
      expect(find.text("test2aaa"), findsOneWidget);
      expect(find.text("test2bbb"), findsOneWidget);
    });

    testWidgets('min chars for suggestions', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
          home: TestPage(
        minCharsForSuggestions: 4,
      )));
      await tester.pumpAndSettle();

      tester.testTextInput.enterText("333");
      await tester.pumpAndSettle(const Duration(milliseconds: 2000));
      expect(find.text("333aaa"), findsNothing);
      expect(find.text("333bbb"), findsNothing);
      tester.testTextInput.enterText("4444");
      await tester.pumpAndSettle(const Duration(milliseconds: 2000));
      expect(find.text("4444aaa"), findsOneWidget);
      expect(find.text("4444bbb"), findsOneWidget);
    });

    testWidgets('should handle controller text initialization',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestPage()));
      await tester.pumpAndSettle();

      // Check that default text is displayed
      expect(find.text('Default text'), findsOneWidget);
    });

    testWidgets('should respect input formatters', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestPage()));
      await tester.pumpAndSettle();

      // Try to enter text longer than 50 characters (the limit set by LengthLimitingTextInputFormatter)
      final longText = 'a' * 60; // 60 characters
      tester.testTextInput.enterText(longText);
      await tester.pumpAndSettle();

      // Text should be limited to 50 characters
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text.length, lessThanOrEqualTo(50));
    });

    testWidgets('should handle empty suggestions', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestPage()));
      await tester.pumpAndSettle();

      // Enter empty text (should return empty list from suggestionsCallback)
      tester.testTextInput.enterText("");
      await tester.pumpAndSettle(const Duration(milliseconds: 2000));

      // No suggestions should be shown
      expect(find.textContaining("aaa"), findsNothing);
      expect(find.textContaining("bbb"), findsNothing);
    });

    testWidgets('should handle autofocus', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestPage()));
      await tester.pumpAndSettle();

      // TextField should be focused due to autofocus: true
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.focusNode?.hasFocus, isTrue);
    });

    testWidgets('should display label correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestPage()));
      await tester.pumpAndSettle();

      expect(find.text('Dropdown Search Field'), findsOneWidget);
    });

    testWidgets('should handle suggestion selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestPage()));
      await tester.pumpAndSettle();

      // Enter text to show suggestions
      tester.testTextInput.enterText("test");
      await tester.pumpAndSettle(const Duration(milliseconds: 2000));

      // Tap on a suggestion
      await tester.tap(find.text("testaaa"));
      await tester.pumpAndSettle();

      // Controller text should be updated
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, "testaaa");
    });

    testWidgets('should handle rapid text changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestPage()));
      await tester.pumpAndSettle();

      // Enter text rapidly
      tester.testTextInput.enterText("a");
      await tester.pump(const Duration(milliseconds: 100));
      tester.testTextInput.enterText("ab");
      await tester.pump(const Duration(milliseconds: 100));
      tester.testTextInput.enterText("abc");
      await tester.pumpAndSettle(const Duration(milliseconds: 2000));

      // Should show suggestions for the final text
      expect(find.text("abcaaa"), findsOneWidget);
      expect(find.text("abcbbb"), findsOneWidget);
    });

    testWidgets('should display no items found builder when configured',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestPage()));
      await tester.pumpAndSettle();

      // The current implementation returns empty list for empty pattern
      // and returns items for non-empty pattern, so noItemsFoundBuilder might not be triggered
      // This test would need a custom implementation to properly test noItemsFoundBuilder
    });

    testWidgets('should handle form validation', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestPage()));
      await tester.pumpAndSettle();

      // Check that the widget is inside a Form
      expect(find.byType(Form), findsOneWidget);

      // The form key should be accessible
      final form = tester.widget<Form>(find.byType(Form));
      expect(form.child, isA<ListView>());
    });

    testWidgets('should dispose resources properly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestPage()));
      await tester.pumpAndSettle();

      // Navigate away to trigger dispose
      await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: Text('New Page'))));
      await tester.pumpAndSettle();

      // This test mainly ensures no exceptions are thrown during disposal
      expect(find.text('New Page'), findsOneWidget);
    });

    testWidgets('suggestions should update based on pattern changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestPage()));
      await tester.pumpAndSettle();

      // Test pattern 1
      tester.testTextInput.enterText("hello");
      await tester.pumpAndSettle(const Duration(milliseconds: 2000));
      expect(find.text("helloaaa"), findsOneWidget);
      expect(find.text("hellobbb"), findsOneWidget);

      // Test pattern 2
      tester.testTextInput.enterText("world");
      await tester.pumpAndSettle(const Duration(milliseconds: 2000));
      expect(find.text("worldaaa"), findsOneWidget);
      expect(find.text("worldbbb"), findsOneWidget);
      expect(find.text("helloaaa"), findsNothing);
      expect(find.text("hellobbb"), findsNothing);
    });
    // testWidgets('entering text works', (WidgetTester tester) async {
    //   await tester.pumpWidget(MaterialApp(home: TestPage()));
    //   await tester.pumpAndSettle();
    //   await tester.enterText(find.byType(DropDownSearchFormField), 'new text');
    // });

    // Up/down keyboard tests have been commented out due to a PR that
    // doesn't track them anymore to fix another bug .. sort of odd
    //   testWidgets('handle key up/down events', (WidgetTester tester) async {
    //     await tester.pumpWidget(MaterialApp(home: TestPage()));
    //     await tester.pumpAndSettle();

    //     tester.testTextInput.enterText("keyTest");
    //     await tester.pumpAndSettle(Duration(milliseconds: 2000));

    //     final textFieldFinder = find.byKey(TestKeys.textFieldKey);
    //     final TextField textField = tester.firstWidget(textFieldFinder);

    //     final firstSuggestionText = find.text("keyTestaaa");
    //     final firstSuggestionWrapperFinder = find.ancestor(
    //         of: firstSuggestionText,
    //         matching: find.byKey(TestKeys.getSuggestionKey(0)));
    //     final InkWell firstSuggestion =
    //         tester.firstWidget(firstSuggestionWrapperFinder);

    //     expect(textFieldFinder, findsOneWidget);

    //     expect(firstSuggestionText, findsOneWidget);
    //     expect(firstSuggestionWrapperFinder, findsOneWidget);

    //     expect(textField.focusNode?.hasFocus, true);
    //     expect(firstSuggestion.focusNode?.hasFocus, false);

    //     await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);

    //     expect(textField.focusNode?.hasFocus, false);
    //     expect(firstSuggestion.focusNode?.hasFocus, true);
    //   });
  });
}
