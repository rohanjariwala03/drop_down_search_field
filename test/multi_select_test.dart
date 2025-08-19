import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class SimpleMultiSelectTestPage extends StatefulWidget {
  const SimpleMultiSelectTestPage({super.key});

  @override
  State<SimpleMultiSelectTestPage> createState() =>
      _SimpleMultiSelectTestPageState();
}

class _SimpleMultiSelectTestPageState extends State<SimpleMultiSelectTestPage> {
  final List<String> selectedItems = [];
  final List<String> allItems = [
    "React",
    "Angular",
    "Vue",
    "Svelte",
    "Flutter",
    "React Native",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multi Select Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            MultiSelectDropdownSearchFormField<String>(
              textFieldConfiguration: const TextFieldConfiguration(
                decoration: InputDecoration(
                  labelText: 'Select frameworks',
                  border: OutlineInputBorder(),
                ),
              ),
              initiallySelectedItems: selectedItems,
              onMultiSuggestionSelected: (String suggestion, bool selected) {
                setState(() {
                  if (selected) {
                    if (!selectedItems.contains(suggestion)) {
                      selectedItems.add(suggestion);
                    }
                  } else {
                    selectedItems.remove(suggestion);
                  }
                });
              },
              chipBuilder: (context, item) {
                return Chip(
                  label: Text(item),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () {
                    setState(() {
                      selectedItems.remove(item);
                    });
                  },
                );
              },
              suggestionsCallback: (pattern) {
                return allItems
                    .where((item) =>
                        item.toLowerCase().contains(pattern.toLowerCase()))
                    .toList();
              },
              itemBuilder: (context, String suggestion) {
                final isSelected = selectedItems.contains(suggestion);
                return ListTile(
                  title: Text(suggestion),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  tileColor: isSelected ? Colors.green.shade50 : null,
                );
              },
              noItemsFoundBuilder: (context) => const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('No frameworks found'),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Selected: ${selectedItems.join(', ')}',
              key: const Key('selected_items_text'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  group('Multi Select Tests', () {
    testWidgets('should display multi select dropdown',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(const MaterialApp(home: SimpleMultiSelectTestPage()));
      await tester.pumpAndSettle();

      expect(find.byType(MultiSelectDropdownSearchFormField<String>),
          findsOneWidget);
      expect(find.text('Select frameworks'), findsOneWidget);
    });

    testWidgets('should show suggestions when typing',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(const MaterialApp(home: SimpleMultiSelectTestPage()));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      // Enter text to trigger suggestions
      await tester.enterText(textField, 'React');
      await tester.pumpAndSettle();

      // Should show React and React Native
      expect(find.text('React'), findsAtLeastNWidgets(1));
      expect(find.text('React Native'), findsOneWidget);
    });

    testWidgets('should filter items based on search',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(const MaterialApp(home: SimpleMultiSelectTestPage()));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      // Search for 'React'
      await tester.enterText(textField, 'React');
      await tester.pumpAndSettle();

      // Should show React and React Native but not others
      expect(find.text('React'), findsAtLeastNWidgets(1));
      expect(find.text('React Native'), findsOneWidget);
      expect(find.text('Angular'), findsNothing);
      expect(find.text('Vue'), findsNothing);
    });

    testWidgets('should handle empty search results',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(const MaterialApp(home: SimpleMultiSelectTestPage()));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      // Search for non-existent item
      await tester.enterText(textField, 'NonExistentFramework');
      await tester.pumpAndSettle();

      expect(find.text('No frameworks found'), findsOneWidget);
    });

    testWidgets('should display form field correctly',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(const MaterialApp(home: SimpleMultiSelectTestPage()));
      await tester.pumpAndSettle();

      // Check basic UI elements
      expect(find.text('Select frameworks'), findsOneWidget);
      expect(find.text('Selected: '), findsOneWidget);
    });

    testWidgets('should allow text input and suggestions',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(const MaterialApp(home: SimpleMultiSelectTestPage()));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      // Type partial text
      await tester.enterText(textField, 'Fl');
      await tester.pumpAndSettle();

      // Should show Flutter
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('React'), findsNothing);
    });
  });
}
