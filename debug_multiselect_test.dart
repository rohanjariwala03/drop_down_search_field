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
                final filtered = allItems
                    .where((item) =>
                        item.toLowerCase().contains(pattern.toLowerCase()))
                    .toList();
                return filtered;
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
  testWidgets('Debug multi select filtering', (WidgetTester tester) async {
    await tester
        .pumpWidget(const MaterialApp(home: SimpleMultiSelectTestPage()));
    await tester.pumpAndSettle();

    debugDumpApp();

    // Tap on the multi-select dropdown to open it
    final multiSelect = find.byType(MultiSelectDropdownSearchFormField<String>);
    await tester.tap(multiSelect);
    await tester.pumpAndSettle();

    final textField = find.byType(TextField);

    if (textField.evaluate().isNotEmpty) {
      // Search for 'React'
      await tester.enterText(textField, 'React');
      await tester.pumpAndSettle();

      final allTexts = find.byType(Text);
      for (int i = 0; i < allTexts.evaluate().length; i++) {
        tester.widget<Text>(allTexts.at(i));
      }
    }
  });
}
