import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class EdgeCasesTestPage extends StatefulWidget {
  final bool simulateError;
  final bool simulateSlowNetwork;
  final bool enableEmptyResults;

  const EdgeCasesTestPage({
    super.key,
    this.simulateError = false,
    this.simulateSlowNetwork = false,
    this.enableEmptyResults = false,
  });

  @override
  State<EdgeCasesTestPage> createState() => _EdgeCasesTestPageState();
}

class _EdgeCasesTestPageState extends State<EdgeCasesTestPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> items = ['Apple', 'Banana', 'Cherry', 'Date'];

  Future<List<String>> _getItems(String pattern) async {
    if (widget.simulateError) {
      throw Exception('Network error occurred');
    }

    if (widget.simulateSlowNetwork) {
      await Future.delayed(const Duration(seconds: 5));
    }

    if (widget.enableEmptyResults) {
      return [];
    }

    return items
        .where((item) => item.toLowerCase().contains(pattern.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edge Cases Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DropDownSearchFormField<String>(
          textFieldConfiguration: TextFieldConfiguration(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Search items',
              border: OutlineInputBorder(),
            ),
          ),
          suggestionsCallback: _getItems,
          itemBuilder: (context, String suggestion) {
            return ListTile(title: Text(suggestion));
          },
          onSuggestionSelected: (String suggestion) {
            _controller.text = suggestion;
          },
          errorBuilder: (context, error) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: ${error.toString()}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          },
          noItemsFoundBuilder: (context) => const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No items found'),
          ),
          loadingBuilder: (context) => const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}

void main() {
  group('Edge Cases Tests', () {
    testWidgets('should handle network errors gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EdgeCasesTestPage(simulateError: true),
        ),
      );
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      await tester.enterText(textField, 'Apple');
      await tester.pumpAndSettle();

      // Should display error message
      expect(find.textContaining('Error:'), findsOneWidget);
      expect(find.textContaining('Network error occurred'), findsOneWidget);
    });

    testWidgets('should handle empty results correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EdgeCasesTestPage(enableEmptyResults: true),
        ),
      );
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      await tester.enterText(textField, 'Apple');

      // Wait for debounce duration to trigger the search
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Should show no items found message
      expect(find.text('No items found'), findsOneWidget);
    });

    testWidgets('should handle null or empty search patterns',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: EdgeCasesTestPage()),
      );
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      // Test with empty string
      await tester.enterText(textField, '');
      await tester.pumpAndSettle();

      // Should not crash and should handle empty pattern gracefully
      expect(find.byType(DropDownSearchFormField<String>), findsOneWidget);
    });

    testWidgets('should handle special characters in search',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: EdgeCasesTestPage()),
      );
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      // Test with special characters
      await tester.enterText(textField, '@#\$%');
      await tester.pumpAndSettle();

      // Should not crash
      expect(find.byType(DropDownSearchFormField<String>), findsOneWidget);
    });

    testWidgets('should handle very long search strings',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: EdgeCasesTestPage()),
      );
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      // Test with very long string
      final longString = 'A' * 1000;
      await tester.enterText(textField, longString);
      await tester.pumpAndSettle();

      // Should not crash
      expect(find.byType(DropDownSearchFormField<String>), findsOneWidget);
    });

    testWidgets('should handle rapid consecutive searches',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: EdgeCasesTestPage()),
      );
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      // Rapid fire multiple searches
      for (int i = 0; i < 10; i++) {
        await tester.enterText(textField, 'Search$i');
        await tester.pump(const Duration(milliseconds: 50));
      }

      await tester.pumpAndSettle();

      // Should handle all searches without crashing
      expect(find.byType(DropDownSearchFormField<String>), findsOneWidget);
    });

    testWidgets('should handle widget disposal during async operation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EdgeCasesTestPage(simulateSlowNetwork: true),
        ),
      );
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      // Start a search that will take a long time
      await tester.enterText(textField, 'Apple');
      await tester.pump(); // Don't settle

      // Navigate away while the search is still pending
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Text('New Page')),
        ),
      );
      await tester.pumpAndSettle();

      // Should not crash
      expect(find.text('New Page'), findsOneWidget);
    });

    testWidgets('should handle form validation errors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: DropDownSearchFormField<String>(
                textFieldConfiguration: const TextFieldConfiguration(
                  decoration: InputDecoration(labelText: 'Required Field'),
                ),
                suggestionsCallback: (pattern) => ['Item1', 'Item2'],
                itemBuilder: (context, item) => ListTile(title: Text(item)),
                onSuggestionSelected: (item) {},
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The field should be present
      expect(find.byType(DropDownSearchFormField<String>), findsOneWidget);
      expect(find.text('Required Field'), findsOneWidget);
    });
  });
}
