import 'dart:math';

import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';

class PaginatedSuggestionExample extends StatefulWidget {
  const PaginatedSuggestionExample({super.key});

  @override
  State<PaginatedSuggestionExample> createState() =>
      _PaginatedSuggestionExampleState();
}

class _PaginatedSuggestionExampleState
    extends State<PaginatedSuggestionExample> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dropdownSearchFieldController =
      TextEditingController();
  SuggestionsBoxController suggestionBoxController = SuggestionsBoxController();
  String? _selectedName;

  final List<String> names = [];

  String generateRandomName() {
    const characters = 'abcdefghijklmnopqrstuvwxyz';
    final random = Random();
    final length = random.nextInt(5) + 4; // Generates a length between 4 and 8
    return String.fromCharCodes(Iterable.generate(
      length,
      (_) => characters.codeUnitAt(random.nextInt(characters.length)),
    ));
  }

  List<String> getSuggestions(String query) {
    if (query.isNotEmpty) {
      final tempList = names
          .where((s) => s.toLowerCase().contains(query.toLowerCase()))
          .toList();
      return tempList;
    }
    int i = 0;
    while (i < 10) {
      names.add(generateRandomName());
      i++;
    }
    return names;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        suggestionBoxController.close();
      },
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('What is your favorite name?'),
              DropDownSearchFormField(
                textFieldConfiguration: TextFieldConfiguration(
                  decoration: const InputDecoration(labelText: 'Name'),
                  controller: _dropdownSearchFieldController,
                ),
                paginatedSuggestionsCallback: (pattern) async {
                  // await Future.delayed(const Duration(seconds: 5));
                  final suggestionsToReturn = getSuggestions(pattern);
                  return suggestionsToReturn;
                },
                itemBuilder: (context, String suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                itemSeparatorBuilder: (context, index) {
                  return const Divider();
                },
                transitionBuilder: (context, suggestionsBox, controller) {
                  return suggestionsBox;
                },
                onSuggestionSelected: (String suggestion) {
                  _dropdownSearchFieldController.text = suggestion;
                },
                suggestionsBoxController: suggestionBoxController,
                validator: (value) =>
                    value!.isEmpty ? 'Please select a name' : null,
                onSaved: (value) => _selectedName = value,
                displayAllSuggestionWhenTap: true,
              ),
              const Spacer(),
              ElevatedButton(
                child: const Text('Submit'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Your favorite name is $_selectedName.'),
                      ),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
