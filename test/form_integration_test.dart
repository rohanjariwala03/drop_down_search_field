import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FormIntegrationTestPage extends StatefulWidget {
  const FormIntegrationTestPage({super.key});

  @override
  State<FormIntegrationTestPage> createState() =>
      _FormIntegrationTestPageState();
}

class _FormIntegrationTestPageState extends State<FormIntegrationTestPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  final List<String> countries = ['USA', 'Canada', 'UK', 'Germany', 'France'];
  final List<String> cities = [
    'New York',
    'Toronto',
    'London',
    'Berlin',
    'Paris'
  ];

  String? _validationResult;

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _validationResult = 'Form is valid';
      });
    } else {
      setState(() {
        _validationResult = 'Form has errors';
      });
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _nameController.clear();
    _countryController.clear();
    _cityController.clear();
    setState(() {
      _validationResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Integration Test')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropDownSearchFormField<String>(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _countryController,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    border: OutlineInputBorder(),
                  ),
                ),
                suggestionsCallback: (pattern) {
                  return countries
                      .where((country) =>
                          country.toLowerCase().contains(pattern.toLowerCase()))
                      .toList();
                },
                itemBuilder: (context, String suggestion) {
                  return ListTile(title: Text(suggestion));
                },
                onSuggestionSelected: (String suggestion) {
                  _countryController.text = suggestion;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Country is required';
                  }
                  if (!countries.contains(value)) {
                    return 'Please select a valid country';
                  }
                  return null;
                },
                noItemsFoundBuilder: (context) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No countries found'),
                ),
              ),
              const SizedBox(height: 16),
              DropDownSearchFormField<String>(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                  ),
                ),
                suggestionsCallback: (pattern) {
                  return cities
                      .where((city) =>
                          city.toLowerCase().contains(pattern.toLowerCase()))
                      .toList();
                },
                itemBuilder: (context, String suggestion) {
                  return ListTile(title: Text(suggestion));
                },
                onSuggestionSelected: (String suggestion) {
                  _cityController.text = suggestion;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'City is required';
                  }
                  return null;
                },
                noItemsFoundBuilder: (context) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No cities found'),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Submit'),
                  ),
                  ElevatedButton(
                    onPressed: _resetForm,
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_validationResult != null)
                Text(
                  _validationResult!,
                  key: const Key('validation_result'),
                  style: TextStyle(
                    color: _validationResult == 'Form is valid'
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  group('Form Integration Tests', () {
    testWidgets('should display form with all fields',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(const MaterialApp(home: FormIntegrationTestPage()));
      await tester.pumpAndSettle();

      expect(find.byType(Form), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Country'), findsOneWidget);
      expect(find.text('City'), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('should show validation errors when form is submitted empty',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(const MaterialApp(home: FormIntegrationTestPage()));
      await tester.pumpAndSettle();

      // Submit form without filling any fields
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Name is required'), findsOneWidget);
      expect(find.text('Country is required'), findsOneWidget);
      expect(find.text('City is required'), findsOneWidget);
      expect(find.text('Form has errors'), findsOneWidget);
    });

    testWidgets('should integrate with form state management',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(const MaterialApp(home: FormIntegrationTestPage()));
      await tester.pumpAndSettle();

      // Submit empty form to trigger validation
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      // Should show form errors state
      expect(find.text('Form has errors'), findsOneWidget);

      // Fill one field and submit again
      await tester.enterText(find.byType(TextFormField), 'John Doe');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      // Should still show errors for unfilled dropdown fields
      expect(find.text('Country is required'), findsOneWidget);
      expect(find.text('City is required'), findsOneWidget);
    });
  });
}
