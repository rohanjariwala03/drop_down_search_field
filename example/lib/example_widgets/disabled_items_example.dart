import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';

class DisabledItemsExample extends StatefulWidget {
  const DisabledItemsExample({super.key});

  @override
  State<DisabledItemsExample> createState() => _DisabledItemsExampleState();
}

class _DisabledItemsExampleState extends State<DisabledItemsExample> {
  final TextEditingController _dropdownSearchFieldController =
      TextEditingController();

  SuggestionsBoxController suggestionBoxController = SuggestionsBoxController();

  // Example data structure with disabled items
  static final List<Map<String, dynamic>> fruits = [
    {'name': 'Apple', 'disabled': false},
    {'name': 'Avocado', 'disabled': true}, // This item is disabled
    {'name': 'Banana', 'disabled': false},
    {'name': 'Blueberries', 'disabled': false},
    {'name': 'Blackberries', 'disabled': true}, // This item is disabled
    {'name': 'Cherries', 'disabled': false},
    {'name': 'Grapes', 'disabled': false},
    {'name': 'Grapefruit', 'disabled': true}, // This item is disabled
    {'name': 'Guava', 'disabled': false},
    {'name': 'Kiwi', 'disabled': false},
    {'name': 'Lychee', 'disabled': false},
    {'name': 'Mango', 'disabled': false},
    {'name': 'Orange', 'disabled': false},
    {'name': 'Papaya', 'disabled': true}, // This item is disabled
    {'name': 'Passion fruit', 'disabled': false},
    {'name': 'Peach', 'disabled': false},
    {'name': 'Pears', 'disabled': false},
    {'name': 'Pineapple', 'disabled': false},
    {'name': 'Raspberries', 'disabled': false},
    {'name': 'Strawberries', 'disabled': false},
    {'name': 'Watermelon', 'disabled': false},
  ];

  static List<Map<String, dynamic>> getSuggestions(String query) {
    List<Map<String, dynamic>> matches = <Map<String, dynamic>>[];
    matches.addAll(fruits);
    matches.retainWhere(
        (fruit) => fruit['name'].toLowerCase().contains(query.toLowerCase()));
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disabled Items Example'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: GestureDetector(
        onTap: () {
          suggestionBoxController.close();
        },
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Dropdown with Disabled Items',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Try typing fruit names. Some items like "Avocado", "Blackberries", "Grapefruit", and "Papaya" are disabled and cannot be selected.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              DropDownSearchField<Map<String, dynamic>>(
                textFieldConfiguration: TextFieldConfiguration(
                  decoration: const InputDecoration(
                    labelText: 'Select a fruit',
                    border: OutlineInputBorder(),
                  ),
                  controller: _dropdownSearchFieldController,
                ),
                suggestionsCallback: (pattern) {
                  return getSuggestions(pattern);
                },
                itemBuilder: (context, Map<String, dynamic> suggestion) {
                  final isDisabled = suggestion['disabled'] as bool;
                  return ListTile(
                    enabled: !isDisabled,
                    title: Text(suggestion['name']),
                    trailing: isDisabled
                        ? const Icon(Icons.block, color: Colors.grey, size: 16)
                        : null,
                  );
                },
                // This is the new callback that determines if an item is disabled
                itemDisabledCallback: (Map<String, dynamic> suggestion) {
                  return suggestion['disabled'] as bool;
                },
                itemSeparatorBuilder: (context, index) {
                  return const Divider();
                },
                transitionBuilder: (context, suggestionsBox, controller) {
                  return suggestionsBox;
                },
                onSuggestionSelected: (Map<String, dynamic> suggestion) {
                  _dropdownSearchFieldController.text = suggestion['name'];
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Selected: ${suggestion['name']}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                suggestionsBoxController: suggestionBoxController,
                displayAllSuggestionWhenTap: true,
                isMultiSelectDropdown: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
