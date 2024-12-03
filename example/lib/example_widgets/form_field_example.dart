import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';

class FormFieldExample extends StatefulWidget {
  const FormFieldExample({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FormFieldExampleState createState() => _FormFieldExampleState();
}

class _FormFieldExampleState extends State<FormFieldExample> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dropdownSearchFieldController =
      TextEditingController();

  String? _selectedFruit;

  SuggestionsBoxController suggestionBoxController = SuggestionsBoxController();
  static final List<String> fruits = [
    'Apple',
    'Avocado',
    'Banana',
    'Blueberries',
    'Blackberries',
    'Cherries',
    'Grapes',
    'Grapefruit',
    'Guava',
    'Kiwi',
    'Lychee',
    'Mango',
    'Orange',
    'Papaya',
    'Passion fruit',
    'Peach',
    'Pears',
    'Pineapple',
    'Raspberries',
    'Strawberries',
    'Watermelon',
  ];
  static List<String> getSuggestions(String query) {
    List<String> matches = <String>[];
    matches.addAll(fruits);

    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Field Example'),
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
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('What is your favorite fruit?'),
                DropDownSearchFormField(
                  textFieldConfiguration: TextFieldConfiguration(
                    decoration: const InputDecoration(labelText: 'Fruit'),
                    controller: _dropdownSearchFieldController,
                  ),
                  suggestionsCallback: (pattern) {
                    return getSuggestions(pattern);
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
                      value!.isEmpty ? 'Please select a fruit' : null,
                  onSaved: (value) => _selectedFruit = value,
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
                          content: Text('You love $_selectedFruit to eat'),
                        ),
                      );
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
