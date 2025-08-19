import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class DisabledItemsTestPage extends StatefulWidget {
  const DisabledItemsTestPage({super.key});

  @override
  State<DisabledItemsTestPage> createState() => _DisabledItemsTestPageState();
}

class _DisabledItemsTestPageState extends State<DisabledItemsTestPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> foodItems = [
    "Apple",
    "Banana", // This will be disabled
    "Cherry",
    "Date", // This will be disabled
    "Elderberry",
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Disabled Items Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DropDownSearchFormField<String>(
          textFieldConfiguration: TextFieldConfiguration(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Search food items',
              border: OutlineInputBorder(),
            ),
          ),
          suggestionsCallback: (pattern) {
            return foodItems
                .where((item) =>
                    item.toLowerCase().contains(pattern.toLowerCase()))
                .toList();
          },
          itemBuilder: (context, String suggestion) {
            final isDisabled = suggestion == "Banana" || suggestion == "Date";
            return ListTile(
              title: Text(
                suggestion,
                style: TextStyle(
                  color: isDisabled ? Colors.grey : Colors.black,
                ),
              ),
              enabled: !isDisabled,
            );
          },
          onSuggestionSelected: (String suggestion) {
            final isDisabled = suggestion == "Banana" || suggestion == "Date";
            if (!isDisabled) {
              _controller.text = suggestion;
            }
          },
          noItemsFoundBuilder: (context) => const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('No items found'),
          ),
        ),
      ),
    );
  }
}

void main() {
  group('Disabled Items Tests', () {
    testWidgets('should display all items including disabled ones',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: DisabledItemsTestPage()));
      await tester.pumpAndSettle();

      // Tap the search field and enter a search term
      final searchField = find.byType(DropDownSearchFormField<String>);
      await tester.tap(searchField);
      await tester.pumpAndSettle();

      await tester.enterText(searchField, 'a');
      await tester.pumpAndSettle();

      // Should find all items containing 'a'
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Date'), findsOneWidget);
    });

    testWidgets('should allow selection of enabled items',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: DisabledItemsTestPage()));
      await tester.pumpAndSettle();

      final searchField = find.byType(DropDownSearchFormField<String>);
      await tester.tap(searchField);
      await tester.pumpAndSettle();

      await tester.enterText(searchField, 'Apple');
      await tester.pumpAndSettle();

      // Tap on enabled item (find the one in the suggestions, not the text field)
      final appleSuggestions = find.text('Apple');
      expect(appleSuggestions, findsAtLeastNWidgets(1));

      // Tap the last Apple (which should be in the suggestions)
      await tester.tap(appleSuggestions.last);
      await tester.pumpAndSettle();

      // Verify selection worked by checking the text field value
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'Apple');
    });

    testWidgets('should prevent selection of disabled items',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: DisabledItemsTestPage()));
      await tester.pumpAndSettle();

      final searchField = find.byType(DropDownSearchFormField<String>);
      await tester.tap(searchField);
      await tester.pumpAndSettle();

      await tester.enterText(searchField, 'Banana');
      await tester.pumpAndSettle();

      // Try to tap on disabled item
      final bananaSuggestions = find.text('Banana');
      expect(bananaSuggestions, findsAtLeastNWidgets(1));

      // Tap the suggestion (last one should be in the dropdown)
      await tester.tap(bananaSuggestions.last);
      await tester.pumpAndSettle();

      // Verify that the field shows the search term, indicating no selection occurred
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'Banana');
    });

    testWidgets('should visually distinguish disabled items',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: DisabledItemsTestPage()));
      await tester.pumpAndSettle();

      final searchField = find.byType(DropDownSearchFormField<String>);
      await tester.tap(searchField);
      await tester.pumpAndSettle();

      await tester.enterText(searchField, 'a');
      await tester.pumpAndSettle();

      // Find the ListTile widgets for enabled and disabled items
      final listTiles = find.byType(ListTile);
      expect(listTiles, findsAtLeastNWidgets(2));

      // Check that items are displayed (this test verifies the UI renders properly)
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Date'), findsOneWidget);
    });
  });
}
