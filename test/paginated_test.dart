import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class PaginatedTestPage extends StatefulWidget {
  const PaginatedTestPage({super.key});

  @override
  State<PaginatedTestPage> createState() => _PaginatedTestPageState();
}

class _PaginatedTestPageState extends State<PaginatedTestPage> {
  final TextEditingController _controller = TextEditingController();

  // Simulated large dataset
  final List<String> allCountries = [
    'Afghanistan',
    'Albania',
    'Algeria',
    'Argentina',
    'Armenia',
    'Australia',
    'Austria',
    'Azerbaijan',
    'Bahrain',
    'Bangladesh',
    'Belarus',
    'Belgium',
    'Brazil',
    'Bulgaria',
    'Cambodia',
    'Cameroon',
    'Canada',
    'Chile',
    'China',
    'Colombia',
    'Croatia',
    'Czech Republic',
    'Denmark',
    'Ecuador',
    'Egypt',
    'Estonia',
    'Finland',
    'France',
    'Georgia',
    'Germany',
    'Ghana',
    'Greece',
    'Hungary',
    'Iceland',
    'India',
    'Indonesia',
    'Iran',
    'Iraq',
    'Ireland',
    'Israel',
    'Italy',
    'Japan',
    'Jordan',
    'Kazakhstan',
    'Kenya',
    'Kuwait',
    'Latvia',
    'Lebanon',
    'Lithuania',
    'Luxembourg',
    'Malaysia',
    'Mexico',
    'Morocco',
    'Netherlands',
    'New Zealand',
    'Nigeria',
    'Norway',
    'Pakistan',
    'Peru',
    'Philippines',
    'Poland',
    'Portugal',
    'Qatar',
    'Romania',
    'Russia',
    'Saudi Arabia',
    'Singapore',
    'Slovakia',
    'Slovenia',
    'South Africa',
    'South Korea',
    'Spain',
    'Sri Lanka',
    'Sweden',
    'Switzerland',
    'Thailand',
    'Turkey',
    'Ukraine',
    'United Arab Emirates',
    'United Kingdom',
    'United States',
    'Uruguay',
    'Venezuela',
    'Vietnam'
  ];

  // Simulate paginated API call
  Future<List<String>> _getCountries(String pattern) async {
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simulate network delay

    final filtered = allCountries
        .where(
            (country) => country.toLowerCase().contains(pattern.toLowerCase()))
        .toList();

    // Return first 10 items (simulate pagination)
    return filtered.take(10).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paginated Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropDownSearchFormField<String>(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Search countries',
                  border: OutlineInputBorder(),
                  helperText: 'Shows max 10 results',
                ),
              ),
              suggestionsCallback: _getCountries,
              itemBuilder: (context, String suggestion) {
                return ListTile(
                  title: Text(suggestion),
                  leading: const Icon(Icons.location_on),
                );
              },
              onSuggestionSelected: (String suggestion) {
                _controller.text = suggestion;
              },
              noItemsFoundBuilder: (context) => const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No countries found'),
              ),
              loadingBuilder: (context) => const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              minCharsForSuggestions: 2,
              debounceDuration: const Duration(milliseconds: 300),
            ),
            const SizedBox(height: 20),
            Text(
              'Selected: ${_controller.text}',
              key: const Key('selected_country_text'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  group('Paginated Tests', () {
    testWidgets('should display paginated dropdown field',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PaginatedTestPage()));
      await tester.pumpAndSettle();

      expect(find.byType(DropDownSearchFormField<String>), findsOneWidget);
      expect(find.text('Search countries'), findsOneWidget);
      expect(find.text('Shows max 10 results'), findsOneWidget);
    });

    testWidgets('should show loading indicator during search',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PaginatedTestPage()));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      // Enter search term that meets minimum chars requirement
      await tester.enterText(textField, 'Un');
      await tester.pump(); // Don't settle yet to catch loading state

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should respect minimum characters for suggestions',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PaginatedTestPage()));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      // Enter only 1 character (less than minimum of 2)
      await tester.enterText(textField, 'A');
      await tester.pumpAndSettle();

      // Should not show suggestions
      expect(find.text('Afghanistan'), findsNothing);
      expect(find.text('Albania'), findsNothing);
    });

    testWidgets('should show suggestions after minimum characters',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PaginatedTestPage()));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      // Enter 2 characters (meets minimum requirement)
      await tester.enterText(textField, 'Un');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Should show United countries
      expect(find.text('United Kingdom'), findsOneWidget);
      expect(find.text('United States'), findsOneWidget);
    });

    testWidgets('should limit results to 10 items',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PaginatedTestPage()));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      // Search for 'a' which should match many countries
      await tester.enterText(textField, 'a');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Count the number of ListTile widgets (suggestions)
      final listTiles = find.byType(ListTile);
      expect(listTiles.evaluate().length, lessThanOrEqualTo(10));
    });

    testWidgets('should handle selection correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PaginatedTestPage()));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      // Search for specific country
      await tester.enterText(textField, 'Canada');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Select Canada
      await tester.tap(find.text('Canada'));
      await tester.pumpAndSettle();

      // Verify selection
      expect(find.textContaining('Selected: Canada'), findsOneWidget);
    });

    testWidgets('should show no results message when appropriate',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PaginatedTestPage()));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      // Search for non-existent country
      await tester.enterText(textField, 'Atlantis');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('No countries found'), findsOneWidget);
    });

    testWidgets('should handle debounce correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PaginatedTestPage()));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      // Type quickly (simulate rapid typing)
      await tester.enterText(textField, 'Ge');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(textField, 'Ger');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(textField, 'Germ');

      // Wait for debounce to complete
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Should show Germany
      expect(find.text('Germany'), findsOneWidget);
    });

    testWidgets('should display icons in suggestions',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PaginatedTestPage()));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      await tester.enterText(textField, 'France');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Should show location icons
      expect(find.byIcon(Icons.location_on), findsAtLeastNWidgets(1));
    });
  });
}
